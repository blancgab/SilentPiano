## Silent Piano - CSV Note Reader
#  Code Gen for MATLAB validation array
#  Gabriel Blanco, May 9th 2015

from collections import defaultdict
import csv

csv_name = 'notes.csv'

nmap = {'a': 9, 'c': 0, 'ab': 8, 'e': 4, 'd': 2, 'g': 7, 'f': 5, 'c#': 1, 'db': 1, 
        'd#': 3, 'bb': 12, 'f#': 6, 'g#': 8, 'gb': 6, 'a#': 10, 'b': 11}

def str2notenumber(str):

    if len(str) == 2:
        pitch = str[0].lower()
    elif len(str) == 3:
        pitch = str[0:2].lower()
    else:
        return -1

    pnum = nmap[pitch]
    octave = int(str[-1]) + 1

    return pnum + 12*octave


def pressOrRelease(str):

    if str.lower() == 'press':
        return 0
    if str.lower() == 'release':
        return 1
    else:
        return -1

if __name__ == "__main__":
    nmap = defaultdict(lambda: -1, nmap)

    with open(csv_name, 'rb') as csvfile:
        notesreader = csv.reader(csvfile, delimiter=',', quotechar='|')

        pv = 'x'
        count = 1

        for row in notesreader:

            if row[2] == pv:
                count = count + 1
            else:
                count = 1

            print "C({},:,{}) = [{} {}];".format(row[2], count, str2notenumber(row[0]), pressOrRelease(row[1]))

            pv = row[2]
