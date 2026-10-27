import matplotlib
matplotlib.use("Agg")

import matplotlib.pyplot as plt
from bisect import bisect_right

# Ma dinh danh tin hieu trong file tb.vcd
signals = {
    "$": "clk",
    "&": "rst_n",
    "%": "ena",
    "(": "uio_in",
    "0": "mode",
    "1": "enable",
    "4": "state",
    "#": "uo_out",
}

events = {code: [] for code in signals}
time = 0

# Doc file VCD
with open("tb.vcd", "r") as f:
    for line in f:
        line = line.strip()

        if line.startswith("#"):
            time = int(line[1:])

        elif line.startswith("b"):
            parts = line.split()
            if len(parts) == 2:
                value, code = parts
                if code in events:
                    events[code].append((time, value[1:]))

        elif len(line) >= 2 and line[0] in "01xXzZ":
            code = line[1:]
            if code in events:
                events[code].append((time, line[0]))

# Ve tat ca tin hieu
fig, axes = plt.subplots(
    len(signals), 1,
    figsize=(16, 11),
    sharex=True
)

for ax, (code, name) in zip(axes, signals.items()):
    data = events[code]

    if not data:
        continue

    times = [t / 1000 for t, v in data]  # ps -> ns
    values = []

    for t, v in data:
        try:
            values.append(int(v, 2))
        except ValueError:
            values.append(0)

    if name in ("clk", "rst_n", "ena", "mode", "enable"):
        ax.step(times, values, where="post", linewidth=1.5)
        ax.set_ylim(-0.3, 1.3)
        ax.set_yticks([0, 1])
    else:
        ax.step(times, values, where="post", linewidth=1.5)
        ax.set_ylabel(name, rotation=0, labelpad=45)

    ax.set_title(name, loc="left", fontsize=10)
    ax.grid(True, alpha=0.3)

axes[-1].set_xlabel("Time (ns)")
fig.suptitle("D04 - Ring / Johnson Counter Simulation Waveform")
plt.tight_layout()
plt.savefig("waveform.png", dpi=200)
print("Da tao file waveform.png")
