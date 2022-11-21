library(tidyverse)
library(auk)

# WI Snowy Owls
f_in <- "data/ebd_snoowl1_relSep-2022.txt"

# output text file
f_out <- "data/snowys.txt"

ebird_data <- f_in |> 
  # 1. reference file
  auk_ebd() |> 
  # 2. define filters
  auk_species(species = "Snowy Owl") |> 
  auk_country(country = "US") |> 
  # 3. run filtering
  auk_filter(file = f_out, overwrite = TRUE) |> 
  # 4. read text file into r data frame
  read_ebd()

# WI Common Loons
loon_in <- "data/ebd_US-WI_comloo_relOct-2021.txt"
# output text file
loon_out <- "data/loons_wi.txt"

ebird_data <- loon_in |> 
  # 1. reference file
  auk_ebd() |> 
  # 2. define filters
  auk_species(species = "Common Loon") |> 
  auk_country(country = "US") |> 
  # 3. run filtering
  auk_filter(file = loon_out, overwrite = TRUE) |> 
  # 4. read text file into r data frame
  read_ebd()

# WI Common Loons
loon_in <- "data/ebd_US-MI_snoowl1_relOct-2021.txt"
# output text file
loon_out <- "data/snowys_mi.txt"

ebird_data <- loon_in |> 
  # 1. reference file
  auk_ebd() |> 
  # 2. define filters
  auk_species(species = "Snowy Owl") |> 
  auk_country(country = "US") |> 
  # 3. run filtering
  auk_filter(file = loon_out, overwrite = TRUE) |> 
  # 4. read text file into r data frame
  read_ebd()
