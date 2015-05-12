## Silent Piano - CSV Note Reader
#  Code Gen for MATLAB validation array
#  Gabriel Blanco, May 9th 2015

from collections import defaultdict
import csv

csv_name = 'midigen.csv'
framerate = 29.9932;

nmap = {'c'  : 0,
        'c#' : 1,
        'db' : 1,
        'd'  : 2,
        'd#' : 3,
        'eb' : 3,
        'e'  : 4,
        'f'  : 5,
        'f#' : 6,
        'gb' : 6,
        'g'  : 7,
        'g#' : 8,
        'ab' : 8,
        'a'  : 9,
        'a#' : 10,
        'bb' : 10,
        'b'  : 11}


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

        for index, row in enumerate(notesreader):

            # M: input matrix:
            #   1     2     3     4     5     6
            # [ track chan  nn    vel   t1    t2 ] (any more cols ignored...)

            t1 = float(row[1])/framerate
            t2 = float(row[2])/framerate

            print "C({},:) = [1 1 {} 80 {} {}];".format(index+1, str2notenumber(row[0]), t1, t2)
