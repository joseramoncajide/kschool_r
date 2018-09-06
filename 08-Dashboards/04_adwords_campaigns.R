###########################################################################
# Google Adwrods campaigns clustering
##########################################################################

# Obtención de datos ------------------------------------------------------

# Obtener las conseciones del objetivo Formulario de contacto, las impresiones y el coste de cada campaña de Google Adwords en los 30 últimos días.

#                           campaign goal3completions impressions adCost
# 1                        0 - MARCA               17        4136 597.69
# 2                    0 - MARCA BCN                4         531  92.91
# 3        BCN - CURSO - ESTADISTICA                0         495  10.11

ga_adwords_df <- google_analytics_3(...)

ga_adwords_df %>% 
  head(10)


# Transformación de los datos ---------------------------------------------

ga_adwords_scaled_mat <- 
  
# Clustering --------------------------------------------------------------



# Visualización segmentación de campañas ----------------------------------

highchart() %>% 
  hc_title(text = "Scatter chart with size and color") %>% 
  hc_add_series_scatter(x= ga_adwords_df$adCost, y=ga_adwords_df$impressions, z =  ga_adwords_df$goal3completions, color=ga_adwords_df$cluster) %>% 
  hc_title(text = 'SEM') %>% 
  hc_subtitle(text = 'Clustering de campañas de Google Adwords') %>%
  hc_tooltip(pointFormat = "Campaña: {point.campaign}") %>% 
  hc_add_theme(hc_theme_google())