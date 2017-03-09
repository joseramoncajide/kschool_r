#' ---
#' author: "The Big Mistake"
#' output: github_document
#' ---

#+ setup, include = FALSE

#' **¿Por qué no coinciden las métricas de ambos datasets?**



list.of.packages <- c("tidyverse", "googleAnalyticsR", "knitr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

ga_auth()

#' ## Dataset A

dataset_a <- as_data_frame(google_analytics(id = "46728973",
                                            start="2016-09-01", end="2017-03-05",
                                            metrics = c("ga:users", "ga:newUsers", "ga:bounces"),
                                            dimensions = c("ga:date, ga:campaign"),
                                            segment = c("sessions::condition::ga:sourceMedium=@google;ga:medium=@cpc"),
                                            sort = c("ga:date"),
                                            max=99999999, 
                                            samplingLevel="HIGHER_PRECISION"))

dataset_a

#' ### Agrupación manual de datos por campaña
#' En el  dataset A he agrupado los datos por campaña y he sumado todoas las métricas para tener el número total de usuarios,   nuevos usuarios y rebotes para todo el periodo
#' 

dataset_a <- dataset_a %>% 
  dplyr::select(-date) %>% 
  group_by(campaign) %>% 
  summarise_all(funs(dataset_a = sum))

#' **Así queda el primer data set**

dataset_a

#' ## Dataset B
#' 
#' ### Agrupación automática de datos por campaña
#' Solicito los datos agrupados a la api. Para ello pido que no dimensione por fecha
#' 

dataset_b <- as_data_frame(google_analytics(id = "46728973",
                                            start="2016-09-01", end="2017-03-05",
                                            metrics = c("ga:users", "ga:newUsers", "ga:bounces"),
                                            dimensions = c("ga:campaign"),
                                            segment = c("sessions::condition::ga:sourceMedium=@google;ga:medium=@cpc"),
                                            max=99999999, 
                                            samplingLevel="HIGHER_PRECISION"))

names(dataset_b)[2:4] <- c("users_dataset_b", "newUsers_dataset_b", "bounces_dataset_b")

#' **Y así queda el segundo data set**

dataset_b

#' ## Dataset A+B
#' Para facilitar la comparación, he fusionado ambos en un único y he puesto las métricas de dos en dos:
#'  

dataset_a_b <- full_join(dataset_a, dataset_b) %>% 
  dplyr::select(campaign, starts_with('users_'), starts_with('newUsers_'), starts_with('bounces_')) 

knitr::kable(dataset_a_b)
