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
    FORPORT = 'Schedule K Code',
    FORPORT_NAME = 'Foreign Port Name',
    CTRY_F_NAME = 'Country Name'
  ) %>%
  dplyr::select(c("FORPORT","FORPORT_NAME", "CTRY_F_NAME", "Latitude", "Longitude")) %>%
  mutate(FORPORT = as.numeric(FORPORT)) %>% 
  drop_na() %>%
  mutate(Port_Country = paste(FORPORT_NAME, CTRY_F_NAME))
#distinct(FORPORT, .keep_all = TRUE)

##############################################################################


ProcessData <- function(dataset_name, export_sheet, import_sheet) {
dataset_address <- paste0("data/",dataset_name,".xlsx")
i_dataset <- read_excel(dataset_address, sheet = import_sheet) %>% 
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
    )) %>%
  mutate(Port_Country = paste(FORPORT_NAME, CTRY_F_NAME))

e_dataset <- read_excel(dataset_address, sheet = export_sheet) %>% 
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
  )) %>%
  mutate(Port_Country = paste(FORPORT_NAME, CTRY_F_NAME))

i_dataset <- merge(i_dataset, domestic_ports) %>%
  rename(
    Dom_Lat =  LATITUDE,
    Dom_Lon = LONGITUDE
  ) 

  i_dataset <- merge(i_dataset, foreign_ports, by = "Port_Country", all = FALSE) %>%
  rename(
    For_Lat = Latitude,
    For_Lon = Longitude
  ) %>% rename(
    FORPORT = "FORPORT.x",
    FORPORT_NAME = "FORPORT_NAME.x",
    CTRY_F_NAME = "CTRY_F_NAME.x"
  )
  

write.csv(i_dataset, file=paste0("data/","i_",i_dataset$YEAR[1],"_merged.csv"))

e_dataset <- merge(e_dataset,domestic_ports, all = FALSE) %>%
  rename(
    Dom_Lat =  LATITUDE,
    Dom_Lon = LONGITUDE
  )

e_dataset <- merge(e_dataset, foreign_ports, by = "Port_Country", all = FALSE) %>%
  rename(
    For_Lat = Latitude,
    For_Lon = Longitude
  ) %>% rename(
    FORPORT = "FORPORT.x",
    FORPORT_NAME = "FORPORT_NAME.x",
    CTRY_F_NAME = "CTRY_F_NAME.x"
  )

write.csv(e_dataset, file=paste0("data/","e_",e_dataset$YEAR[1],"_merged.csv"))
#######write data
#imports

#exports

}

##############################################################################
ProcessData("Imports_Exports_2023", 1, 2)
ProcessData("Imports_Exports_2022", 2, 1)
ProcessData("Imports_Exports_2021", 2, 1)

ProcessData("Exports_Imports_2019",2,1)

ProcessData("Exports_Import_2018",1,2)
ProcessData("Exports_Imports_2017",1,2)

ProcessData("Imports_Exports_2016",2,1)
ProcessData("Imports_Exports_2015", 3, 2)
ProcessData("Imports_Exports_2014", 2, 1)
ProcessData("Imports_Exports_2013", 1, 2)
ProcessData("Imports_Exports_2012", 1, 2)
