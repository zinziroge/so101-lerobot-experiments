"""Stack top/wrist rollout videos side by side with instruction, camera labels,
episode numbers and per-episode SUCCESS/FAIL annotations.

Requires ffmpeg on PATH and pandas. The font path assumes Windows (Arial Bold).

Usage:
    python make_rollout_video.py <dataset_root> <out.mp4> --success 0 2

    dataset_root: a LeRobot dataset recorded by lerobot-rollout, e.g.
        ~/.cache/huggingface/lerobot/zinziroge/rollout_smolvla_blue_small_last_20261020_174609
    --success:    indices of successful episodes (0-based); all others are marked FAIL
"""

import argparse
import glob
import os
import subprocess
import tempfile

import pandas as pd

FONT = "C\\:/Windows/Fonts/arialbd.ttf"
BANNER_H = 64


def esc(text: str) -> str:
    """Escape text for an ffmpeg drawtext value inside single quotes."""
    return text.replace("\\", "\\\\").replace("'", "\\'").replace(":", "\\:").replace("%", "\\%")


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("root", help="LeRobot dataset folder")
    p.add_argument("out", help="output mp4")
    p.add_argument("--success", type=int, nargs="*", default=[], help="successful episode indices")
    args = p.parse_args()

    ep = pd.concat(pd.read_parquet(f) for f in glob.glob(os.path.join(args.root, "meta", "episodes", "*", "*.parquet")))
    ep = ep.sort_values("episode_index")
    task = ep["tasks"].iloc[0][0]
    n = len(ep)

    top = glob.glob(os.path.join(args.root, "videos", "observation.images.top", "*", "*.mp4"))[0]
    wrist = glob.glob(os.path.join(args.root, "videos", "observation.images.wrist", "*", "*.mp4"))[0]

    common = f"fontfile='{FONT}'"
    draws = [
        # camera labels (inside each panel, below the banner)
        f"drawtext={common}:text='top':fontsize=22:fontcolor=white:box=1:boxcolor=black@0.55:boxborderw=6:x=12:y={BANNER_H + 12}",
        f"drawtext={common}:text='wrist':fontsize=22:fontcolor=white:box=1:boxcolor=black@0.55:boxborderw=6:x=640+12:y={BANNER_H + 12}",
        # instruction
        f"drawtext={common}:text='\"{esc(task)}\"':fontsize=26:fontcolor=white:x=16:y=(({BANNER_H}-text_h)/2)",
    ]
    for _, row in ep.iterrows():
        i = int(row["episode_index"])
        t0 = float(row["videos/observation.images.top/from_timestamp"])
        t1 = float(row["videos/observation.images.top/to_timestamp"])
        ok = i in args.success
        result, color = ("SUCCESS", "0x33dd55") if ok else ("FAIL", "0xff4444")
        enable = f"enable='between(t,{t0:.3f},{t1 - 0.001:.3f})'"
        draws.append(
            f"drawtext={common}:text='Episode {i}':fontsize=26:fontcolor=white:"
            f"x=w-text_w-180:y=(({BANNER_H}-text_h)/2):{enable}"
        )
        draws.append(
            f"drawtext={common}:text='{result}':fontsize=30:fontcolor={color}:"
            f"x=w-text_w-24:y=(({BANNER_H}-text_h)/2):{enable}"
        )

    graph = (
        "[0:v][1:v]hstack=inputs=2[s];"
        f"[s]pad=iw:ih+{BANNER_H}:0:{BANNER_H}:color=0x202020[p];"
        "[p]" + ",".join(draws) + "[v]"
    )

    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False, encoding="utf-8") as f:
        f.write(graph)
        script = f.name
    try:
        subprocess.run(
            ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", top, "-i", wrist,
             "-/filter_complex", script, "-map", "[v]",
             "-c:v", "libx264", "-crf", "20", "-preset", "medium", "-pix_fmt", "yuv420p",
             "-movflags", "+faststart", args.out],
            check=True,
        )
    finally:
        os.remove(script)
    print(f"wrote {args.out}: {n} episodes, task='{task}', success={args.success}")


if __name__ == "__main__":
    main()
