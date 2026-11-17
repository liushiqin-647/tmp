#!/usr/bin/env python3
"""按脚本里的 # [n] 顺序逐条执行轨迹命令，保存每条的输出、退出码和耗时。"""
import argparse
import re
import subprocess
import sys
import time
from pathlib import Path


def parse_steps(path):
    text = Path(path).read_text(encoding="utf-8")
    parts = re.split(r"(?m)^# \[(\d+)\]\s*$", text)
    steps = []
    for i in range(1, len(parts), 2):
        body = parts[i + 1].strip("\n")
        if body.strip():
            steps.append((int(parts[i]), body))
    return steps


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("script")
    ap.add_argument("--workdir", default=".", help="命令执行目录，默认当前目录")
    ap.add_argument("--out", help="输出目录，默认 ~/tmp/trajectory-runs/<脚本名>")
    ap.add_argument("--start", type=int, default=0)
    ap.add_argument("--end", type=int, default=0)
    ap.add_argument("--timeout", type=float, default=0, help="单条超时秒数，0 表示不限")
    a = ap.parse_args()

    steps = [
        (n, b)
        for n, b in parse_steps(a.script)
        if (not a.start or n >= a.start) and (not a.end or n <= a.end)
    ]
    outdir = Path(a.out) if a.out else Path.home() / "tmp" / "trajectory-runs" / Path(a.script).stem
    (outdir / "steps").mkdir(parents=True, exist_ok=True)
    rows = ["step\trc\tms\tcommand"]
    total = 0

    for n, body in steps:
        first = body.splitlines()[0][:100]
        print(f"\n=== [{n}] {first}", flush=True)
        t0 = time.monotonic()
        try:
            r = subprocess.run(
                ["bash", "-c", body], cwd=a.workdir,
                capture_output=True, text=True, timeout=a.timeout or None,
            )
            out, err, rc = r.stdout, r.stderr, r.returncode
        except subprocess.TimeoutExpired as e:
            out = e.stdout.decode() if isinstance(e.stdout, bytes) else (e.stdout or "")
            err = e.stderr.decode() if isinstance(e.stderr, bytes) else (e.stderr or "")
            rc = 124
        ms = int((time.monotonic() - t0) * 1000)
        total += ms
        if out:
            print(out, end="" if out.endswith("\n") else "\n")
        if err:
            print(err, end="", file=sys.stderr)
        print(f"<<< rc={rc} 用时 {ms}ms", flush=True)
        (outdir / "steps" / f"step-{n:03d}.log").write_text(
            f"$ {body}\n--- stdout ---\n{out}\n--- stderr ---\n{err}\n--- rc={rc} ms={ms}\n",
            encoding="utf-8",
        )
        rows.append(f"{n}\t{rc}\t{ms}\t{first}")

    (outdir / "summary.tsv").write_text("\n".join(rows) + f"\nTOTAL\t\t{total}\t\n", encoding="utf-8")
    print(f"\n完成 {len(steps)} 条，总耗时 {total}ms\n日志: {outdir}")


if __name__ == "__main__":
    main()
