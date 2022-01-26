from datetime import datetime, timedelta

# Using readlines()
wm = open('results/socket/1200/1200/Wm-1200.log', 'r')
Lines = wm.readlines()

UltimaHoraOk = '2022/01/15 19:12:26'
count = 0

current_line = Lines[0].split(',')
date_separated = current_line[0].split('/')
date = '20' + date_separated[2] + '/' + date_separated[1] + '/' + date_separated[0] + ' ' + current_line[1]

f = '%Y/%m/%d %H:%M:%S'
f2 = '%d/%m/%y,%H:%M:%S'

date_line = datetime.strptime(date, f)
dif = (datetime.strptime(UltimaHoraOk, f) - date_line).total_seconds()

new_date_line = date_line + timedelta(seconds=dif)

with open("results/socket/1200/1200/Wm-1200.log") as fp:
    while True:
        count += 1
        line = fp.readline()

        current_line_write = line.split(',')
 
        if not line:
            break
        
        if count == 1:
            continue

        new_date_line = new_date_line + timedelta(seconds=0.5)
        print(new_date_line.strftime(f2) + "," + current_line_write[2].replace("\n", ""))
