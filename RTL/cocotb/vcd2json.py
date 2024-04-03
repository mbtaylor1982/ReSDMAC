"""Create WaveJSON text string from VCD file."""
import sys


class _SignalDef:
    def __init__(self, name, sid, length):
        self._name = name
        self._sid = sid
        self._length = length
        self._fmt = ''


class WaveExtractor:

    def __init__(self, vcd_file, json_file, path_list):
        """
        Extract signal values from VCD file and output in JSON format.
        Specify VCD filename, JSON filename, and signal path list.
        If <json_file> is an empty string, standard output is used.
        Use slashes to separate signal path hierarchies.
        The first signal of the list is regarded as clock.
        Other signals are sampled on the negative edge of the clock.
        """
        self._vcd_file = vcd_file
        self._json_file = json_file
        self._path_list = [path.strip('/') for path in path_list]
        self._wave_chunk = 20
        self._start_time = 0
        self._end_time = 0
        self._setup()

    @property
    def wave_chunk(self):
        """Number of wave samples per time group."""
        return self._wave_chunk

    @wave_chunk.setter
    def wave_chunk(self, value):
        self._wave_chunk = value

    @property
    def start_time(self):
        """Sampling start time."""
        return self._start_time

    @start_time.setter
    def start_time(self, value):
        self._start_time = value

    @property
    def end_time(self):
        """Sampling end time."""
        return self._end_time

    @end_time.setter
    def end_time(self, value):
        self._end_time = value

    def _setup(self):

        def create_path_dict(fin):
            hier_list = []
            path_list = []
            path_dict = {}
            while True:
                line = fin.readline()
                if not line:
                    raise EOFError('Can\'t find word "$enddefinitions".')
                words = line.split()
                if not words:
                    continue
                if words[0] == '$enddefinitions':
                    return path_list, path_dict
                if words[0] == '$scope':
                    hier_list.append(words[2])
                elif words[0] == '$var':
                    path = '/'.join(hier_list + [words[4]])
                    path_list.append(path)
                    path_dict[path] = _SignalDef(name=words[4],
                                                 sid=words[3],
                                                 length=int(words[2]))
                elif words[0] == '$upscope':
                    del hier_list[-1]

        def update_path_dict(path_list, path_dict):
            new_path_dict = {}
            for path in path_list:
                signal_def = path_dict.get(path, None)
                if not signal_def:
                    raise ValueError('Can\'t find path "{0}".'.format(path))
                new_path_dict[path] = signal_def
            return new_path_dict

        fin = open(self._vcd_file, 'rt')
        path_list, path_dict = create_path_dict(fin)
        if self._path_list:
            path_dict = update_path_dict(self._path_list, path_dict)
        else:
            self._path_list = path_list
        self._path_dict = path_dict
        self._fin = fin

    def print_props(self):
        """
        Display the properties. If an empty path list is given to
        the constructor, display the list created from the VCD file.
        """
        print("vcd_file  = '" + self._vcd_file + "'")
        print("json_file = '" + self._json_file + "'")
        print("path_list = [", end='')
        for i, path in enumerate(self._path_list):
            if i != 0:
                print("             ", end='')
            print("'" + path + "'", end='')
            if i != len(self._path_list)-1:
                print(",")
            else:
                print("]")
        print("wave_chunk = " + str(self._wave_chunk))
        print("start_time = " + str(self._start_time))
        print("end_time   = " + str(self._end_time))
        return 0

    def wave_format(self, signal_path, fmt):
        """
        Set the display format of the multi-bit signal. <fmt> is
        one of the following characters. The default is 'x'.
        'b' - Binary.
        'd' - Signed decimal.
        'u' - Unsigned decimal.
        'x' - Hexa-decimal, lowercase is used.
        'X' - Hexa-decimal, uppercase is used.
        """
        if fmt not in ('b', 'd', 'u', 'x', 'X'):
            raise ValueError('"{0}": Invalid format character.'.format(fmt))
        self._path_dict[signal_path]._fmt = fmt
        return 0

    def execute(self):
        """Perform signal sampling and JSON generation."""
        fin = self._fin
        path_list = self._path_list
        path_dict = self._path_dict
        wave_chunk = self._wave_chunk
        start_time = self._start_time
        end_time = self._end_time

        sampler = _SignalSampler(wave_chunk, start_time, end_time)
        jsongen = _JsonGenerator(path_list, path_dict, wave_chunk)

        clock_id = path_dict[path_list[0]]._sid
        id_list = [path_dict[path]._sid for path in path_list]
        value_dict = {sid: 'x' for sid in id_list}
        sample_dict = {sid: [] for sid in id_list}

        if self._json_file == '':
            fout = sys.stdout
        else:
            self.print_props()
            print()
            print('Create WaveJSON file "{0}".'.format(self._json_file))
            fout = open(self._json_file, 'wt')
        fout.write(jsongen.create_header())

        while True:
            origin = sampler.run(fin, clock_id, value_dict, sample_dict)
            if len(sample_dict[clock_id]) == 0:
                break
            fout.write(jsongen.create_body(origin, sample_dict))

        fout.write(jsongen.create_footer())
        fin.close()
        fout.close()
        return 0


