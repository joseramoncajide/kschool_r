###########################################################################
# @jrcajide, 2017-04
# Librerías necesarias
##########################################################################

# Ejecutar el siguiente bloque de código

list.of.packages <- c("tidyverse","RColorBrewer","ggthemes","scales","forecast","maps","googleAuthR","searchConsoleR","tm","wordcloud","googleAnalyticsR","knitr","flexdashboard","imputeTS","smooth","strucchange","CausalImpact","GGally","highcharter","xts")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

