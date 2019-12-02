import sys
import os
import pystar
import re
import collections
import pandas as pd
import argparse

def read_particles_to_keep(csv_file):
    df = pd.read_csv(csv_file)

    return(df['Particle'].tolist())

def star_to_filtered_pd(star_file, particle_csv):

    star_data = pystar.load(star_file)['']
    fields = list(star_data)[0]

    rows_list = []
    for pt in list(star_data.values())[0]:
        single_row = collections.OrderedDict()
        single_row.update(
            graph_name = pt[0],
            x = pt[1],
            y = pt[2],
            image_name = pt[3],
            defocus_u = pt[4],
            defocus_v = pt[5],
            defocus_angle = pt[6],
            phase_shift = pt[7],
            voltage = pt[8],
            spherical_abberation = pt[9],
            amplitude_contrast = pt[10],
            magnification = pt[11],
            detector_pixel_size = pt[12],
            angle_rot = pt[13],
            angle_tilt = pt[14],
            angle_psi = pt[15],
            origin_x = pt[16],
            origin_y = pt[17],
        )
        rows_list.append(single_row)

    to_return = pd.DataFrame(rows_list)

    particle_list = read_particles_to_keep(particle_csv)
    particle_row_indeces = [x - 1 for x in particle_list]

    return to_return.iloc[particle_row_indeces,]

def pd_to_star(filtered_df, outfile):
    with open(outfile, 'w') as out:
        out.write('''
data_

loop_
_rlnMicrographName #1
_rlnCoordinateX #2
_rlnCoordinateY #3
_rlnImageName #4
_rlnDefocusU #5
_rlnDefocusV #6
_rlnDefocusAngle #7
_rlnPhaseShift #8
_rlnVoltage #9
_rlnSphericalAberration #10
_rlnAmplitudeContrast #11
_rlnMagnification #12
_rlnDetectorPixelSize #13
_rlnAngleRot #14
_rlnAngleTilt #15
_rlnAnglePsi #16
_rlnOriginX #17
_rlnOriginY #18
''')

    filtered_df.to_csv(outfile, sep = ' ', header = False, index = False, mode = 'a')

def main():
    parser = argparse.ArgumentParser(description = 'Output a star file of your selected class')
    parser.add_argument('input_star', help = 'star file generated from cisTEM (same stack as par files)')
    parser.add_argument('selected_particles', help = 'csv file of the particles you selected, from R')
    parser.add_argument('output_star', help = 'Where to save the resultant star file')

    args = parser.parse_args()
    input_star = args.input_star
    output_star = args.output_star
    particles = args.selected_particles

    filtered_df = star_to_filtered_pd(input_star, particles)
    pd_to_star(filtered_df, output_star)

if __name__ == '__main__':
    main()
