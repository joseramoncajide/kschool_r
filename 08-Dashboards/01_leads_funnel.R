###########################################################################
# Widget Leads Funnel
##########################################################################

# Obtención de datos ------------------------------------------------------

# Engaged users:
# ¿Cuántos usuarios han accedido a páginas de cursos en sessiones de más de 3 minutos durante los últimos 30 días?

# users
# 1630

ga_funnel_step_1_df <- google_analytics_3()
# Leads:
# ¿Cuántos usuarios han enviado el formulario de inscripción?
# Acción del evento = 'Form Inscription'

# users
# 36

ga_funnel_step_2_df <- google_analytics_3()


ga_funnel_step_1_df <- ga_funnel_step_1_df %>% 
  as_data_frame() %>% 
  mutate(funnel_step = "Engage")

ga_funnel_step_2_df <- ga_funnel_step_2_df %>% 
  as_data_frame() %>% 
  mutate(funnel_step = "Lead")

funnel_df <- bind_rows(ga_funnel_step_1_df, ga_funnel_step_2_df)

# Visualización Funnel ----------------------------------------------------

highchart() %>% 
  hc_chart(type = "funnel") %>% 
  hc_xAxis(categories = funnel_df$funnel_step) %>% 
  hc_add_series(funnel_df$users, showInLegend = FALSE, dataLabels = list(enabled = FALSE))  %>% 
  hc_title(text = "Funnel captación de Leads") %>%
  hc_subtitle(text = "Usuarios que interactúan con la oferta de cursos y contactos generados")

