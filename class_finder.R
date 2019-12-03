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
                                 if_else(Alpha_Class %in% c('C3'), 'Uncleaved', 'Undefined'))) %>% 
  mutate(gamma_cleaved = if_else(Gamma_Class == 'C1', 'Cleaved',
                                 if_else(Gamma_Class == 'C2', 'Uncleaved', 'Undefined'))) %>% 
  select(Particle, alpha_cleaved, gamma_cleaved) %>% 
  arrange(Particle)

cleave.classified <- cleave.assigned %>% 
  mutate(State = if_else(alpha_cleaved == 'Uncleaved' & gamma_cleaved == 'Uncleaved', 'Both Uncleaved',
                         if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Cleaved', 'Both Cleaved',
                                 if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Uncleaved', 'Alpha Cleaved, Gamma Uncleaved',
                                         if_else(gamma_cleaved == 'Cleaved' & alpha_cleaved == 'Uncleaved', 'Gamma Cleaved, Alpha Uncleaved',
                                                 if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Undefined', 'Alpha Cleaved, Gamma Undefined',
                                                         if_else(gamma_cleaved == 'Cleaved' & alpha_cleaved == 'Undefined', 'Gamma Cleaved, Alpha Undefined',
                                                                 if_else(alpha_cleaved == 'Uncleaved' & gamma_cleaved == 'Undefined', 'Alpha Uncleaved, Gamma Undefined',
                                                                         if_else(gamma_cleaved == 'Uncleaved' & alpha_cleaved == 'Undefined', 'Gamma Uncleaved, Alpha Undefined',
                                                                                 if_else(alpha_cleaved == 'Undefined' & gamma_cleaved == 'Undefined', 'Both Undefined', 'MISCLASSIFICATION!'))))))))))

simple.analysis <- cleave.assigned %>% 
  mutate(Alpha_State = if_else(alpha_cleaved == 'Uncleaved' & gamma_cleaved == 'Uncleaved', 'Both Uncleaved',
                               if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Cleaved', 'Both Cleaved',
                                       if_else(alpha_cleaved == 'Cleaved', 'Alpha Cleaved',
                                               if_else(alpha_cleaved == 'Uncleaved', 'Alpha Uncleaved',
                                                       if_else(alpha_cleaved == 'Undefined', 'Undefined', 'MISCLASSIFICATION!')))))) %>% 
  mutate(Gamma_State = if_else(alpha_cleaved == 'Uncleaved' & gamma_cleaved == 'Uncleaved', 'Both Uncleaved',
                               if_else(alpha_cleaved == 'Cleaved' & gamma_cleaved == 'Cleaved', 'Both Cleaved',
                                       if_else(gamma_cleaved == 'Cleaved', 'Gamma Cleaved',
                                               if_else(gamma_cleaved == 'Uncleaved', 'Gamma Uncleaved', 
                                                       if_else(gamma_cleaved == 'Undefined', 'Undefined', 'MISCLASSIFICATION')))))) %>% 
  select(Particle, Alpha_State, Gamma_State)

# most informative plot
cleave.classified %>% 
  group_by(State) %>% 
  summarize(n = n()) %>% 
  mutate(label = paste(State, '\n', format(n, big.mark = ','))) %>% 
  mutate(label = str_replace(label, ', ', '\n')) %>% 
  mutate(known = if_else(str_detect(State, 'Alpha Cleaved'), 'Alpha',  
                         if_else(str_detect(State, 'Gamma Cleaved'), 'Gamma', State))) %>% 
  ggplot() +
  geom_treemap(aes(area = n, fill = known, subgroup = known), color = 'white') +
  geom_treemap_text(aes(area = n, label = label, subgroup = known), color = 'white', place = 'center') +
  theme(legend.position = 'none') +
  scale_fill_manual(values = c('#1f77b4', # blue
                               '#2ca02c', # green
                               '#d62728', # red
                               '#9467bd', # purple
                               '#17becf', # cyan
                               '#ff7f0e', # orange
                               '#e377c2', # pink
                               '#7f7f7f', # grey
                               '#bcbd22', # yellow-green
                               '#8c564b'  # brown
                               ),
                    aesthetics = c('color', 'fill'))
ggsave('particle_cleavage.pdf', width = 8, height = 8)

