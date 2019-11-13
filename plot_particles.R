library(ggplot2)
library(tidyverse)

args = commandArgs(trailingOnly = TRUE)

raw.data <- read_csv(args[1])

split.data <- raw.data %>% 
  group_split(star)

multi_join <- function(list_of_loaded_data, join_func, ...){
  
  output <- Reduce(function(x, y) {join_func(x, y, ...)}, list_of_loaded_data)
  
  return(output)
}