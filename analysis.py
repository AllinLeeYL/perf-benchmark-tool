import sys
import numpy as np

def parsefile():
    with open("/home/liyilin/perf-benchmark-tool/compare.csv", "r") as f:
        raw = f.readlines()
    data = []
    i=0
    while i < len(raw):
        names = raw[i]
        i = i + 1
        counts = []
        while raw[i] != '---\n':
            counts.append(raw[i])
            i = i + 1
        i = i + 1
        data.append({"names":names, "counts":counts})
    return data

def analysis(fl_rate):
    data = parsefile()
    # Preprocess
    for i, group in enumerate(data):
        names = group['names'].split(',')
        counts = []
        for gstr in group['counts']:
            glist = gstr.split(',')[:-1]
            for j in range(0, len(glist)):
                if glist[j] == '<not':
                    glist[j] = -1
                else:
                    glist[j] = float(glist[j])
            counts.append(glist)
        counts = np.array(counts)
        # Calculate: Please modify the code here
        for j, name in enumerate(names):
            fluctrate = max(counts.T[j]) - min(counts.T[j])
            if counts.T[j][0] == 0:
                flct_rate = 1 if fluctrate > 10 else 0
            else:
                flct_rate = fluctrate / counts.T[j][0]
            if flct_rate > fl_rate or name == 'branch-instructions':
                print(name, counts.T[j])


if __name__ == "__main__":
    analysis(float(sys.argv[1]))