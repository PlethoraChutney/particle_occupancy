import sys
import os
import pystar
import re
import collections
import pandas as pd

def star_to_pd(star_file):

    star_data = pystar.load(star_file)['']
    fields = list(star_data)[0]
    #
    # index_graph_name = fields.index('rlnMicrographName')
    # index_x = fields.index('rlnCoordinateX')
    # index_y = fields.index('rlnCoordinateY')
    # index_image_name = fields.index('rlnImageName')
    # index_defocus_u = fields.index('rlnDefocusU')
    # index_defocus_v = fields.index('rlnDefocusV')
    # index_defocus_angle = fields.index('rlnDefocusAngle')
    # index_phase_shift = fields.index('rlnPhaseShift')
    # index_voltage = fields.index('rlnVoltage')
    # index_spherical_abberation = fields.index('rlnSphericalAbberation')
    # index_amplitude_contrast = fields.index('rlnAmplitudeContrast')
    # index_magnification = fields.index('rlnMagnification')
    # index_detector_pixel_size = fields.index('rlnDetectorPixelSize')
    # index_angle_rot = fields.index('rlnAngleRot')
    # index_angle_tilt = fields.index('rlnAngleTilt')
    # index_angle_psi = fields.index('rlnAnglePsi')
    # index_origin_x = fields.index('rlnOriginX')
    # index_origin_y = fields.index('rlnOriginY')

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
    return(to_return)