# cleaved only
cleave.classified %>% 
  filter(str_detect(State, 'Cleaved')) %>% 
  mutate(State = if_else(str_detect(State, 'Alpha Cleaved'), 'Alpha Cleaved',
                         if_else(str_detect(State, 'Gamma Cleaved'), 'Gamma Cleaved', State))) %>% 
  group_by(State) %>% 
  summarize(n = n()) %>% 
  mutate(label = paste(State, '\n', format(n, big.mark = ','))) %>% 
  mutate(label = str_replace(label, ', ', '\n')) %>% 
  mutate(known = if_else(str_detect(State, 'Alpha Cleaved'), 'Alpha',  
                         if_else(str_detect(State, 'Gamma Cleaved'), 'Gamma', State))) %>% 
  ggplot() +
  ggtitle(paste('Only particles with at least one cleaved subunit; total', format(nrow(filter(cleave.classified, str_detect(State, 'Cleaved'))), big.mark = ','))) +
  geom_treemap(aes(area = n, fill = known, subgroup = known), color = 'white') +
  geom_treemap_text(aes(area = n, label = label, subgroup = known), color = 'white', place = 'center') +
  theme(legend.position = 'none') +
  scale_fill_manual(values = c('#1f77b4', # blue
                               '#2ca02c', # green
                               '#d62728', # red
                               '#9467bd', # purple
                               '#17becf', # cyan
                               '#ff7f0e', # orange
                               '#e377c2', # pink
                               '#7f7f7f', # grey
                               '#bcbd22', # yellow-green
                               '#8c564b'  # brown
  ),
  aesthetics = c('color', 'fill'))
ggsave('cleaved_only.pdf', width = 8, height = 8)

# uncleaved.only
cleave.classified %>% 
  filter(str_detect(State, 'Uncleaved')) %>% 
  mutate(State = if_else(str_detect(State, 'Alpha Uncleaved'), 'Alpha Uncleaved',
                         if_else(str_detect(State, 'Gamma Uncleaved'), 'Gamma Uncleaved', State))) %>% 
  group_by(State) %>% 
  summarize(n = n()) %>% 
  mutate(label = paste(State, '\n', format(n, big.mark = ','))) %>% 
  mutate(label = str_replace(label, ', ', '\n')) %>% 
  mutate(known = if_else(str_detect(State, 'Alpha Uncleaved'), 'Alpha',  
                         if_else(str_detect(State, 'Gamma Uncleaved'), 'Gamma', State))) %>% 
  ggplot() +
  ggtitle(paste('Only particles with at least one uncleaved subunit; total', format(nrow(filter(cleave.classified, str_detect(State, 'Uncleaved'))), big.mark = ','))) +
  geom_treemap(aes(area = n, fill = known, subgroup = known), color = 'white') +
  geom_treemap_text(aes(area = n, label = label, subgroup = known), color = 'white', place = 'center') +
  theme(legend.position = 'none') +
  scale_fill_manual(values = c('#1f77b4', # blue
                               '#2ca02c', # green
                               '#d62728', # red
                               '#9467bd', # purple
                               '#17becf', # cyan
                               '#ff7f0e', # orange
                               '#e377c2', # pink
                               '#7f7f7f', # grey
                               '#bcbd22', # yellow-green
                               '#8c564b'  # brown
  ),
  aesthetics = c('color', 'fill'))
ggsave('uncleaved_only.pdf', width = 8, height = 8)

simpler.classified %>% 
  group_by(State) %>% 
  summarize(n = n()) %>% 
  mutate(label = paste(State, '\n', n)) %>% 
  mutate(label = str_replace(label, ', ', '\n')) %>% 
  mutate(known = if_else(str_detect(State, 'Alpha Cleaved'), 'Alpha',  
                         if_else(str_detect(State, 'Gamma Cleaved'), 'Gamma', State))) %>% 
  ggplot() +
  geom_treemap(aes(area = n, fill = known, subgroup = known), color = 'white') +
  geom_treemap_text(aes(area = n, label = label, subgroup = known), color = 'white', place = 'center') +
  theme(legend.position = 'none') +
  scale_fill_manual(values = c('#1f77b4', # blue
                               '#2ca02c', # green
                               '#d62728', # red
                               '#9467bd', # purple
                               '#17becf', # cyan
                               '#ff7f0e', # orange
                               '#e377c2', # pink
                               '#7f7f7f', # grey
                               '#bcbd22', # yellow-green
                               '#8c564b'  # brown
  ),
  aesthetics = c('color', 'fill'))
ggsave('simple_particle_cleavage_alternate.pdf', width = 8, height = 8)


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

#### Make csv files of particle numbers ####
particles.to.select <- cleave.classified %>% 
  filter(State == 'Both Uncleaved') %>% 
  select(Particle)

write_csv(particles.to.select, 'uncleaved_particles.csv')

particles.to.select <- cleave.classified %>% 
  filter(State == 'Both Cleaved') %>% 
  select(Particle)

write_csv(particles.to.select, 'cleaved_particles.csv')
