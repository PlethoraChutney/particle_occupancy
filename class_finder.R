library(tidyverse)
library(ggplot2)
library(treemapify)

alpha.occupancies <- read_csv('173_occupancies.csv') %>% 
  select('Particle' = X1, C1 = `1`, C2 = `2`, C3= `3`, C4 = `4`, C5 = `5`) %>% 
  mutate(Particle = Particle + 1)

gamma.occupancies <- read_csv('377_occupancies.csv') %>% 
  select('Particle' = X1, C1 = `1`, C2 = `2`, C3= `3`, C4 = `4`, C5 = `5`) %>% 
  mutate(Particle = Particle + 1)

alpha.assigned <- alpha.occupancies %>% 
  gather(key = Alpha_Class, value = Occupancy, -Particle) %>% 
  group_by(Particle) %>% 
  filter(Occupancy == max(Occupancy)) %>% 
  select(-Occupancy) %>% 
  ungroup()

gamma.assigned <- gamma.occupancies %>% 
  gather(key = Gamma_Class, value = Occupancy, -Particle) %>% 
  group_by(Particle) %>% 
  filter(Occupancy == max(Occupancy)) %>% 
  select(-Occupancy) %>% 
  ungroup()

merged.assigned <- full_join(alpha.assigned, gamma.assigned, by = 'Particle')

# this is where you tell the script which classes are cleaved and which are uncleaved
cleave.assigned <- merged.assigned %>% 
  mutate(alpha_cleaved = if_else(Alpha_Class %in% c('C1', 'C4'), 'Cleaved', 
                                 if_else(Alpha_Class %in% c('C3'), 'Uncleaved', 'Unknown'))) %>% 
  mutate(gamma_cleaved = if_else(Gamma_Class == 'C1', 'Cleaved',
                                 if_else(Gamma_Class == 'C2', 'Uncleaved', 'Unknown'))) %>% 
  select(Particle, alpha_cleaved, gamma_cleaved) %>% 
  arrange(Particle)

cleave.classified <- cleave.assigned %>% 
  mutate(State = if_else(alpha_cleaved == 'Uncleaved' & gamma_cleaved == 'Uncleaved', 'Fully Uncleaved',
                         if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Cleaved', 'Fully Cleaved',
                                 if_else(alpha_cleaved == 'Cleaved' & (gamma_cleaved != 'Cleaved'), 'Alpha Cleaved',
                                         if_else(gamma_cleaved == 'Cleaved' & (alpha_cleaved != 'Cleaved'), 'Gamma Cleaved',
                                                 if_else(alpha_cleaved == 'Uncleaved' & gamma_cleaved != 'Uncleaved', 'Alpha Uncleaved',
                                                         if_else(gamma_cleaved == 'Uncleaved' & alpha_cleaved != 'Uncleaved', 'Gamma Uncleaved',
                                                                 if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Uncleaved', 'Alpha Cleaved, Gamma Uncleaved',
                                                                         if_else(gamma_cleaved == 'Cleaved' & alpha_cleaved == 'Uncleaved', 'Gamma Cleaved, Alpha Uncleaved', 'Unknown')))))))))
  



cleave.classified %>% 
  group_by(State) %>% 
  summarize(n = n()) %>% 
  ggplot() +
  geom_treemap(aes(area = n, color = State, fill = State)) +
  geom_treemap_text(aes(area = n, label = n), color = 'white', place = 'center') +
  scale_fill_manual(values = c('#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2'),
                    aesthetics = c('color', 'fill'))
  
