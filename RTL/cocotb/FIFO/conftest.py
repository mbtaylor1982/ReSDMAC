"""Pytest conftest for FIFO tests.

Collects per-test results and generates a Markdown report at the end of the
session, written to  test_results/FIFO/report.md .
"""

import os
import pytest
from datetime import datetime, timezone

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
RESULTS_DIR = os.path.join(PROJECT_ROOT, "test_results", "FIFO")

# Accumulate results across the session
_results = []


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    """Capture the outcome of each test call phase."""
    outcome = yield
    report = outcome.get_result()
    if report.when == "call":
        # Extract the cocotb testcase name from parametrize id
        testcase = None
        if hasattr(item, "callspec") and "testcase" in item.callspec.params:
            testcase = item.callspec.params["testcase"]
        else:
            testcase = item.name

        _results.append({
            "testcase": testcase,
            "passed": report.passed,
            "duration": report.duration,
            "longrepr": str(report.longrepr) if report.longrepr else "",
        })


def pytest_sessionfinish(session, exitstatus):
    """Write the Markdown test report after all tests have run."""
    if not _results:
        return

    os.makedirs(RESULTS_DIR, exist_ok=True)
    report_path = os.path.join(RESULTS_DIR, "report.md")

    total = len(_results)
    passed = sum(1 for r in _results if r["passed"])
    failed = total - passed
    status = "PASSED" if failed == 0 else "FAILED"
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    lines = []
    lines.append("# FIFO Test Report")
    lines.append("")
    lines.append(f"**Date:** {timestamp}  ")
    lines.append(f"**Status:** {status}  ")
    lines.append(f"**Tests:** {passed}/{total} passed, {failed} failed  ")
    lines.append("")
    lines.append("## Results")
    lines.append("")
    lines.append("| Test | Status | Duration | VCD |")
    lines.append("|------|--------|----------|-----|")

    for r in _results:
        name = r["testcase"]
        stat = "PASS" if r["passed"] else "FAIL"
        dur = f"{r['duration']:.2f}s"
        vcd_file = f"{name}.vcd"
        vcd_exists = os.path.isfile(os.path.join(RESULTS_DIR, vcd_file))
        vcd_link = f"[{vcd_file}]({vcd_file})" if vcd_exists else "n/a"
        lines.append(f"| {name} | {stat} | {dur} | {vcd_link} |")

    # Append failure details if any
    failures = [r for r in _results if not r["passed"]]
    if failures:
        lines.append("")
        lines.append("## Failures")
        lines.append("")
        for r in failures:
            lines.append(f"### {r['testcase']}")
            lines.append("")
            lines.append("```")
            lines.append(r["longrepr"])
            lines.append("```")
            lines.append("")

    lines.append("")

    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
