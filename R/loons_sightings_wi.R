library(tidyverse)
library(tigris)
library(sf)
library(showtext)
library(tidycensus)

ebird_data <- read_ebd("data/loons_wi.txt")

`%+%` <- function(x, y) paste0(x,y)

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

# Get census data

pop <- get_decennial(geography = "county",
                     state = "WI",
                     variables = "P1_001N", 
                     year = 2020) %>%
  mutate(county = str_remove_all(NAME, " County, Wisconsin$"))

# Adjust to group by sighting by day

top10 <- ebird_data %>%
  filter(lubridate::year(observation_date) == 2020) %>%
  group_by(county) %>%
  summarise(count = sum(as.numeric(observation_count))) %>%
  ungroup() %>%
  left_join(., pop) %>%
  mutate(n = count / value * 100000) %>%
  arrange(desc(n)) %>%
  head(10)

top10 %>%
  ggplot(aes(reorder(county, n), n)) +
  geom_segment(aes(x = reorder(county, n), xend = reorder(county, n),
                   y = 0, yend = n),
               linetype = 2, size = 1) +
  geom_point(size = 8, color = "red") +
  #geom_text(aes(label = n), color = "white") +
  coord_flip() +
  theme_minimal() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_text(color = "red", size = 14),
        text = element_text(family = "ks"),
        plot.title.position = "plot",
        plot.caption.position = "plot",
        plot.caption = element_text(hjust = 0, size = 12, lineheight = 1.25),
        plot.title = element_text(size = 16),
        plot.subtitle = element_text(size = 14)) + 
  labs(x = "", y = "",
       caption = "Sightings are per 100,000 residents.\n" %+%
         "Graph by Spencer Schien (@MrPecners) | Data from eBird Basic Dataset",
       title = "Wisconsin counties with the most snowy owl sightings in 2020",
       subtitle = "Portage and Douglas counties outstrip the rest")

# ggsave("graphics/top_10_counties.jpeg", device = "jpeg")


ebird_data %>%
  filter(lubridate::year(observation_date) == 2020) %>%
  group_by(locality, latitude, longitude) %>%
  summarise(n = sum(as.numeric(observation_count))) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = st_crs(4326)) %>%
  ggplot() +
  geom_sf(data= wi_trim, color = "white", size = .1, fill = "grey75") +
  geom_sf(data = wi_trim %>% filter(NAME %in% top10$county),
          color = "red", size = .5, fill = NA) +
  geom_sf(aes(size = n), alpha = .25, color = "red") +
  theme_void() +
  theme(legend.position = "bottom",
        text = element_text(family = "ks"),
        plot.title.position = "plot",
        plot.title = element_text(size = 22, hjust = 1, margin = margin(t = 10, b = -40)),
        plot.subtitle = element_text(size = 16, hjust = 1, margin = margin(t = 45, b = -30)),
        plot.caption.position = "plot",
        plot.caption = element_text(hjust = .5, margin = margin(t = 10, b = 5),
                                    size = 12, lineheight = 1.25)) + 
  labs(title = "Where to see common loons in Wisconsin",
       subtitle = "2020 top ten counties in red",
       size = "Locality Total 2020 Sightings",
       caption = "Top counties determined by sightings per 100,000 residents.\n" %+%
         "Graph by Spencer Schien (@MrPecners) | Data from eBird Basic Dataset")

# ggsave("graphics/loon_sightings_map_2020.jpeg", device = "jpeg")
