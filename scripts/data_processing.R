#dataset merging and processing

#lib
library(readxl)
library(tidyverse)

#read import and exports
e_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Exports") %>% 
  select(!c("WTWY","WTWY_NAME")) %>%
  mutate(PORT = as.numeric(PORT)) %>%
  group_by(PORT, FORPORT,PMS_NAME) %>%
  mutate(TONNAGE = sum(TONNAGE)) %>%
  unique() %>%
  ungroup()

i_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Imports") %>% select(!c("WTWY","WTWY_NAME"))

#read port coords
#process domestic ports
domestic_ports <- read_excel("data/domestic_ports.xlsx")
domestic_ports <- domestic_ports %>% 
  filter(FAC_TYPE == "Dock") %>%
  select(c("LATITUDE", "LONGITUDE", "PORT", "PORT_NAME")) %>% 
  drop_na() %>% 
  unique() %>%
  group_by(PORT, PORT_NAME) %>%
  mutate(LATITUDE = mean(LATITUDE))%>%
  mutate(LONGITUDE = mean(LONGITUDE)) %>%
  ungroup()%>%
  unique()
#process foreign ports
foreign_ports <- read_excel("data/foreign_ports.xlsx") %>%
  rename(
    FORPORT = 'Schedule K Code'
  )

#join data

test <- inner_join(e_2023,domestic_ports) %>%
  rename(
   Domestic_Lat =  LATITUDE,
  Domestic_Lon = LONGITUDE
  ) %>%
  left_join(e_2023, foreign_ports, by = "FORPORT") %>%
  rename(
    For_Lat =  LATITUDE,
    For_Lon = LONGITUDE
  )

write.csv(portcord, file="data/ports.csv")
