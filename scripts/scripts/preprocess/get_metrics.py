#!/usr/bin/python3
import sys

if len(sys.argv) != 3:
    exit(f'Needs file and architecture!\npython3 get_metrics.py i7-ES-ALL Xeon\n{sys.argv}')

fname = sys.argv[1]

def main():
    pstr = sys.argv[2] + ','
    columns = []
    wantedA = ['Wall Time (Actual Time)',
        'classifications correct (percent)',
        'Precision (percent)',
        'Recall (percent)' ]
    wantedB = ['evaluation time (cpu seconds)',
        'classifications correct (percent)',
        'Precision (percent)',
        'Recall (percent)' ]
    spname = fname.split('/')[-1].split('-')
    spline = []
    for s in spname[1:]:
        pstr += s + ','
    with open (fname) as f:
        # size = -1
        got_wanted = False
        for line in f:
            if 'learning evaluation instances' in line and not got_wanted:
                spline = line.split(',')
                # size = len(spline)
                wanted = []
                wanted = wantedA if 'Wall Time (Actual Time)' in spline else wantedB
                for s in spline:
                    if s in wanted:
                        columns.append(spline.index(s))
                got_wanted = True
            else:
                spline = line.split(',')
#                 break
                # if len(spline) == size:
                    # for c in columns:
                    #     pstr += spline[c] + ','
        for c in columns:
            pstr += spline[c] + ','
        print (pstr[:-1])

if __name__ == '__main__':
    main()
