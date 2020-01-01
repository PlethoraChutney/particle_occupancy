import os
import sys
import pandas as pd
import argparse

# 1 Data I/O -------------------------------------------------------------------

# we drop the last two rows because they're cisTEM diagnostics
def read_par(file):
    par_file = pd.read_csv(file, sep = r"\s+")
    par_file.drop(par_file.tail(2).index, inplace = True)
    return par_file

def read_all_par(directory, list_of_files):
    pars_to_read = []
    for file in list_of_files:
        fullpath = os.path.abspath(os.path.join(directory, file))
        pars_to_read.append(read_par(fullpath))
    return pars_to_read

# 2 Find per-particle class ----------------------------------------------------

def process_pars(directory, run_numbers):
    all_pars = [x for x in os.listdir(directory) if x.endswith('.par')]

    separated_pars = {}
    for run in run_numbers:
        one_run = [x for x in all_pars if str(run) in x]
        separated_pars[run] = one_run

    full_tables = {}
    for run in separated_pars.keys():
        table = read_all_par(directory, separated_pars[run])
        full_tables[run] = table

    dfs = {}
    for run in full_tables.keys():
        columns = {}
        for i in range(len(full_tables[run])):
            columns[f'C{i+1}'] = full_tables[run][i]['OCC']
        dfs[run] = pd.DataFrame.from_dict(columns)

    return dfs

def write_dataframes(dfs, outdir, alpha_number, gamma_number):
    outdir = os.path.abspath(outdir)
    for key in dfs.keys():
        if key == alpha_number:
            subunit = 'alpha'
        elif key == gamma_number:
            subunit = 'gamma'
        else:
            subunit = 'unknown'
        outpath = os.path.join(outdir, f'{subunit}_occupancies.csv')
        dfs[key].to_csv(outpath)

# 3 Main -----------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description = 'Collect occupancy values from par files')
    parser.add_argument('in_dir', metavar = 'par-files-dir', help = 'Directory containing all par files')
    parser.add_argument('alpha_number', metavar = 'alpha-number', help = 'cisTEM run number for the alpha focused classification')
    parser.add_argument('gamma_number', metavar = 'gamma-number', help = 'cisTEM run number for the gamma focused classification')
    parser.add_argument('-o', '--out-dir', default = os.getcwd(), help = 'Where to save csv files. Default current dir')

    args = parser.parse_args()
    run_numbers = [args.alpha_number, args.gamma_number]
    in_dir = args.in_dir
    out_dir = args.out_dir

    par_dfs = process_pars(in_dir, run_numbers)
    write_dataframes(par_dfs, out_dir, args.alpha_number, args.gamma_number)

if __name__ == '__main__':
    main()
