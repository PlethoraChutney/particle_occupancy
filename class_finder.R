library(tidyverse)
library(ggplot2)
library(treemapify)
library(ggupset)
library(UpSetR)
library(RColorBrewer)

#### Hardcoding ####
alpha.cleaved.list <- c('C1', 'C4')
alpha.uncleaved.list <- c('C3')
gamma.cleaved.list <- c('C1')
gamma.cleaved.list <- c('C2')

#### Data import and cleaning ####

alpha.occupancies <- read_csv('alpha_occupancies.csv') %>% 
  select('Particle' = X1, everything()) %>% 
  mutate(Particle = Particle + 1)

gamma.occupancies <- read_csv('gamma_occupancies.csv') %>% 
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

#### Class Assignment ####

cleave.assigned <- merged.assigned %>% 
  mutate(alpha_cleaved = if_else(Alpha_Class %in% alpha.cleaved.list, 'Cleaved', 
                                 if_else(Alpha_Class %in% alpha.uncleaved.list, 'Uncleaved', 'Undefined'))) %>% 
  mutate(gamma_cleaved = if_else(Gamma_Class %in% gamma.cleaved.list, 'Cleaved',
                                 if_else(Gamma_Class %in% gamma.uncleaved.list, 'Uncleaved', 'Undefined'))) %>% 
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


#### Treemap Plots ####
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

# uncleaved only
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

#### Upset Plots ####
upset.data <- cleave.assigned %>%  
  rename(Alpha = 'alpha_cleaved', Gamma = 'gamma_cleaved') %>% 
  mutate(Alpha = paste('Alpha', Alpha), Gamma = paste('Gamma', Gamma)) %>% 
  mutate(State = str_extract_all(paste(Alpha, Gamma, sep = " "), "^Alpha .*ed(?= )|Gamma .*ed$")) %>% 
  mutate(Merged_State = paste(Alpha, Gamma, sep = ' '))

# upsetr way (more informative but busier)
upsetr.data <- upset.data %>% 
  select(Particle, ms = Merged_State) %>% 
  mutate(Alpha_Cleaved = if_else(str_detect(ms, 'Alpha Cleaved'), 1, 0),
         Alpha_Uncleaved = if_else(str_detect(ms, 'Alpha Uncleaved'), 1, 0),
         Alpha_Undefined = if_else(str_detect(ms, 'Alpha Undefined'), 1, 0),
         Gamma_Cleaved = if_else(str_detect(ms, 'Gamma Cleaved'), 1, 0),
         Gamma_Uncleaved = if_else(str_detect(ms, 'Gamma Uncleaved'), 1, 0),
         Gamma_Undefined = if_else(str_detect(ms, 'Gamma Undefined'), 1, 0)
  ) %>% 
  select(-ms) %>% 
  as.data.frame()

pdf('upsetr_plot.pdf', width = 6, height = 6)
upset(upsetr.data,
      sets = c('Gamma_Cleaved', 'Gamma_Undefined', 'Gamma_Uncleaved', 'Alpha_Cleaved', 'Alpha_Undefined', 'Alpha_Uncleaved'),
      keep.order = TRUE,
      line.size = NA,
      mainbar.y.label = 'Number of Particles',
      sets.x.label = 'Number of Particles',
      set_size.scale_max = 300000,
      set_size.show = TRUE,
      main.bar.color = brewer.pal(9, 'Paired')
      )
dev.off()

# ggplot way (prettier)
pdf('upset_plot.pdf', width = 6, height = 6)
upset.data %>% 
  ggplot(aes(x = State, fill = Merged_State, color = Merged_State)) +
  theme_minimal() +
  geom_bar() +
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
  aesthetics = c('color', 'fill')) +
  theme(legend.position = 'none') +
  ylab('Number of Particles') +
  xlab('Cleavage State') +
  scale_x_upset() +
  scale_y_continuous(breaks = seq(from = 0, to = 100000, by = 5000)) +
  axis_combmatrix(levels = c('Alpha Uncleaved', 'Alpha Undefined', 'Alpha Cleaved', 'Gamma Uncleaved', 'Gamma Undefined', 'Gamma Cleaved')) +
  theme_combmatrix(combmatrix.panel.line.size = 0)
dev.off()

#### CSV Files for Stars ####
particles.to.select <- cleave.classified %>% 
  filter(State == 'Both Uncleaved') %>% 
  select(Particle)

write_csv(particles.to.select, 'uncleaved_particles.csv')

particles.to.select <- cleave.classified %>% 
  filter(State == 'Both Cleaved') %>% 
  select(Particle)

write_csv(particles.to.select, 'cleaved_particles.csv')
