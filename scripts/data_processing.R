#dataset merging and processing

#lib
library(readxl)
library(tidyverse)



#-------categorize goods------------#
#Industrial
Ind_list <- c("All Manufactured Equipment, Machinery and Products",
                     "Primary Non-Ferrous Metal Products;Fabricated Metal Prods.",
                     "Fertilizers",
                     "Other Chemicals and Related Products",
                    "Building Cement & Concrete; Lime; Glass",
              "Primary Iron and Steel Products (Ingots,Bars,Rods,etc.)",
              "Slag")
#Agricultural
Ag_list <- c(
  "Animal Feed, Grain Mill Products, Flour, Processed Grains",
  "Vegetable Products",
  "Corn",
  "Oilseeds (Soybean, Flaxseed and Others)",
  "Wheat",
  "Other Agricultural Products; Food and Kindred Products",
  "Barley, Rye, Oats, Rice and Sorghum Grains"
  
  
)
#Coal, Oil, and Petrochemicals
Petro_list <- c(
  "Coal,Lignite & Coal Coke",
  "Petroleum Pitches, Coke, Asphalt, Naptha and Solvents",
  "Distillate,Residual & Other Fuel Oils; Lube Oil & Greases",
  "Petroleum Products NEC",
  "Gasoline, Jet Fuel, Kerosene",
  "Crude Petroleum"
)
#Rock and Minerals
Mineral_list <- c(
  "Sulphur (Dry), Clay & Salt",
  "Other Non-Metal. Min.",
  "Iron Ore and Iron & Steel Waste & Scrap",
  "Sand, Gravel, Stone, Rock, Limestone, Soil, Dredged Material",
  "Non-Ferrous Ores and Scrap")

#Timber and Timber Products
Timber_list <- c(
  "Forest Products, Lumber, Logs, Woodchips",
  "Pulp and Waste Paper",
  "Paper & Allied Products",
  "Primary Wood Products; Veneer; Plywood" 
)

#fish list
Fish_list <- c(
  "Fish",
  "Marine Shells" 
)
#Other
GoodCatagorize <- function(good) {
  
  for (i in 1:length(good)) {
    if (good[i] %in% Ind_list){
      "Industrial goods"
    }
    else if (good[i] %in% Ag_list) {
      "Agricultural goods"
    }
    else if (good[i] %in% Petro_list){
      "#Coal, Oil, and Petrochemicals"
    }
    else if (good[i] %in% Mineral_list){
      "Ore, Rock and Minerals"
    }
    else if (good[i] %in% Timber_list){
      "Wood and Wood Products"
    }
    else if (good[i] %in% Fish_list) {
      "Fish and Marine Goods"
    }
    else{
      "Other goods"
    }
  }

}

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
  dplyr::select(c("FORPORT","Foreign Port Name", "Country Name", "Latitude", "Longitude"))%>%
  mutate(FORPORT = as.numeric(FORPORT)) %>% drop_na()#%>%
#distinct(FORPORT, .keep_all = TRUE)

