#dataset merging and processing

#lib
library(readxl)
library(tidyverse)

#read import and exports
e_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Exports") %>% 
  dplyr::select(!c("WTWY","WTWY_NAME")) %>%
  mutate(PORT = as.numeric(PORT)) %>%
  group_by(PORT, FORPORT,PMS_NAME) %>%
  mutate(TONNAGE = sum(TONNAGE)) %>%
  base::unique() %>%
  ungroup()

i_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Imports") %>% dplyr::select(!c("WTWY","WTWY_NAME"))

#read port coords
#process domestic ports
domestic_ports <- read_excel("data/domestic_ports.xlsx")
domestic_ports <- domestic_ports %>% 
  filter(FAC_TYPE == "Dock") %>%
  dplyr::select(c("LATITUDE", "LONGITUDE", "PORT", "PORT_NAME")) %>% 
  drop_na() %>% 
  base::unique() %>%
  group_by(PORT, PORT_NAME) %>%
  mutate(LATITUDE = mean(LATITUDE))%>%
  mutate(LONGITUDE = mean(LONGITUDE)) %>%
  ungroup()%>%
  base::unique()
#process foreign ports
foreign_ports <- read_excel("data/foreign_ports.xlsx") %>%
  rename(
    FORPORT = 'Schedule K Code'
  ) %>%
  dplyr::select(c("FORPORT","Foreign Port Name", "Latitude", "Longitude"))%>%
  mutate(FORPORT = as.numeric(FORPORT))

#join data

test <- merge(e_2023[],domestic_ports) %>%
  rename(
   Dom_Lat =  LATITUDE,
  Dom_Lon = LONGITUDE
  ) %>%
  merge(foreign_ports, by.x = "FORPORT", by.y = "FORPORT") %>%
  rename(
    For_Lat = Latitude,
    For_Lon = Longitude
  )

write.csv(test, file="data/e_2023_merged.csv")
