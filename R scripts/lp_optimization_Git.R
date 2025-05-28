
# This code creates the linear programming based optimization model to prioritize parks implementation

library(lpSolve)
library(readxl)
library(writexl)
library(ggplot2)
library(viridis)
library(scales)
library(corrplot)
library(sf)
library(dplyr)
library(geobr)
library(gridExtra)

choose.files()


  
# Reading file containing parks (shp or gpkg)
  
parques <- read_sf("dados/parques_São_Paulo_4.0.gpkg")
  
 
{

# Defining problem parameters
  
# Constraints
  
total_budget <- 750000000        # user defined 
min_num <- 1                     # user defined

# Number of parks

num_parques <- nrow(parques)

# Cost Matrix

cost <- parques$Costs

# Objective function coefficients (in this example we are maximizing benefit-cost)

obj_coef <- (parques$CRP_norm + parques$WPP_norm + parques$RCP_norm) / parques$Cost_nor_1  # define your objective function here

# Probleman direction

direction <- "max"              # change for different directions here

# Cost constraint
A <- matrix(cost, nrow = 1)
dir <- "<="                    
rhs <- total_budget

# Number of parks constraint
B <- matrix(rep(1, num_parques), nrow = 1)
dir_b <- ">="
rhs_b <- min_num

# Restriction of selecting at least one park
A_eq <- matrix(rep(1, num_parques), nrow = 1)
dir_eq <- ">="
rhs_eq <- 1

# Adding decision variable for each park (0 when not selected and 1 when selected)
A_bin <- diag(num_parques)

# Combining all matrices
A_final <- rbind(A,B,A_eq, A_bin)
dir_final <- c(rep(dir, 1), dir_b, dir_eq,rep("<=", num_parques))
rhs_final <- c(rhs,rhs_b, rhs_eq, rep(1, num_parques))

# Solve the linear optimization problem
sol <- lp(direction, objective.in = obj_coef, const.mat = A_final, const.dir = dir_final, const.rhs = rhs_final, all.bin = TRUE)
print(sol$status)
best_sol <- sol$solution     # selection of parks 

# Selected parks
selected_parks <- parques[best_sol == 1, ]

# Solver results
sol$objective
sol$const.count
c <- sol$constraints
sol$objval
sol$solution

# Confirming that restrictions have been respected
sum(selected_parks$Costs) < total_budget

}

# SPATIALIZING

{

sp_total <- read_municipality(code_muni = 3550308, year = 2022)

list_parques <- list(selected_parks)

textos <- c("Objective 1")

cols <- c("#40826d")

wgs84_proj <- st_crs("+proj=longlat +datum=WGS84")

sp_total <- st_transform(sp_total,wgs84_proj)
selected_parks <- st_transform(selected_parks, wgs84_proj)

X11(width = 10, height = 10)
layout(matrix(1:1, nrow = 1, byrow = TRUE))
par(mar = c(0.1, 0.1, 0.1, 0.3))
for (i in seq_along(list_parques)) {
  plot(sp_total$geom)
  plot(selected_parks$geom, col = cols[i], border = cols[i], add = TRUE)
  mtext(textos[i], line = -30, adj = 0.9, cex = 1.5, col = cols[i], font = 3)
}

}
