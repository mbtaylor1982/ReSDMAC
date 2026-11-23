import unittest
from package_candidate import updater_crc, validate_identity


class PackageContract(unittest.TestCase):
    def test_updater_crc_vectors(self):
        self.assertEqual(updater_crc(b""), 0)
        self.assertEqual(updater_crc(b"123456789"), 0x89A1897F)
        self.assertEqual(updater_crc(bytes(128)), 0)

    def test_hardware_version_cannot_be_truncated(self):
        validate_identity("v1.2", "stable-update-rc1")
        for version in ("v1.2-rc1", "v0.10", "1.2", ""):
            with self.assertRaises(ValueError):
                validate_identity(version, "candidate")

    def test_candidate_cannot_escape_output_paths(self):
        for candidate in ("../release", "branch/name", "name with spaces", ""):
            with self.assertRaises(ValueError):
                validate_identity("v1.2", candidate)


if __name__ == "__main__":
    unittest.main()
