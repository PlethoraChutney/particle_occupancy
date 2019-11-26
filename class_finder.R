library(tidyverse)
library(ggplot2)

files_list <- c('test_files/output_par_173_1.par', 'test_files/output_par_173_2.par', 'test_files/output_par_173_3.par',
                'test_files/output_par_173_4.par', 'test_files/output_par_173_5.par')

tables_list <- lapply(files_list, read_table2)
tables_list <- lapply(tables_list, function(x) select(x, C, OCC))

merge_full <- Reduce(
  function(x, y) full_join(x, y, by = 'C'),
  tables_list
)
