##########################################################################
# Series temporales y estadísticas básica para Analítica Web
##########################################################################

setwd('/Users/jose/Documents/GitHub/kschool_r/09-Time-Series')

## ------------------------------------------------------------------------
# Cargamos la librerías necesarias
list.of.packages <- c("imputeTS", "smooth", "strucchange", "CausalImpact", "tidyverse", "GGally", "highcharter", "xts")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)





sessions <- c(266, 333, 307, 213, 213, 147, 201, 147, 300, 274, 244, 179, 
              284, 340, 324, 288, 256, 230, 241, 222, 336, 341, 270, 164, 
              240, 362, 311, 242, 250, 270, 247, 252, 385, 540, 876, 214, 
              307, 398, 404, 324, 351, 413, 398, 351, 468, 412, 407, 356, 
              521, 570, 697)

hist(sessions,probability = T, breaks=20, main="Histograma: Distribución de sesiones del periodo")
curve(dnorm(x, mean(sessions), sd(sessions)), add=TRUE, col="darkblue", lwd=2)

mean(sessions)
abline(v = mean(sessions), col = "royalblue", lwd = 2)

median(sessions)
abline(v = median(sessions), col = "red", lwd = 2)

#cuartiles
quantile(sessions) 

#rango intercuartílico
IQR(sessions) 
quantile(sessions, 3/4) - quantile(sessions, 1/4)

var(sessions)

sqrt(var(sessions))
sd(sessions)

length(sessions)

diff(sesiones)

round(mean(sessions), 0)

mean_sessions <- mean(sessions)
sd_sessions <- sd(sessions)
n <- length(sessions)

#Error estándar
sem_sessions <- sd(sessions) / sqrt(n)



# Outliers ----------------------------------------------------------------
# https://es.wikipedia.org/wiki/Valor_at%C3%ADpico
# Tukey’s definition of an outlier: https://en.wikipedia.org/wiki/Outlier#Tukey's_fences

boxplot(sesiones)

q3 <- qnorm(0.75)
q1 <- qnorm(0.25)
iqr <- q3 - q1
r <- c(q1 - 1.5*iqr, q3 + 1.5*iqr)
r


max(sessions)
( max_sessions <- as.numeric(quantile(sessions, probs=c(.75)) + 1.5 * IQR(sessions)) )
min(sessions)
( min_sessions <- as.numeric(quantile(sessions, probs=c(.25)) - 1.5 * IQR(sessions)) )

outliers <- sessions[sessions < min_sessions | sessions > max_sessions]

plot(sessions, col=ifelse(sessions %in% outliers, "red", "blue"))
abline(h = max_sessions, col="red") 

boxplot(sessions)

clean_sessions <- sessions[!sessions %in% outliers]
plot(clean_sessions, pch="*")

hist(sessions)
hist(clean_sessions)

mean(clean_sessions)
median(clean_sessions)



# Modelos de regresión lineal ---------------------------------------------

ventas <- c(10,12,11,13,12,14,16,12,14,11,10,19,8.5,8,9,13,16,18,20,22)
tv <- c(13,14,15,17,17.5,13,14.5,9,8,9,8,10,17,18,18.5,19,20,20,13,14)
radio <-c(56,55,60,65,69,67,68,67,97,66,65,60,70,110,75,80,85,90,56,55)
online <- c(40,40,42,50,40,44,40,44,46,46,45,110,30,50,45,40,80,90,90, 110)
datos <- data.frame(ventas, tv, radio, online)
pairs(datos)

modelo <- lm(ventas ~ tv + radio + online, data = datos)
summary(modelo)
round(coefficients(modelo), 4)
# ventas = 8.7759 - 0.0085*tv - 0.0384*radio + 0.1335*online

modelo2 <- lm(ventas ~ online, data = datos)
summary(modelo2)
round(coefficients(modelo2), 4)
# ventas = 5.8170 + 0.1356*online
cor(ventas, online)
cor(datos)
plot(y=ventas, x=online)
abline(modelo2, col='red')

# Continuamos -------------------------------------------------------------

# El tiempor como una variable contínua
mod <- lm(sessions ~ time(sessions))
summary(mod)


mod2 <- lm(clean_sessions ~ time(clean_sessions))
summary(mod2)

plot(clean_sessions, ylim = c(0, 900))
abline(mod2, col="red")


# Comparamos ambos modelos
par(mfrow=c(1, 2))
plot(sessions, ylim = c(0, 900), main="Con outliers")
abline(mod, col="red", lwd=3, lty=2)
plot(clean_sessions, ylim = c(0, 900), main="Sin outliers")
abline(mod2, col="red", lwd=3, lty=2)
dev.off()


