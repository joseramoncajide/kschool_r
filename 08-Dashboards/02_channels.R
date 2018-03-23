###########################################################################
# Channel correlations
##########################################################################

# Obtención de datos ------------------------------------------------------

# Engaged users:
# ¿Cuántos sesiones ha habido por canal durante los 30 últimos días?

# date channelGrouping sessions
# 2018-02-21         (Other)       35
# 2018-02-21          Direct      131
# 2018-02-21  Organic Search      313
# 2018-02-21     Paid Search      119

ga_channels_df <- google_analytics_3()

ga_channels_df %>% 
  head(10)


# Transformación de los datos en una matriz -------------------------------

pivoted_channels_df <- ga_channels_df %>% 
  as_data_frame() %>% 
  spread(channelGrouping, sessions) %>% 
  replace(., is.na(.), 0)

channel_mat <- pivoted_channels_df %>% 
  select(-date) %>% 
  as.matrix() 


# Correlación -------------------------------------------------------------

correlation_mat <- cor(channel_mat)

# Visualización correlación canales ---------------------------------------

hchart(correlation_mat) %>% 
  hc_add_theme(hc_theme_google()) %>% 
  hc_title(text = "Canales de adquisición") %>%
  hc_subtitle(text = "Correlaciones entre canales")
