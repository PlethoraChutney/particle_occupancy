import sys
import glob
import os
import re
import numpy as np
import pandas as pd
import pystar2
import argparse


def star_to_pd(star_dir):
    stars = []
    for file in os.listdir(star_dir):
        if file.endswith(".star"):
            stars.append(os.path.join(star_dir, file))

    rows_list = []
    for star in stars:
        star_data = pystar2.load(star)['']
        fields = list(star_data)[0]

        index_x = fields.index('rlnCoordinateX')
        index_y = fields.index('rlnCoordinateY')
        index_image = fields.index('rlnImageName')
        index_class = fields.index('rlnClassNumber')

        for pick in list(star_data.values())[0]:
            single_row = {}
            single_row.update(
                star = star,
                x = pick[index_x],
                y = pick[index_y],
                cls = pick[index_class],
                image = pick[index_image]
            )
            rows_list.append(single_row)

    to_return = pd.DataFrame(rows_list)
    return(to_return)

def main():
    parser = argparse.ArgumentParser(description = 'Convert star file into csv')
    parser.add_argument('star_dir', help = 'Directory containing your star files')
    parser.add_argument('-o', '--output', help = 'Path for output .csv file', default = '.')

    args = parser.parse_args()
    star_dir = args.star_dir
    out = os.path.abspath(args.output)

    if os.path.isfile(star_dir) and star_dir[-5:] == '.star':
        print('You gave a star file, not the containing directory.\nUsing the directory containing that star file')
        star_dir = os.path.dirname(star_dir)

    if not out[-4:] == '.csv':
        outdir = out
        outfile = os.path.join(out, 'converted_star.csv')
    else:
        outdir = os.path.dirname(out)
        outfile = out

    star_to_pd(star_dir).to_csv(outfile, index = False)

if __name__ == '__main__':
    main()
