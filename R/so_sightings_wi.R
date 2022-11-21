library(tidyverse)
library(tigris)
library(sf)
library(showtext)
library(tidycensus)

ebird_data <- read_ebd("data/snowys.txt")


font_add_google("Kaushan Script", "ks")

showtext_auto()

skip <- c(
  "American Samoa",
  "Commonwealth of the Northern Mariana Islands",
  "Puerto Rico",
  "United States Virgin Islands"
)

s <- states()

l <- rnaturalearth::ne_download(type = "lakes", category = "physical", scale = "large")  %>%
  st_as_sf()

gl <- l %>% 
  filter(name %in% c("Lake Michigan", 
                     "Lake Superior",
                     "Lake Huron",
                     "Lake Ontario",
                     "Lake Erie")) %>%
  st_union() |> 
  st_transform(crs = 5070) |> 
  st_union()

s_trim <- s |> 
  st_transform(crs = 5070) |> 
  filter(!NAME %in% skip) |> 
  st_difference(gl)


sf_birds <- ebird_data |> 
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) |> 
  st_transform(crs = 5070) 

wi <- sf_birds |> 
  filter(state == "Wisconsin") 

gridded <- st_make_grid(wi, square = FALSE, cellsize = 5000) 

joined <- as_tibble(gridded[wi]) |> 
  mutate(ind = row_number()) |> 
  st_as_sf() |> 
  st_join(wi |> 
            filter(state == "Wisconsin"))
  
jj <- left_join(joined, joined |> 
              as_tibble() |> 
              group_by(ind) |> 
              summarise(n = sum(as.numeric(observation_count), na.rm = TRUE)) |> 
              arrange(desc(n)))


  
jj |> 
  ggplot(aes(fill = n)) +
  geom_sf(size = .1)  +
  coord_sf(crs = 3071) +
  theme_void()

