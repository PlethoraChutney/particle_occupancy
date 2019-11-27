library(tidyverse)
library(ggplot2)
library(treemapify)

#### Data import and cleaning ####

alpha.occupancies <- read_csv('173_occupancies.csv') %>% 
  select('Particle' = X1, everything()) %>% 
  mutate(Particle = Particle + 1)

gamma.occupancies <- read_csv('510_occupancies.csv') %>% 
  select('Particle' = X1, everything()) %>% 
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

#### Class assignment and Plot ####
# this is where you tell the script which classes are cleaved and which are uncleaved
cleave.assigned <- merged.assigned %>% 
  mutate(alpha_cleaved = if_else(Alpha_Class %in% c('C1', 'C4'), 'Cleaved', 
                                 if_else(Alpha_Class %in% c('C3'), 'Uncleaved', 'Unknown'))) %>% 
  mutate(gamma_cleaved = if_else(Gamma_Class == 'C1', 'Cleaved',
                                 if_else(Gamma_Class == 'C2', 'Uncleaved', 'Unknown'))) %>% 
  select(Particle, alpha_cleaved, gamma_cleaved) %>% 
  arrange(Particle)

cleave.classified <- cleave.assigned %>% 
  mutate(State = if_else(alpha_cleaved == 'Uncleaved' & gamma_cleaved == 'Uncleaved', 'Both Uncleaved',
                         if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Cleaved', 'Both Cleaved',
                                 if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Uncleaved', 'Alpha Cleaved, Gamma Uncleaved',
                                         if_else(gamma_cleaved == 'Cleaved' & alpha_cleaved == 'Uncleaved', 'Gamma Cleaved, Alpha Uncleaved',
                                                 if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Unknown', 'Alpha Cleaved, Gamma Unknown',
                                                         if_else(gamma_cleaved == 'Cleaved' & alpha_cleaved == 'Unknown', 'Gamma Cleaved, Alpha Unknown',
                                                                 if_else(alpha_cleaved == 'Uncleaved' & gamma_cleaved == 'Unknown', 'Alpha Uncleaved, Gamma Unknown',
                                                                         if_else(gamma_cleaved == 'Uncleaved' & alpha_cleaved == 'Unknown', 'Gamma Uncleaved, Alpha Unknown',
                                                                                 if_else(alpha_cleaved == 'Unknown' & gamma_cleaved == 'Unknown', 'Both Unknown', 'MISCLASSIFICATION!'))))))))))
  



cleave.classified %>% 
  group_by(State) %>% 
  summarize(n = n()) %>% 
  mutate(label = paste(State, '\n', n)) %>% 
  ggplot() +
  geom_treemap(aes(area = n, fill = State, color = State)) +
  geom_treemap_text(aes(area = n, label = n), color = 'white', place = 'center') +
  scale_fill_manual(values = c('#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf'),
                    aesthetics = c('color', 'fill'))
ggsave('particle_cleavage.pdf', width = 8, height = 5)

#### Make new par file(s) ####
original.par.file <- read_table2('par_files/output_par_173_1.par')

particles.to.select <- cleave.classified %>% 
  filter(State == 'Both Uncleaved') %>% 
  select(Particle)

new.par.file <- original.par.file %>% 
  mutate(OCC = if_else(C %in% particles.to.select$Particle, 100, 0)) %>% 
  mutate(INCLUDE = if_else(C %in% particles.to.select$Particle, 1, 0)) %>% 
  drop_na()

write_delim(new.par.file, path = 'both_uncleaved.par', delim = ' ')
