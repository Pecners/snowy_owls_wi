library(tidyverse)
library(tigris)
library(sf)
library(showtext)

font_add_google("Kaushan Script", "ks")

showtext_auto()

wi <- counties(state = "WI") %>%
  st_transform(., crs = st_crs(4326))

l <- rnaturalearth::ne_download(type = "lakes", category = "physical", scale = "large")  %>%
  st_as_sf(., crs = st_crs(4326))

gl <- l %>% 
  filter(name %in% c("Lake Michigan", "Lake Superior")) %>%
  st_union()

wi_trim <- st_difference(wi, gl)

ebird_data %>%
  filter(lubridate::year(observation_date) == 2020) %>%
  group_by(county) %>%
  tally() %>%
  ungroup() %>%
  arrange(desc(n)) %>%
  right_join(., wi_trim, by = c("county" = "NAME")) %>%
  st_as_sf() %>%
  ggplot(aes(fill = n)) +
  geom_sf(color = "white", size = .1) +
  theme_void() +
  theme(legend.position = "none")

ebird_data %>%
  filter(lubridate::year(observation_date) == 2020) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = st_crs(4326)) %>%
  ggplot() +
  geom_sf(data= wi_trim, color = "white", size = .1) +
  geom_sf(alpha = .25) +
  theme_void() +
  theme(legend.position = "none",
        text = element_text(family = "ks"),
        plot.title.position = "plot",
        plot.title = element_text(size = 18, hjust = .5)) + 
  labs(title = "Snowy Owl Sightings in 2020")