class _SignalSampler():

    def __init__(self, wave_chunk, start_time, end_time):
        self._wave_chunk = wave_chunk
        self._start_time = start_time
        self._end_time = end_time
        self._now = 0

    def run(self, fin, clock_id, value_dict, sample_dict):

        origin = self._now
        clock_prev = value_dict[clock_id]
        for sid in sample_dict:
            del sample_dict[sid][:]
        data_count = 0
        while True:
            if self._end_time != 0 and self._end_time < int(self._now):
                return origin
            line = fin.readline()
            if not line:
                return origin
            words = line.split()
            if not words:
                continue
            char = words[0][0]
            if char == '$':
                continue
            if char == 'r':
                continue
            if char in ('0', '1', 'x', 'z'):
                sid = words[0][1:]
                if sid in value_dict:
                    value_dict[sid] = char
                continue
            if char == 'b':
                sid = words[1]
                if sid in value_dict:
                    value_dict[sid] = words[0][1:]
                continue
            if char == '#':
                next_now = words[0][1:]
                clock = value_dict[clock_id]
                if clock_prev == '0' and clock == '1':
                    if data_count == 0:
                        origin = self._now
                elif self._start_time <= int(origin) and \
                        clock_prev == '1' and clock == '0':
                    for sid in sample_dict:
                        sample_dict[sid].append(value_dict[sid])
                    data_count += 1
                    if data_count == self._wave_chunk:
                        self._now = next_now
                        return origin
                self._now = next_now
                clock_prev = clock
                continue
            raise ValueError('"{0}": Unexpected character.'.format(char))


class _JsonGenerator():

    def __init__(self, path_list, path_dict, wave_chunk):
        self._path_list = path_list
        self._path_dict = path_dict
        self._wave_chunk = wave_chunk
        self._clock_name = path_dict[path_list[0]]._name
        self._name_width = max([len(path_dict[path]._name)
                                for path in path_list])

    def create_header(self):
        name = '"{0}"'.format(self._clock_name).ljust(self._name_width + 2)
        wave = '"{0}"'.format('p' + '.' * (self._wave_chunk - 1))
        json =  '{ "head": {"tock":1},\n'
        json += '  "signal": [\n'
        json += '  {   "name": '+name+', "wave": '+wave+' }'
        return json

    def create_body(self, origin, sample_dict):

        def create_wave(samples):
            prev = None
            wave = ''
            for value in samples:
                if value == prev:
                    wave += '.'
                else:
                    wave += value
                prev = value
            return '"'+wave+'"'

        def create_wave_data(samples, length, fmt):
            prev = None
            wave = ''
            data = ''
            for value in samples:
                if value == prev:
                    wave += '.'
                elif all([c == '0' or c == '1' for c in value]):
                    wave += '='
                    data += ' ' + data_format(value, length, fmt)
                elif all([c == 'z' for c in value]):
                    wave += 'z'
                else:
                    wave += 'x'
                prev = value
            return '"'+wave+'"', '"'+data[1:]+'"'

        def data_format(value, length, fmt):
            value = int(value, 2)
            if fmt == 'b':
                fmt = '0' + str(length) + 'b'
            elif fmt == 'd':
                if value >= 2**(length-1):
                    value -= 2**length
            elif fmt == 'u':
                fmt = 'd'
            elif fmt == 'X':
                fmt = '0' + str((length+3)//4) + 'X'
            else:
                fmt = '0' + str((length+3)//4) + 'x'
            return format(value, fmt)

        json =  ',\n'
        json += '  {},\n'
        json += '  ["{0}"'.format(origin)
        for path in self._path_list[1:]:
            name   = self._path_dict[path]._name
            sid    = self._path_dict[path]._sid
            length = self._path_dict[path]._length
            if length == 1:
                name = '"{0}"'.format(name).ljust(self._name_width + 2)
                wave = create_wave(sample_dict[sid])
                json += ',\n    { "name": '+name+', "wave": '+wave+' }'
            else:
                fmt = self._path_dict[path]._fmt
                name = '"{0}"'.format(name).ljust(self._name_width + 2)
                wave, data = create_wave_data(sample_dict[sid], length, fmt)
                json += ',\n    { "name": '+name+', "wave": '+wave+\
                                                 ', "data": '+data+' }'
        json += '\n  ]'
        return json

    def create_footer(self):
        json =  '\n'
        json += '  ]\n'
        json += '}\n'
        return json
