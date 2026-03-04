#dataset merging and processing

#lib
library(readxl)
library(tidyverse)

#read import and exports
e_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Exports")
i_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Imports")

#read port coords
portcord <- read_excel("data/portcoords.xlsx")
portcord$`Schedule K Code` <- as.numeric(portcord$`Schedule K Code`)
 
#join data
test <- inner_join(portcord, e_2023, join_by("Schedule K Code" == "FORPORT"), relationship = "many-to-many")

write.csv(portcord, file="data/ports.csv")
