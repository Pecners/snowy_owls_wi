library(tidyverse)
library(auk)
# path to the ebird data file, here a sample included in the package
# get the path to the example data included in the package
# in practice, provide path to ebd, e.g. f_in <- "data/ebd_relFeb-2018.txt
f_in <- "data/ebd_US-WI_snoowl1_relOct-2021.txt"
# output text file
f_out <- "data/snowys.txt"

ebird_data <- f_in %>% 
  # 1. reference file
  auk_ebd() %>% 
  # 2. define filters
  auk_species(species = "Snowy Owl") %>% 
  auk_country(country = "US") %>% 
  # 3. run filtering
  auk_filter(file = f_out, overwrite = TRUE) %>% 
  # 4. read text file into r data frame
  read_ebd()
