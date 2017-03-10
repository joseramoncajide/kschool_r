###########################################################################
# @jrcajide, 2017-03
# ggvis
##########################################################################

# Intalación y carga de librerías necesarias ------------------------------

list.of.packages <- c("tidyverse", "ggvis")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# Importamos datos --------------------------------------------------------

mis_datos <- read_csv('03-Data-Viz/data/adwords.csv')

mis_datos %>% 
  ggvis(x = ~impressions, y = ~adClicks) %>% 
  layer_points()

mis_datos %>% 
  ggvis(x = ~impressions, y = ~adClicks, fill = ~nombre) %>% 
  layer_points()

mis_datos %>% 
  ggvis(x = ~impressions, y = ~adClicks, fill = ~nombre) %>% 
  filter(users > eval(input_slider(min(mis_datos$users), max(mis_datos$users)))) %>% layer_points()