##############################################################################
ProcessData <- function(dataset_name) {
dataset_address <- paste0("data/",dataset_name,".xlsx")
i_dataset <- read_excel(dataset_address, sheet = 1) %>% 
    dplyr::select(!c("WTWY","WTWY_NAME")) %>%
    mutate(PORT = as.numeric(PORT)) %>%
    group_by(PORT, FORPORT,PMS_NAME) %>%
    mutate(TONNAGE = sum(TONNAGE)) %>%
    base::unique() %>%
    ungroup() %>%
    mutate(Good_Category = case_when(
      PMS_NAME %in% Ind_list ~ "Industrial goods",
      PMS_NAME %in% Ag_list ~ "Agricultural goods",
      PMS_NAME %in% Petro_list ~ "Coal, Oil, and Petrochemicals",
      PMS_NAME %in% Mineral_list ~"Ore, Rock and Minerals",
      PMS_NAME %in% Timber_list ~ "Wood and Wood Products",
      PMS_NAME %in% Fish_list ~ "Fish and Marine Goods",
      TRUE ~ "Other Goods"
    ))

e_dataset <- read_excel(dataset_address, sheet = 2) %>% 
  dplyr::select(!c("WTWY","WTWY_NAME")) %>%
  mutate(PORT = as.numeric(PORT)) %>%
  group_by(PORT, FORPORT,PMS_NAME) %>%
  mutate(TONNAGE = sum(TONNAGE)) %>%
  base::unique() %>%
  ungroup() %>%
  mutate(Good_Category = case_when(
    PMS_NAME %in% Ind_list ~ "Industrial goods",
    PMS_NAME %in% Ag_list ~ "Agricultural goods",
    PMS_NAME %in% Petro_list ~ "Coal, Oil, and Petrochemicals",
    PMS_NAME %in% Mineral_list ~"Ore, Rock and Minerals",
    PMS_NAME %in% Timber_list ~ "Wood and Wood Products",
    PMS_NAME %in% Fish_list ~ "Fish and Marine Goods",
    TRUE ~ "Other Goods"
  ))

i_dataset <- 
  merge(i_dataset,domestic_ports) %>%
  rename(
    Dom_Lat =  LATITUDE,
    Dom_Lon = LONGITUDE
  ) %>%
  merge(foreign_ports, by.x = "FORPORT_NAME", by.y = "Foreign Port Name") %>%
  rename(
    For_Lat = Latitude,
    For_Lon = Longitude
  )

e_dataset <- merge(e_dataset,domestic_ports) %>%
  rename(
    Dom_Lat =  LATITUDE,
    Dom_Lon = LONGITUDE
  ) %>%
  merge(foreign_ports, by.x = "FORPORT_NAME", by.y = "Foreign Port Name") %>%
  rename(
    For_Lat = Latitude,
    For_Lon = Longitude
  )

#######write data
#imports
write.csv(i_dataset, file=paste0("data/","i_",i_dataset$YEAR[1],"_merged.csv"))
#exports
write.csv(e_dataset, file=paste0("data/","e_",e_dataset$YEAR[1],"_merged.csv"))
}
ProcessData("Imports_Exports_2020")
##############################################################################

#read import and exports

e_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = 1) %>% 
  dplyr::select(!c("WTWY","WTWY_NAME")) %>%
  mutate(PORT = as.numeric(PORT)) %>%
  group_by(PORT, FORPORT,PMS_NAME) %>%
  mutate(TONNAGE = sum(TONNAGE)) %>%
  base::unique() %>%
  ungroup() %>%
  mutate(Good_Category = case_when(
    PMS_NAME %in% Ind_list ~ "Industrial goods",
    PMS_NAME %in% Ag_list ~ "Agricultural goods",
    PMS_NAME %in% Petro_list ~ "Coal, Oil, and Petrochemicals",
    PMS_NAME %in% Mineral_list ~"Ore, Rock and Minerals",
    PMS_NAME %in% Timber_list ~ "Wood and Wood Products",
    PMS_NAME %in% Fish_list ~ "Fish and Marine Goods",
    TRUE ~ "Other Goods"
  ))

i_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Imports") %>% 
  dplyr::select(!c("WTWY","WTWY_NAME")) %>%
  mutate(PORT = as.numeric(PORT)) %>%
  group_by(PORT, FORPORT,PMS_NAME) %>%
  mutate(TONNAGE = sum(TONNAGE)) %>%
  base::unique() %>%
  ungroup() %>%
  mutate(Good_Category = case_when(
    PMS_NAME %in% Ind_list ~ "Industrial goods",
    PMS_NAME %in% Ag_list ~ "Agricultural goods",
    PMS_NAME %in% Petro_list ~ "Coal, Oil, and Petrochemicals",
    PMS_NAME %in% Mineral_list ~"Ore, Rock and Minerals",
    PMS_NAME %in% Timber_list ~ "Wood and Wood Products",
    PMS_NAME %in% Fish_list ~ "Fish and Marine Goods",
    TRUE ~ "Other Goods"
  ))





#join data

e_2023_merged <- merge(e_2023,domestic_ports) %>%
  rename(
   Dom_Lat =  LATITUDE,
  Dom_Lon = LONGITUDE
  ) %>%
  merge(foreign_ports, by.x = "FORPORT_NAME", by.y = "Foreign Port Name") %>%
  rename(
    For_Lat = Latitude,
    For_Lon = Longitude
  )

i_2023_merged <- merge(i_2023[],domestic_ports) %>%
  rename(
    Dom_Lat =  LATITUDE,
    Dom_Lon = LONGITUDE
  ) %>%
  merge(foreign_ports, by.x = "FORPORT_NAME", by.y = "Foreign Port Name") %>%
  rename(
    For_Lat = Latitude,
    For_Lon = Longitude
  )


#write data
write.csv(e_2023_merged, file="data/e_2023_merged.csv")
write.csv(i_2023_merged, file="data/i_2023_merged.csv")

#create country list
write.csv(unique(test$CTRY_F_NAME), file = "data/country_list.csv")


