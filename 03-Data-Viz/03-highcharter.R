###########################################################################
# @jrcajide, 2018-03
# Highcharter: http://jkunst.com/highcharter/index.html
##########################################################################

# Intalación y carga de librerías necesarias ------------------------------

list.of.packages <- c("tidyverse", "highcharter")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)


# Importamos datos --------------------------------------------------------

sessions_df <- read_csv('data/sessions.csv')

sessions_df %>% 
  group_by(channelGrouping, deviceCategory) %>% 
  summarise(sessions = sum(sessions)) %>% 
  hchart("bar", hcaes(x = deviceCategory, y = sessions, group=channelGrouping))

sessions_df %>% 
  group_by(channelGrouping, deviceCategory) %>% 
  summarise(sessions = sum(sessions)) %>% 
  hchart("column", hcaes(x = deviceCategory, y = sessions, group=channelGrouping))

sessions_df %>% 
  group_by(date) %>% 
  summarise(sessions = sum(sessions)) %>% 
  hchart("line", hcaes(x = date, y = sessions))

sessions_df %>% 
  group_by(date, deviceCategory) %>% 
  summarise(sessions = sum(sessions)) %>% 
  hchart("line", hcaes(x = date, y = sessions, group= deviceCategory)) %>% 
  hc_add_theme(hc_theme_darkunica()) %>% 
  hc_title(text = "Tráfico por dispositivos") %>%
  hc_subtitle(text = "Evolución temporal")

sessions_df %>% 
  hchart(type = "heatmap", hcaes(x = deviceCategory, y = channelGrouping, value = bounceRate)) %>% 
  hc_legend(layout = "vertical", verticalAlign = "top", align = "right") %>% 
  hc_title(text = "Tasa de rebote") 

