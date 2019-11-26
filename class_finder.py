import os
import sys
import pandas as pd
import argparse

def read_par(file):
    par_file = pd.read_csv(file, sep = r"\s+")
    return par_file

def read_all_par(directory, list_of_files):
    pars_to_read = []
    for file in list_of_files:
        fullpath = os.path.abspath(os.path.join(directory, file))
        pars_to_read.append(read_par(fullpath))
    return pars_to_read

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
            columns[i+1] = full_tables[run][i]['OCC']
        dfs[run] = pd.DataFrame.from_dict(columns)

    return dfs

def write_dataframes(dfs, outdir):
    outdir = os.path.abspath(outdir)
    for key in dfs.keys():
        outpath = os.path.join(outdir, f'{key}_occupancies.csv')
        dfs[key].to_csv(outpath)

def main():
    parser = argparse.ArgumentParser(description = 'Collect occupancy values from par files')
    parser.add_argument('run_numbers', metavar='run-numbers', nargs='*', help = 'The numbers cisTEM put in your different runs')
    parser.add_argument('in_dir', metavar='par-files-dir', help = 'Directory containing all par files')
    parser.add_argument('-o', '--out-dir', default = os.getcwd(), help = 'Where to save csv files. Default current dir')

    args = parser.parse_args()
    run_numbers = args.run_numbers
    in_dir = args.in_dir
    out_dir = args.out_dir

    par_dfs = process_pars(in_dir, run_numbers)
    write_dataframes(par_dfs, out_dir)

if __name__ == '__main__':
    main()