##########################################################################
# Series temporales: modelar el tiempo ------------------------------------
# 
# Una serie temporal se define como una colección de observaciones (discretas o continuas) de una variable recogidas secuencialmente en el tiempo.
# 
# El tiempo es una elemento natural presente en el momento en el que se genera el dato.
# Serie es la característica fundamental de las series temporales. Quiere decir que una observación presente es influenciada por los valores pasados de la misma (Auto correlación).
# Lo modelos de series temporales usarán esta característica para predecir valores futuros.
# 
# 
# Objetivos del análisis de series temporales
# El principal objetivo es el de elaborar un modelo estadístico que describa la procencia de dicha serie.
# 
# Descriptivos: La dibujamos y consideramos sus medidas descriptivas básicas. ¿Presentan una tendencia?. ¿Existe estacionalidad?. ¿Hay valores extremos?
#   
# Predictivos: En ocasiones no sólo se trata de explicar los sucedido sino de ser capaces de predecir el futuro.
##########################################################################

# sessions con outliers
(sessions_ts <- ts(data = sessions, start = c(2014, 01), frequency = 12))


max_sessions <- quantile(sessions_ts, probs=c(.75)) + 1.5 * IQR(sessions_ts)
min_sessions <- quantile(sessions_ts, probs=c(.25)) - 1.5 * IQR(sessions_ts)
plot(sessions_ts, ylim = c(0, 900))
abline(h=max_sessions, col = "green")
abline(h=min_sessions, col = "red")


# Y si trabajamos sin outliers
(clean_sessions_ts <- ts(data = clean_sessions, start = c(2014, 01), frequency = 12))

# Nos faltan meses:
length(sessions_ts) == length(clean_sessions_ts)

# Marcamos los autliers como NA
clean_sessions_ts <- sessions_ts
clean_sessions_ts[clean_sessions_ts %in% outliers] <- NA

plot(sessions_ts, col="blue", lwd=2, lty="dotted")
lines(clean_sessions_ts, col = "red", lwd=2)

# library(imputeTS)
plotNA.distribution(clean_sessions_ts)

clean_sessions_ts
na.mean(clean_sessions_ts)
na.mean(clean_sessions_ts, option = "median")
na.kalman(clean_sessions_ts)

plotNA.imputations(clean_sessions_ts, na.mean(clean_sessions_ts))
plotNA.imputations(clean_sessions_ts, na.mean(clean_sessions_ts, option = "median"))
plotNA.imputations(clean_sessions_ts, na.kalman(clean_sessions_ts))

# Imputamos los NA
clean_sessions_ts <- na.kalman(clean_sessions_ts)
plot(sessions_ts, col="blue", lwd=2, lty="dotted")
lines(clean_sessions_ts, col = "red", lwd=2)

# Nuestra serie definitiva
rm(sessions_ts)
sessions_ts <- clean_sessions_ts
plot(sessions_ts)


# Modelos -----------------------------------------------------------------

# Modelado: Media
sessions.mean <- meanf(sessions_ts, h=12)
summary(sessions.mean)
plot(sessions.mean)

# Modelado: Naive
sessions_ts.naive <- naive(sessions_ts, h=12)
summary(sessions_ts.naive)
plot(sessions_ts.naive)

# Modelado: Media Móvil Simple
# library(smooth)
sessions_ts.sma<-sma(sessions_ts, h = 12, holdout = T, level = .95, ic = 'AIC')
sessions_ts.forecast <- forecast(sessions_ts.sma)
plot(sessions_ts.forecast)


# Componentes de una serie temporal ---------------------------------------
sessions_ts.decomp <- decompose(sessions_ts)
plot(sessions_ts.decomp)


# Serie desestacionalizada ------------------------------------------------
sessions_des.ts  <- sessions_ts-sessions_ts.decomp$seasonal
plot(sessions_ts,main="Serie normal Vs desestacionalizada", col="blue", lwd=2, lty="dotted")
lines(sessions_des.ts, col='red')

# Modelado: naive estacional
sessions_ts.snaive <- snaive(sessions_ts, h = 12)
plot(sessions_ts.snaive)

# Modelado: HoltWinters
sessions_ts.hw <- HoltWinters(sessions_ts)
plot(sessions_ts.hw)

forecast_out_sample <- forecast(sessions_ts.hw, h=12)
plot(forecast_out_sample)


# Cambios estructurales en una serie --------------------------------------

