# Development Environment Setup Guide

This guide explains how to set up a local development environment for the ReSDMAC project using Docker and VSCode.

## Prerequisites

### Required Software
1. **Docker Desktop** - For running containerized builds and tests
   - Windows: [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
   - Linux: [Docker Engine](https://docs.docker.com/engine/install/)
   - Ensure Docker is running before attempting builds

2. **Visual Studio Code** - Primary IDE for development
   - [Download VSCode](https://code.visualstudio.com/)

3. **Git** - Version control
   - [Download Git](https://git-scm.com/downloads)

### Optional (for Dev Container workflow)
- **Remote - Containers** VSCode extension (for Dev Container support)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/mbtaylor1982/SDMAC-Replacement.git
cd SDMAC-Replacement

# Open in VSCode
code .
```

## Docker Images Used

The project uses three custom Docker images for different tasks:

| Image | Purpose | Size |
|-------|---------|------|
| `mbtaylor1982/quartus:22.1` | FPGA synthesis (Quartus Prime 22.1 Lite) | ~8GB |
| `mbtaylor1982/cocotb-iverilog:latest` | RTL simulation and testing | ~1GB |
| `ghcr.io/inti-cmnb/kicad5_auto:latest` | KiCad PCB output generation | ~2GB |

Pull the images in advance to avoid delays during first build:
```bash
docker pull mbtaylor1982/quartus:22.1
docker pull mbtaylor1982/cocotb-iverilog:latest
docker pull ghcr.io/inti-cmnb/kicad5_auto:latest
```

## Development Workflows

### Option 1: Dev Container (Recommended)

The project includes a Dev Container configuration that provides a consistent development environment.

1. Install the **Dev Containers** extension in VSCode
2. Open the project folder in VSCode
3. Press `F1` and select **Dev Containers: Reopen in Container**
4. VSCode will build and start the container with all required extensions

The Dev Container includes:
- Docker-in-Docker support (for running build containers)
- All recommended VSCode extensions pre-installed
- Debian Bullseye base environment

### Option 2: Local VSCode with Docker Tasks

Use VSCode locally and run builds via Docker tasks.

#### Recommended Extensions

Install these extensions for the best experience:

**Verilog/HDL:**
- `mshr-h.veriloghdl` - Verilog language support and linting
- `tzylee.verilog-highlight` - Syntax highlighting
- `czh.czh-verilog-snippet` - Code snippets
- `czj.verilog-simplealign` - Code alignment

**Testing & Simulation:**
- `Cameron.vscode-pytest` - pytest integration
- `ms-python.python` - Python support
- `bmpenuelas.waveform-render` - VCD waveform visualization
- `surfer-project.surfer` - Waveform viewer

**Git & GitHub:**
- `mhutchie.git-graph` - Git graph visualization
- `donjayamanne.githistory` - Git history
- `github.vscode-github-actions` - GitHub Actions monitoring

**Other:**
- `aaron-bond.better-comments` - Enhanced comments
- `usernamehw.errorlens` - Inline error display
- `go2sh.tcl-language-support` - TCL script support
- `redhat.vscode-yaml` - YAML support

## VSCode Tasks

The project provides pre-configured tasks accessible via `Ctrl+Shift+B` (build) or `Ctrl+Shift+P` > "Tasks: Run Task".

### Build Firmware

Compiles the FPGA bitstream using Quartus.

- **Task:** `Build Firmware`
- **Shortcut:** `Ctrl+Shift+B` (default build task)
- **Prompts for:** Target device (10M02, 10M04, or 10M16)

```bash
# Equivalent manual command (Windows PowerShell)
docker run --rm -v ${pwd}:/build -w /build/Quartus -it mbtaylor1982/quartus:22.1 quartus_sh -t RESDMAC.tcl -device 10M16SCU169C8G -version v9.9
```

**Supported Devices:**
| Device | Description |
|--------|-------------|
| `10M02SCU169C8G` | Intel MAX 10 - 2K LEs |
| `10M04SCU169C8G` | Intel MAX 10 - 4K LEs |
| `10M16SCU169C8G` | Intel MAX 10 - 16K LEs (default) |

### Run Testbench

Runs cocotb tests using pytest.

- **Task:** `Run Testbench`
- **Group:** Test (default test task)

```bash
# Equivalent manual command (Windows PowerShell)
docker run --rm -v ${pwd}:/test -w /test -it mbtaylor1982/cocotb-iverilog:latest pytest -o log_cli=true
```

Test outputs:
- Console output with pass/fail status
- VCD waveform files in `sim_build/` (viewable with waveform extensions)
- Timing diagram JSON files in `Docs/TimingDiagrams/`

### Clean

Removes build artifacts and simulation outputs.

- **Task:** `Clean`

### KiCad Output

Generates PCB manufacturing files.

- **Task:** `Kicad_Output`

## Quartus License (Optional)

For full Quartus functionality, you may need a license file. The tasks reference a license path:

```
-e LM_LICENSE_FILE=/opt/license.dat -v /path/to/license.dat:/opt/license.dat:ro
```

**Note:** Quartus Prime Lite Edition (used by this project) is free and does not require a license for the MAX 10 devices used.

To use a license file, update the path in `.vscode/tasks.json`:
```json
"-v /path/to/license.dat:/opt/license.dat:ro"
```
Replace `/path/to/license.dat` with your actual license file path.

## Project Structure Overview

```
SDMAC-Replacement/
├── RTL/                    # Verilog RTL source code
│   ├── RESDMAC.v          # Top-level module
│   ├── CPU_SM/            # CPU-side state machine
│   ├── SCSI_SM/           # SCSI-side state machine
│   ├── FIFO/              # FIFO implementation
│   ├── Registers/         # Register file
│   ├── datapath/          # Data path logic
│   └── cocotb/            # Python testbenches
├── Quartus/               # FPGA project files
│   ├── RESDMAC.qpf       # Quartus project
│   ├── RESDMAC.qsf       # Project settings
│   ├── RESDMAC.tcl       # Build script
│   └── IP/               # Generated IP cores
├── KiCad/                 # PCB design files
├── Docs/                  # Documentation
├── .vscode/               # VSCode configuration
│   ├── tasks.json        # Build/test tasks
│   ├── settings.json     # Editor settings
│   └── launch.json       # Debug configurations
└── .devcontainer/         # Dev Container config
```

## Development Workflow

### Typical Development Cycle

1. **Edit RTL** - Modify Verilog files in `RTL/`
2. **Run Tests** - Execute `Run Testbench` task to verify changes
3. **View Waveforms** - Open VCD files from `sim_build/` to debug
4. **Build Firmware** - Run `Build Firmware` task to compile for FPGA
5. **Commit Changes** - Use git to track your work

### Running Specific Tests

To run a specific test file or test function:

```bash
# Run all tests in a specific file
docker run --rm -v ${pwd}:/test -w /test -it mbtaylor1982/cocotb-iverilog:latest pytest RTL/cocotb/FIFO/test_fifo.py -v

# Run a specific test function
docker run --rm -v ${pwd}:/test -w /test -it mbtaylor1982/cocotb-iverilog:latest pytest RTL/cocotb/test_resdmac.py::test_name -v
```

### Viewing Waveforms

After running tests, VCD files are generated in `sim_build/`. You can view them using:

1. **Surfer** extension in VSCode
2. **GTKWave** (external tool)
3. **Waveform Render** extension for inline rendering

## Troubleshooting

### Docker Issues

**"Cannot connect to Docker daemon"**
- Ensure Docker Desktop is running
- On Windows, check that WSL2 is properly configured

**"Image not found"**
- Pull the required images manually (see Docker Images section)

**Permission denied on Linux**
- Add your user to the docker group: `sudo usermod -aG docker $USER`
- Log out and back in for changes to take effect

### Build Issues

**Quartus errors about missing files**
- Run the `Clean` task first
- Ensure all git submodules are initialized (if any)

**Tests failing with import errors**
- Verify you're using the correct Docker image
- Check that the volume mounts are correct for your OS

### VSCode Issues

**Linting not working**
- Ensure the `mshr-h.veriloghdl` extension is installed
- Check that iverilog is configured in settings (handled by the project's `.vscode/settings.json`)

## Additional Resources

- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) - Architecture and codebase overview
- [SDMAC.md](SDMAC.md) - SDMAC technical specification
- [TIMING_CONSTRAINTS.md](TIMING_CONSTRAINTS.md) - FPGA timing constraints
- [100MHz_Clock_Conversion_Guide.md](100MHz_Clock_Conversion_Guide.md) - Clock conversion details

## CI/CD Pipeline

The project uses GitHub Actions for automated builds and tests:

- **test.yml** - Runs cocotb tests on push/PR to main
- **build.yml** - Manual workflow dispatch for firmware builds
- **build_on_push.yml** - Quick validation on push
- **kicad.yml** - KiCad output generation
- **release.yml** - Release artifact creation

See `.github/workflows/` for workflow definitions.
