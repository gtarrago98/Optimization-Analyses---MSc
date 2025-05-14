# This code was used to generate optimization curves for the prioritization results, considering a limited budget as constraints

library(readxl)
library(writexl)
library(ggplot2)
library(viridis)
library(scales)
library(corrplot)
library(DHARMa)
library(sf)
library(tidyr)
library(dplyr)
library(gridExtra)
library(plotly)
library(fmsb)
library(png)
library(magick)

# Evaluating the effect of progressive budget increases on objectives/ ecosystem services 

{
  parques <- read_xlsx("dados/parques_São_Paulo_4.0.xlsx")
  
    
    # Function to organize list
    
    order_df <- function(dir){
      
      arquivos_crs <- list.files(path = dir, pattern = "*.csv", full.names = TRUE)
      
      list <- lapply(arquivos_crs, read.table, header = TRUE, sep = ",")
      
      names(list) <- basename(arquivos_crs)
      
      numeros <- as.numeric(gsub(".*_(\\d+(\\.\\d+)?)mi\\.csv$", "\\1", names(list)))
      
      ordem <- order(numeros)
      
      list <- list[ordem]
      
      return(list)
      
    }
    
    
    # Normalization function
    
    normalize <- function(x) {
      return ((x - min(x)) / (max(x) - min(x)))
    }
    
    
    colour <- c("#1e9a6f","darkgoldenrod1","#6271FF","#e64949","blue4", "chartreuse", "#f668b3")
    
    dolar <- 5.4
    
    
    # Function to create dataframe
    
    
    sum_service <- function(list) {
      
      crs_value <- vector("numeric", length(list))
      wps_value <- vector("numeric", length(list))
      rcs_value <- vector("numeric", length(list))
      crs_provision <- vector("numeric", length(list))
      wps_provision <- vector("numeric", length(list))
      rcs_provision <- vector("numeric", length(list))
      sum_cost <- vector("numeric", length(list))
      combined_provision <- vector("numeric", length(list))
      cost_benefit <- vector("numeric", length(list))
      vegetation <- vector("numeric", length(list))
      n_parks <- vector("numeric", length(list))
      cr_deman <- vector("numeric", length(list))
      rc_deman <- vector("numeric", length(list))
      wp_deman <- vector("numeric", length(list))
      
      for (i in seq_along(list)) {
        
        crs <- sum(list[[i]]$CR_supply, na.rm = TRUE)
        wps <- sum(list[[i]]$WP_supply, na.rm = TRUE)
        rc <- sum(list[[i]]$RC_supply, na.rm = TRUE)
        p_crs <- sum((list[[i]]$CR_deman * list[[i]]$CR_supply), na.rm = TRUE)
        p_wps <- sum((list[[i]]$WP_deman * list[[i]]$WP_supply), na.rm = TRUE)
        p_rcs <- sum((list[[i]]$RC_deman * list[[i]]$RC_supply), na.rm = TRUE)
        s_cost <- sum(list[[i]]$Costs)
        p_combined <- sum((list[[i]]$CRP_norm + list[[i]]$WPP_norm + list[[i]]$RCP_norm), na.rm = TRUE)
        cos_ben <-  sum((list[[i]]$CRP_norm + list[[i]]$WPP_norm + list[[i]]$RCP_norm)/list[[i]]$Cost_nor_1, na.rm = TRUE)
        veg <- sum(list[[i]]$area_veg_m)
        parks <- nrow(list[[i]])
        deman_cr <- sum(list[[i]]$CR_deman, na.rm = TRUE)
        deman_wp <- sum(list[[i]]$WP_deman, na.rm = TRUE)
        deman_rc <- sum(list[[i]]$RC_deman, na.rm = TRUE)
        
        crs_value[i] <- crs
        wps_value[i] <- wps
        rcs_value[i] <- rc
        crs_provision[i] <- p_crs
        wps_provision[i] <- p_wps
        rcs_provision[i] <- p_rcs
        sum_cost[i] <- s_cost
        combined_provision[i] <- p_combined
        cost_benefit[i] <- cos_ben
        vegetation[i] <- veg
        n_parks[i] <- parks
        cr_deman[i] <- deman_cr
        wp_deman[i] <- deman_wp
        rc_deman[i] <- deman_rc
        
      }
      
      
      
      scenario_names <- sub("\\.csv$", "", names(list))
      
      numeros <- as.numeric(gsub(".*_(\\d+(\\.\\d+)?)mi\\.csv$", "\\1", names(list)))
      
      df <- data.frame(scenario = scenario_names, budget = numeros, "Nº Parks" = n_parks, cost = sum_cost, CRS_Supply = crs_value, WPS_Supply = wps_value, RC_Supply = rcs_value,
                       CRS_Provision = crs_provision, WPS_provision = wps_provision,RCS_provision = rcs_provision, Combined_provision = combined_provision,Cost_Benefit = cost_benefit, Vegetation = vegetation, CR_deman = cr_deman, WP_deman = wp_deman, RC_deman = rc_deman)
      
      return(df)
    }
    
  }
  
  # Evaluating the progression of ecosystem services across different optimization scenarios using limited budget as constraints 
  
  {
    # Maximize Climate Regulation Provision
    
    dir_crs <- "dados\\Orçamento\\max_CRP" # path to a list of all prioritization results that maximize a specific benefit.
    
    list_crs <- order_df(dir_crs)
    
    df_crs <- sum_service(list_crs)
  }
  
  # Optimization Curve for Maximize Climate Regulation Provision Scenario
  
  
  df_crs$prop_crs <- df_crs$CRS_Supply/sum(parques$CR_supply)
  df_crs$prop_wps <- df_crs$WPS_Supply/sum(parques$WP_supply)
  df_crs$prop_rcs <- df_crs$RC_Supply/ sum(parques$RC_supply)
  df_crs$prop_crp <- df_crs$CRS_Provision/sum(parques$CR_deman*parques$CR_supply)
  df_crs$prop_wpp <- df_crs$WPS_provision/sum(parques$WP_deman*parques$WP_supply)
  df_crs$prop_rcp <- df_crs$RCS_provision/ sum(parques$RC_deman * parques$RC_supply)
  df_crs$prop_cost <- df_crs$cost/sum(parques$Costs)
  df_crs$prop_deman <- df_crs$CR_deman/sum(parques$CR_deman)
  
  
  
  curve_crs_fit <- df_crs |>
    ggplot(aes(x = (budget/10)/dolar))+
    geom_line(aes(y = prop_crs,color = "Climate Regulation Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
    geom_line(aes(y = prop_wps,color = "Water Infiltration Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
    geom_line(aes(y = prop_rcs,color = "Recreation Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
    geom_line(aes(y = prop_crp,color = "Climate Regulation Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
    geom_line(aes(y = prop_wpp,color = "Water Infiltration Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
    geom_line(aes(y = prop_rcp,color = "Recreation Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
    #geom_line(aes(y = prop_deman,color = "Climate Regulation Demand"),linewidth = 1, linetype = 1, show.legend = TRUE)+
    scale_x_continuous(breaks = round(seq(df_crs$budget[1]/dolar, df_crs$budget[nrow(df_crs)], by = 0.5),1)) +
    labs(title = "Local Climate Regulation Provision Optimization Scenario", x = "Available Budget (US$ billion)", y = "Services (%)")+
    scale_color_manual(
      name = "Service", 
      values = c("Climate Regulation Supply" = colour[1], "Water Infiltration Supply" = colour[3], "Recreation Supply" =colour[7],
                 "Climate Regulation Provision" = colour[4],"Water Infiltration Provision" = colour[2], "Recreation Provision" =colour[6],"Climate Regulation Demand" = "blueviolet")) +
    theme_minimal() + 
    theme(
      panel.background = element_rect(fill = "white", color = "#d9d9d9"),
      legend.text = element_text(size = 10),
      axis.text = element_text(color = "black"),
      axis.ticks = element_line(color = "black")
    )
  
  image_crs_fit <- grid.arrange(curve_crs_fit, ncol = 1)
  
  {
    # Maximize Water Infiltration Provision
    
    dir_wps <- "dados\\Orçamento\\max_WIP" 
    
    
    list_wps <- order_df(dir_wps)
    
    
    df_wps <- sum_service(list_wps)
    
  }
  
  # Optimization Curve for Maximize Water Infiltration Provision Scenario
  
  df_wps$prop_crs <- df_wps$CRS_Supply/sum(parques$CR_supply)
  df_wps$prop_wps <- df_wps$WPS_Supply/sum(parques$WP_supply)
  df_wps$prop_rcs <- df_wps$RC_Supply/ sum(parques$RC_supply)
  df_wps$prop_crp <- df_wps$CRS_Provision/sum(parques$CR_deman*parques$CR_supply)
  df_wps$prop_wpp <- df_wps$WPS_provision/sum(parques$WP_deman*parques$WP_supply)
  df_wps$prop_rcp <- df_wps$RCS_provision/ sum(parques$RC_deman * parques$RC_supply)
  df_wps$prop_cost <- df_wps$cost/sum(parques$Costs)
  df_wps$prop_deman <- df_wps$WP_deman/sum(parques$WP_deman)
  
  
  
  curve_wps_fit <- df_wps |>
    ggplot(aes(x = (budget/10)/dolar))+
    geom_line(aes(y = prop_crs,color = "Climate Regulation Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
    geom_line(aes(y = prop_wps,color = "Water Infiltration Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
    geom_line(aes(y = prop_rcs,color = "Recreation Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
    geom_line(aes(y = prop_crp,color = "Climate Regulation Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
    geom_line(aes(y = prop_wpp,color = "Water Infiltration Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
    geom_line(aes(y = prop_rcp,color = "Recreation Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
    scale_x_continuous(breaks = round(seq(df_crs$budget[1]/dolar, df_crs$budget[nrow(df_crs)], by = 0.5),1)) +
    labs(title = "Local Water Infiltration Provision Optimization Scenario", x = "Available Budget (US$ billion)", y = "Services (%)")+
    scale_color_manual(
      name = "Service", 
      values = c("Climate Regulation Supply" = colour[1], "Water Infiltration Supply" = colour[3], "Recreation Supply" =colour[7],
                 "Climate Regulation Provision" = colour[4],"Water Infiltration Provision" = colour[2], "Recreation Provision" =colour[6], "Water Protection Demand"="cyan")) +
    theme_minimal() + 
    theme(
      panel.background = element_rect(fill = "white", color = "#d9d9d9"),
      legend.text = element_text(size = 10),
      axis.text = element_text(color = "black"),
      axis.ticks = element_line(color = "black")
    )
  
  image_wps_fit <- grid.arrange(curve_wps_fit, ncol = 1)
  
  # Maximize Recreational Provision
  
{
  
  dir_rcs <- "dados\\Orçamento\\max_RCP" 
  
  
  list_rcs <- order_df(dir_rcs)
  
  
  df_rcs <- sum_service(list_rcs)
  
}

# Optimization Curve for Maximize Recreational Provision Scenario



df_rcs$prop_crs <- df_rcs$CRS_Supply/sum(parques$CR_supply)
df_rcs$prop_wps <- df_rcs$WPS_Supply/sum(parques$WP_supply)
df_rcs$prop_rcs <- df_rcs$RC_Supply/ sum(parques$RC_supply)
df_rcs$prop_crp <- df_rcs$CRS_Provision/sum(parques$CR_deman*parques$CR_supply)
df_rcs$prop_wpp <- df_rcs$WPS_provision/sum(parques$WP_deman*parques$WP_supply)
df_rcs$prop_rcp <- df_rcs$RCS_provision/ sum(parques$RC_deman * parques$RC_supply)
df_rcs$prop_cost <- df_rcs$cost/sum(parques$Costs)
df_rcs$prop_deman <- df_rcs$RC_deman/sum(parques$RC_deman)


curve_rcs_fit <- df_rcs |>
  ggplot(aes(x = (budget/10)/dolar))+
  geom_line(aes(y = prop_crs,color = "Climate Regulation Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
  geom_line(aes(y = prop_wps,color = "Water Infiltration Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
  geom_line(aes(y = prop_rcs,color = "Recreation Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
  geom_line(aes(y = prop_crp,color = "Climate Regulation Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
  geom_line(aes(y = prop_wpp,color = "Water Infiltration Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
  geom_line(aes(y = prop_rcp,color = "Recreation Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
  scale_x_continuous(breaks = round(seq(df_crs$budget[1]/dolar, df_crs$budget[nrow(df_crs)], by = 0.5),1)) +
  labs(title = "Recreational Provision Optimization Scenario", x = "Available Budget (US$ billion)", y = "Services (%)")+
  scale_color_manual(
    name = "Service", 
    values = c("Climate Regulation Supply" = colour[1], "Water Infiltration Supply" = colour[3], "Recreation Supply" =colour[7],
               "Climate Regulation Provision" = colour[4],"Water Infiltration Provision" = colour[2], "Recreation Provision" =colour[6],"Recreational Demand"="brown1")) +
  theme_minimal() + 
  theme(
    panel.background = element_rect(fill = "white", color = "#d9d9d9"),
    legend.text = element_text(size = 10),
    axis.text = element_text(color = "black"),
    axis.ticks = element_line(color = "black")
  )

image_rcs_fit <- grid.arrange(curve_rcs_fit, ncol = 1)

{
  
  # Maximize Cost-Benefit
  
  
  dir_cb <- "dados\\Orçamento\\max_CB" 
  
  
  list_cb <- order_df(dir_cb)
  
  
  df_cb <- sum_service(list_cb)
  
}

# Optimization Curve for Maximize Cost-Benefit Scenario



df_cb$prop_crs <- df_cb$CRS_Supply/sum(parques$CR_supply)
df_cb$prop_wps <- df_cb$WPS_Supply/sum(parques$WP_supply)
df_cb$prop_rcs <- df_cb$RC_Supply/ sum(parques$RC_supply)
df_cb$prop_crp <- df_cb$CRS_Provision/sum(parques$CR_deman*parques$CR_supply)
df_cb$prop_wpp <- df_cb$WPS_provision/sum(parques$WP_deman*parques$WP_supply)
df_cb$prop_rcp <- df_cb$RCS_provision/ sum(parques$RC_deman * parques$RC_supply)
df_cb$prop_cost <- df_cb$cost/sum(parques$Costs)



curve_cb_fit <- df_cb |>
  ggplot(aes(x = (budget/10)/dolar))+
  geom_line(aes(y = prop_crs,color = "Climate Regulation Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
  geom_line(aes(y = prop_wps,color = "Water Infiltration Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
  geom_line(aes(y = prop_rcs,color = "Recreation Supply"),linewidth = 1, linetype = 1, show.legend = TRUE)+
  geom_line(aes(y = prop_crp,color = "Climate Regulation Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
  geom_line(aes(y = prop_wpp,color = "Water Infiltration Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
  geom_line(aes(y = prop_rcp,color = "Recreation Provision"),linewidth = 1, linetype = 2, show.legend = TRUE)+
  scale_x_continuous(breaks = round(seq(df_crs$budget[1]/dolar, df_crs$budget[nrow(df_crs)], by = 0.5),1))+
  labs(title = "Benefit-Cost Optimization Scenario", x = "Available Budget (US$ billion)", y = "Services (%)")+
  scale_color_manual(
    name = "Service", 
    values = c("Climate Regulation Supply" = colour[1], "Water Infiltration Supply" = colour[3], "Recreation Supply" =colour[7],
               "Climate Regulation Provision" = colour[4],"Water Infiltration Provision" = colour[2], "Recreation Provision" =colour[6])) +
  theme_minimal() + 
  theme(
    panel.background = element_rect(fill = "white", color = "#d9d9d9"),
    legend.text = element_text(size = 10),
    axis.text = element_text(color = "black"),
    axis.ticks = element_line(color = "black")
  )

image_cb_fit <- grid.arrange(curve_cb_fit, ncol = 1)

# Combined plots

comb_1 <- grid.arrange(image_crs_fit, image_wps_fit, image_rcs_fit, image_cb_fit, nrow = 2)

# Radar plots

# Normalize

ser_comp$CR_supply <- normalize(ser_comp$CR_supply)
ser_comp$WP_supply <- normalize(ser_comp$WP_supply)
ser_comp$RC_supply <- normalize(ser_comp$RC_supply)
ser_comp$Cost <- normalize(ser_comp$Cost)

{
  
  scn <-  c("CRS","WPS","RCS","CB")
  
  selected_row  <- ser_comp[4,c(1:4)]
  
  selected_row <- rbind(rep(1, ncol(selected_row)), rep(0, ncol(selected_row)), selected_row)
  
  file_name <- paste0("dados\\Optimization_maps\\radar_plot",scn[4],df_crs$budget[i], ".png")
  
  png(file_name, width = 1600, height = 800, res = 195)
  
  par(mar = c(1, 2, 2, 2))
  
  radarchart(selected_row, axistype = 4,
             seg = 5,pty = 32,
             pcol = colour[4], pfcol = scales::alpha(colour[4], 0.7), plwd = 2, plty = 1,
             cglcol = "grey", cglwd = 1, cglty = 1, axislabcol = "black", caxislabels = c(NA,NA,NA,NA,NA,NA),calcex = 1,
             vlcex = 1.25, vlabels = c("CRS", "WPS   ", "RCS   ",  "   Cost"))
  #text(x = 1.3, y = 1.3, paste0("R$: ",df_crs$budget[2]/10, " bi"), cex = 1.2, col = "#e64949", pos = 1)
  
  dev.off()
  
}

# Radar Plots for each services scenarios

cenarios <- df_cb


for (i in 1:nrow(cenarios)){
  
  selected_row  <- cenarios[i,c(14:20)]
  
  selected_row <- rbind(rep(1, ncol(selected_row)), rep(0, ncol(selected_row)), selected_row)
  
  colors <- c("#d9d9d9","#1e9a6f")
  
  file_name <- paste0("dados\\Orçamento\\Radar_plots\\CB\\grafico_cenario_", cenarios$budget[i], ".png")
  
  png(file_name, width = 1600, height = 800, res = 195)
  
  par(mar = c(1, 2, 2, 2))
  
  radarchart(selected_row, axistype = 4,
             seg = 5,pty = 32,
             pcol = colors[2], pfcol = scales::alpha(colors[1], 0.7), plwd = 2, plty = 1,
             cglcol = "grey", cglwd = 1, cglty = 1, axislabcol = "black", caxislabels = c(NA,NA,NA,NA,NA,NA),calcex = 1,
             vlcex = 1.25, vlabels = c("CRS", "WPS   ", "RCS   ", "CRP","   WPP", "  RCP", "  Cost"))
  text(x = 1.3, y = 1.3, paste0("R$: ",cenarios$budget[i]/10, " bi"), cex = 1.2, col = "#e64949", pos = 1)
  
  dev.off()
  
  # Creating gif with plot images
  
  choose.files()
  
  
  images <- list.files("dados\\Orçamento\\Radar_plots\\CB", pattern = ".*\\.png",full.names = TRUE)
  
  # Ordering images by value
  
  numeric_part <- as.numeric(gsub("[^0-9]", "", basename(images)))
  
  sorted_indices <- order(numeric_part)
  
  sorted_images <- images[sorted_indices]
  
  animation <- image_read(sorted_images)
  
  animation <- image_animate(animation, fps = 2)
  
  image_write(animation, "dados\\Orçamento\\Radar_plots\\CB\\CB_radar_gif.gif")
  
  
}
