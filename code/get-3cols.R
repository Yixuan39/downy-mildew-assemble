# this script convert the fasta file to a database file

library(data.table)
library(tidyverse)
library(here)
df <- fread(here('all.seq_info.tsv.gz'))

three.col <- df[,1] %>% 
  mutate(col2 = '.') %>%
  mutate(col3 = '.')

fwrite(three.col, here('3cols.txt'), sep = '\t', col.names = FALSE, row.names = FALSE)