# require(strucchange)
breakpoints(sessions_ts ~ 1)
plot(sessions_ts, main="IPI breakpoints", ylab="Sesiones", col="blue", lwd=1.5)
lines(breakpoints(sessions_ts ~ 1), col="red")
lines(confint(breakpoints(sessions_ts ~ 1), level=0.90), col="red")
text(2015.5, 800, "Agosto 2016", cex=0.75, col="red", pos=4, font=3)


# Series temporales de más de una variable --------------------------------
# library(tidyverse)
(ga_data_df <- read_csv('data/ga_sessions.csv'))

# Vamos a analizar el siguiente código ------------------------------------

ga_data_df %>%
  arrange(channelGrouping) %>% 
  spread(channelGrouping, sessions) %>% 
  gather(key = channelGrouping, value = sessions,-date) %>% 
  arrange(date) %>% 
  drop_na() -> ga_data_2_df

assertthat::are_equal(x = ga_data_2_df, y = ga_data_df)


# Transformación de los datos ---------------------------------------------

ga_data_pivoted_df <- ga_data_df %>%
  arrange(channelGrouping) %>% 
  spread(channelGrouping, sessions) %>% 
  replace(., is.na(.), 0)

summary(ga_data_pivoted_df)

# Correlación entre variables
pairs(ga_data_pivoted_df[-1], upper.panel = NULL)

cor(ga_data_pivoted_df[-1])
round(cor(ga_data_pivoted_df[-1]), 2)

# library(GGally)
ggcorr(ga_data_pivoted_df[-1], label = T)
ggpairs(ga_data_pivoted_df[-1])

# library(highcharter)
hchart(cor(ga_data_pivoted_df[-1])) %>% 
  hc_add_theme(hc_theme_google()) %>% 
  hc_title(text = "Canales de adquisición") %>%
  hc_subtitle(text = "Correlaciones entre canales")



# Ejercicio ---------------------------------------------------------------
# ¿Qué ha provocado el pico de sesiones en noviembre de 2017?

ga_data_df %>% 
  group_by(date) %>% 
  summarise(sessions = sum(sessions)) %>% 
  ggplot() + 
  geom_line(aes(x = date, y = sessions), col = "darkblue")  +
  theme_minimal() + 
  ggtitle("¿Qué ha provocado el pico de sesiones en noviembre de 2017?") 


# Sol: Modifica el siguiente código hasta encontrar respuesta a la pregunta

ga_data_pivoted_df %>% 
  ggplot() + 
  geom_line(aes(x = date, y = `Paid Search`), col = "blue")  + 
  geom_line(aes(x = as.Date(date), y = `Organic Search`), col = "green") +
  theme_minimal() + 
  ggtitle("Paid (blue) vs Organic (green) search") 




# Series temporales múltiples ---------------------------------------------
web_data_ts <- ts(ga_data_pivoted_df[-1], frequency = 365, start = c(2014,01))
plot(web_data_ts)

# library(xts)
web_data_xts <- xts(ga_data_pivoted_df[-1], order.by = as.Date(ga_data_pivoted_df$date), frequency = 365)
plot.xts(web_data_xts)
plot.xts(web_data_xts, multi.panel=T, grid.ticks.on = F, major.ticks = F, minor.ticks = F)


# Causal Impact -----------------------------------------------------------
# library(CausalImpact)
# En la serie, primero la respuesta y luego las variables predictoras
# ¿Ha influido el tráfico de RRSS en el órganico a partir de 2016-11-01?
model_data <- web_data_xts[,c("Direct","Social")]
head(model_data)

pre.period <- as.Date(c("2014-01-01","2016-11-01"))
post.period <- as.Date(c("2016-11-02","2018-03-01"))

impact <- CausalImpact(model_data,  pre.period, post.period)
plot(impact)
summary(impact)
summary(impact, "report")



# Comparación de medias ---------------------------------------------------

ga_data_df %>% 
  group_by(channelGrouping) %>% 
  summarise(avg_sessions = round(mean(sessions),0)) %>% 
  arrange(-avg_sessions)

# ANOVA: estudio del efecto de uno o más factores sobre la media de una variable continua.
# H0: No hay diferencias entre las medias de los diferentes grupos :  μ1=μ2...=μk=μ
# H1: Al menos un par de medias son significativamente distintas la una de la otra

hcboxplot(x = ga_data_df$sessions, 
          var = ga_data_df$channelGrouping, 
          color = "#2980b9",
          outliers = FALSE) %>% 
  hc_chart(type = "column")


anova <- aov(ga_data_df$sessions ~ ga_data_df$channelGrouping)
summary(anova)

# Comparaciones múltiples
pairwise.t.test(x = ga_data_df$sessions, g = ga_data_df$channelGrouping, p.adjust.method = "holm", 
                pool.sd = TRUE, paired = FALSE, alternative = "two.sided")


