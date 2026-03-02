#dataset merging and processing

#lib
library(readxl)

#read import and exports
e_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Exports")
i_2023 <- read_excel("data/Imports_Exports_2023.xlsx", sheet = "Imports")

#read port coords
portcord <- read_excel("data/portcoords.xlsx")
