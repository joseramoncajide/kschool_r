
library(tidyverse)
library("tsoutliers")
library(lubridate)
# devtools::install_github("hrbrmstr/hrbrthemes")
# hrbrthemes::import_roboto_condensed()
library(hrbrthemes)
library(CausalImpact)

ga_data <- google_analytics(id = "46728973",
                            start="2016-09-01", end="2017-03-05",
                            metrics = c("ga:users", "ga:newUsers"),
                            dimensions = c("ga:date"),
                            segment = c("sessions::condition::ga:sourceMedium=@google;ga:medium=@cpc"),
                            sort = c("ga:date"),
                            max=99999999, samplingLevel="HIGHER_PRECISION"
)

# ga_data <- as_data_frame(ga_data)


#EDA

ga_data %>% ggplot(aes( x= date, y= newUsers)) + geom_line()

ga_data


# Sabemos que en esta época, son muchos los clientes o usuarios que nos conocen y por lo tanto queremos comprobar si estas campañas inciden también en ellos.
# Tenemos usuarios nuevos y usuarios. Calcular los recurrentes

ga_data <- ga_data %>% mutate(returningUsers = users - newUsers)

ga_data %>% ggplot(aes( x= date, y= returningUsers)) + geom_line()






# Ver costes de campañas

costs <- google_analytics(id = "46728973",
                          start="2016-09-01", end="2017-03-05",
                          metrics = c("ga:adCost"),
                          dimensions = c("ga:date"),
                          segment = NULL,
                          sort = c("ga:date"),
                          max=99999999, samplingLevel="HIGHER_PRECISION"
)

# Tenemos que fusionar. Explicar aquí los joins y funciones disponibles

all_data <- left_join(ga_data, costs)

# EDA

# Todo en un gráfico

all_data <- all_data %>% gather(key='metric', value="value", -date)

# Observamos que parece haber un mayor impacto en usuario nuevos que en recurrentes MOLA!
all_data %>% filter(metric != "adCost") %>% ggplot(aes(x=date, y= value, color = metric)) + geom_line() + geom_point() 


# Volvemos a como estaba
all_data <- all_data %>%  spread(key = "metric", value = "value")


# plot(all_data$adCost, all_data$returningUsers)
plot(all_data$adCost, all_data$newUsers)


all_data %>% ggplot(aes( x= adCost, y= newUsers)) + geom_point(color="orange",size=3,alpha=0.8) 

all_data %>% ggplot(aes( x= adCost, y= newUsers)) + geom_point() + geom_smooth()

all_data %>% ggplot(aes( x= adCost, y= newUsers)) + geom_point() + geom_smooth(method="lm")

# Dibuja ahora lo mismo para returningUsers 



###Correla

#Independent variable
x <- all_data$adCost

#Dependent variable
y <- all_data$newUsers

ct <- cor.test(x, y)
ct

ct$p.value

ct$estimate

# Aquí explicar la correlación y avanzar hacia la regresión


# Cuanto es el precio  que me cuesta traer un usuario nuevo CPA???

|  y |  x |
  |---|---|
  | 19  | 152  |
  | 24  | 161  |
  | 13  | 128  |  
  
  (19 + 24 + 13) /  (152 + 161 + 128) 

# Como primer instinto, el CPA o precio medio a pagar por nuevo usuario
# $y = f(x)$
# $cpa = f(nuevos_usuarios)$

sum(y) / sum(x)

CPA = Usuarios * 0.2

# Por lo tanto y = Beta x

# This is a form of prediction. This is a simple predictive model that takes an input, does a calculation, and gives an output (since the output can be of continuous values, the technical name for what we have would be a “regression model”)

# summary(lm(c(152, 161, 128) ~c(19,24, 13) + 0))

# Ajusto lm sin término indpendiente
pendiente <- coef(lm(c(152, 161, 128) ~ c(19,24, 13) + 0))
# pendiente <- coef(lm(c(19,24, 13)  ~ c(152, 161, 128) + 0))


muestra_de_x <- x[1:3]
muestra_de_y <- y[1:3]
# Esto sólo para regresión lineal no en el origen
# coef_correlacion_muestra <- cor(muestra_de_x, muestra_de_y)
# desviacion_estandar_muestra_de_x <- sd(muestra_de_x)
# desviacion_estandar_muestra_de_y <- sd(muestra_de_y)
# pendiente_muestra <- coef_correlacion_muestra * (desviacion_estandar_muestra_de_y/desviacion_estandar_muestra_de_x)

# $\beta_1 = \frac{\sum x_i y_i}{\sum x_i^2}$
pendiente_muestra <- sum(muestra_de_x * muestra_de_y) / sum(muestra_de_x^2)
# pendiente_muestra <- coef(lm(muestra_de_y ~ muestra_de_x + 0))

# Comprobar como pendiente_muestra es aprox igual a cpa_medio
cpa_medio <- (152 + 161 + 128) / (19 + 24 + 13)
cpa_medio <- sum(muestra_de_x) / sum(muestra_de_y)

sub_titulo <- paste0("Coste por adquisición de un nuevo usuario: ", round(1/pendiente_muestra,2), "€")
ecuacion = paste0("Nuevos usuarios = ", round(pendiente_muestra,2), " * CPA" )

ggplot() + geom_point(aes(x= muestra_de_x, y = muestra_de_y), color="#d62d20",size=3,alpha=0.8) + xlim(0,max(muestra_de_x)+10) + ylim(0,max(muestra_de_y)+5) + 
  geom_text(aes(x= c(152), y = c(19)), label=c("(152, 19)"), vjust=-2, hjust=1, color = "#666666") +
  geom_text(aes(x= c(161), y = c(24)), label=c("(161, 24)"), vjust=-2, hjust=.5, color = "#666666") +
  geom_text(aes(x= c(128), y = c(13)), label=c("(128, 13)"), vjust=2, hjust=.5, color = "#666666") +
  xlab("CPA (€)") +
  ylab("Nuevos usuarios") +
  geom_segment(aes(x = 152, y = 19, xend = 152, yend = 0), linetype=2, color = "#cccccc") +
  geom_segment(aes(x = 0, xend = 152, y = 19, yend = 19), linetype=2, color = "#cccccc") +
  geom_segment(aes(x = 161, y = 24, xend = 161, yend = 0), linetype=2, color = "#cccccc") +
  geom_segment(aes(x = 0, xend = 161, y = 24, yend = 24), linetype=2, color = "#cccccc") +
  geom_segment(aes(x = 128, y = 13, xend = 128, yend = 0), linetype=2, color = "#cccccc") +
  geom_segment(aes(x = 0, xend = 128, y = 13, yend = 13), linetype=2, color = "#cccccc") +  
  labs(title="Modelo predictivo simple", subtitle= sub_titulo, caption = ecuacion) +
  geom_abline(intercept = 0, slope = pendiente_muestra, color= "#0057e7",size=1.1)  +
  geom_abline(intercept = 0, slope = pendiente_muestra + .01, color= "#0057e7", alpha = .2)  +
  geom_abline(intercept = 0, slope = pendiente_muestra - .01, color= "#0057e7", alpha = .2)  +
  # geom_smooth(method="lm", se=FALSE, formula=y~x-1, aes(x= muestra_de_x, y = muestra_de_y) ) 
  # annotate("text", x = 120, y = 5, label = ecuacion, colour = "#3B3938", fontface =2) + 
  theme_ipsum_rc(grid=F, axis=T, ticks = T)

# El CPA (un usuario)
1/pendiente_muestra

# Esto para lineal
# r <- ct$estimate
# sd(x)
# sd(y)
# m <- r * (sd(y)/sd(x))

# cpa_medio <- (152 + 161 + 128) / (19 + 24 + 13)
# cpa_medio <- sum(muestra_de_x) / sum(muestra_de_y)
# 
# sub_titulo <- paste0("Coste por adquisición de un nuevo usuario: ", round(cpa_medio,2), "€")
# eq = paste0("Nuevos usuarios = ", round(pendiente,1), " * CPA" )


# ggplot() + geom_point(aes(x= c(19,24, 13), y = c(152, 161, 128)), color="orange",size=3,alpha=0.8) + xlim(0,30) + ylim(0,200) + 
#   geom_text(aes(x= c(19), y = c(152)), label=c("(19, 152)"), vjust=-.5) +
#   geom_text(aes(x= c(24), y = c(161)), label=c("(24, 161)"), vjust=1) +
#   geom_text(aes(x= c(13), y = c(128)), label=c("(13, 128)"), vjust=1) +
#   xlab("CPA (€)") +
#   ylab("Nuevos usuarios") +
#   geom_segment(aes(x = 19, xend = 19, y = 152, yend = 0), linetype=2, color = "#cccccc") +
#   geom_segment(aes(x = 0, xend = 19, y = 152, yend = 152), linetype=2, color = "#cccccc") +
#   geom_segment(aes(x = 24, xend = 24, y = 161, yend = 0), linetype=2, color = "#cccccc") +
#   geom_segment(aes(x = 0, xend = 24, y = 161, yend = 161), linetype=2, color = "#cccccc") +  
#   geom_segment(aes(x = 13, xend = 13, y = 128, yend = 0), linetype=2, color = "#cccccc") +
#   geom_segment(aes(x = 0, xend = 13, y = 128, yend = 128), linetype=2, color = "#cccccc") +   
#   labs(title="Modelo predictivo simple", subtitle= sub_titulo, caption = eq) +
#   geom_abline(intercept = 0, slope = 1/pendiente, color= "blue")  +
#   geom_abline(intercept = 0, slope = 1/pendiente + .5, color= "blue", alpha = .2)  +
#   geom_abline(intercept = 0, slope = 1/pendiente - .5, color= "blue", alpha = .2)  +
#   # geom_smooth(method="lm", se=FALSE, formula=y~x-1, aes(x= c(19,24, 13), y = c(152, 161, 128)) ) 
#   annotate("text", x = 20, y = 50, label = eq, colour = "red", fontface =2) + 
#   theme_ipsum_rc()
#   # geom_segment(aes(x= c(0), y = c(152), xend=-Inf, yend=19))
#   # geom_vline(aes(xintercept=19), linetype=2)
#   
# # Por lo tanto CPA = (19 + 24 + 13) /  (152 + 161 + 128) 


# Pongamos ahora todos los datos

pendiente <- coef(lm(newUsers ~ 0 + adCost, data = all_data))
sub_titulo <- paste0("Coste por adquisición de un nuevo usuario: ", round(1/pendiente,2), "€")
ecuacion = paste0("Nuevos usuarios = ", round(pendiente,2), " * CPA" )

all_data %>% ggplot(aes( x= adCost, y= newUsers)) + geom_point(color="#ffa700",size=3,alpha=0.8) +
  geom_abline(intercept = 0, slope = pendiente, color= "#0057e7")  +
  labs(title="Modelo predictivo simple (Todos los datos)", subtitle= sub_titulo, caption = ecuacion) +
  # annotate("text", x = 20, y = 50, label = eq, colour = "red", fontface =2) +
  geom_smooth(method="lm", se=FALSE, formula=y~x-1) +
  theme_ipsum_rc(grid="XY")

# Model



new_users.lm <- lm(newUsers ~ adCost, data = all_data)

summary(new_users.lm)




plot(new_users.lm)

(coeficientes <- coef(new_users.lm))

termino_independiente.lm <- coeficientes[1]
pendiente.lm <- coeficientes[2]

# EQ LM 
eq.lm = paste0("Nuevos usuarios = ", round(termino_independiente.lm,2), " + ", round(pendiente.lm,2), " * CPA" )

sub_titulo <- paste0("Coste por adquisición de un nuevo usuario: ", round(1/pendiente.lm,2), "€")

# Moviendo el término independientre
all_data %>% ggplot(aes( x= adCost, y= newUsers)) + geom_point(color="#ffa700",size=3,alpha=0.8) +
  geom_abline(intercept = termino_independiente.lm, slope = pendiente.lm, color= "#0057e7",size=1.4) +
  geom_abline(intercept = termino_independiente.lm + 2 , slope = pendiente.lm, color= "#0057e7", alpha = .8) +
  geom_abline(intercept = termino_independiente.lm - 2 , slope = pendiente.lm, color= "#0057e7", alpha = .8) + 
  geom_abline(intercept = termino_independiente.lm + 4 , slope = pendiente.lm, color= "#0057e7", alpha = .2) +
  geom_abline(intercept = termino_independiente.lm - 4 , slope = pendiente.lm, color= "#0057e7", alpha = .2) +   
  # annotate("text", x = 20, y = 50, label = eq, colour = "red", fontface =2) +
  labs(title="Modelo de regresión lineal", subtitle= sub_titulo, caption = eq.lm) +
  theme_ipsum_rc()


# Obtain predicted and residual values
all_data$predichos <- predict(new_users.lm)
all_data$residups <- residuals(new_users.lm)

# RMSE: The RMSE is a measure of the average deviation of the estimates from the observed values. has the useful property of being in the same units as the response variable (usuarios)
# RMSE is a good measure of how accurately the model predicts the response, and is the most important criterion for fit if the main purpose of the model is prediction
# $MSE=\frac{1}{n} \sum_{i=1}^n (y_i - \hat{y}_i)^2$
# $RMSE=\sqrt{MSE}$
(mean((all_data$newUsers - all_data$predichos)^2))^0.5 
summary(new_users.lm)$sigma

# FINAL
all_data %>% ggplot(aes( x= adCost, y= newUsers)) + geom_point(color="#ffa700",size=3,alpha=0.8) +
  geom_point(aes(y = predichos), color= "#0057e7",size=3,alpha=0.8) +
  geom_segment(aes(xend = adCost, yend = predichos), alpha = .2) +
  # annotate("text", x = 20, y = 50, label = eq, colour = "red", fontface =2) +
  labs(title="Modelo de regresión lineal", subtitle= "Errores del modelo", caption = eq.lm) +
  theme_ipsum_rc(grid=F, axis=T, ticks = F)

#Repetir lo mismo para usuarios recurrentes. ¿Cuál ajuste mejor? 


returning_users.lm <- lm(returningUsers ~ adCost, data = ga_data)

summary(returning_users.lm)

coef(returning_users.lm)

# Coeficientes. Compara la pendiente de ambas rectas. ¿En que usuarios produce más efecto la inversión en Adwords?

coef(new_users.lm)[2] > coef(returning_users.lm)[2]


# Intervalos de confianza del modelo

confint(new_users.lm)
# Por cada euro invertido en CPC, tengo una certeza del 95% de que seré capar de captar entre 0.1619436  y 0.1835284 nuevos usuarios

# Igualmente el términos independiente estará entre 1.4270902 y 6.1977737 (95% de confianza)

predicciones <- as_data_frame(predict(new_users.lm, interval='prediction'))

datos_con_intervalos_de_confianza <- cbind(all_data, 
                                           predicciones)

datos_con_intervalos_de_confianza$fuera_intervalo <-
  ifelse(
    all_data$newUsers <= predicciones$lwr,
    T,
    ifelse(all_data$newUsers >= predicciones$upr, T, F)
  )


library(ggrepel)
datos_con_intervalos_de_confianza %>% ggplot(aes(adCost, newUsers))+
  geom_point(aes(colour=factor(fuera_intervalo))) +
  scale_colour_manual(name = "",   values = c('TRUE'="#d62d20", 'FALSE'="#cccccc"), labels = c("Dentro del intervalo", "Fuera del intervalo")) +
  geom_text_repel(data=subset(datos_con_intervalos_de_confianza, fuera_intervalo == T),  aes(x=adCost, y=newUsers, label = factor(date)), color = '#0057e7' )  +
  # geom_text(aes(x= c(19), y = c(152)), label=c("(19, 152)"), vjust=-.5) +
  geom_line(aes(y=lwr), color = "#d62d20", linetype = "dashed")+
  geom_line(aes(y=upr), color = "#d62d20", linetype = "dashed")+
  geom_smooth(method=lm, se=TRUE, color='#0057e7')  +
  # annotate("text", x = 20, y = 50, label = eq, colour = "red", fontface =2) +
  labs(title="Modelo de regresión lineal", subtitle= "Intervalo de confianza de las predicciones", caption = eq.lm) +
  theme_ipsum_rc(grid=F, axis=T, ticks = T) +theme( legend.position = "bottom")




# Predecir.

predict(new_users.lm)

## Predecir un valor
posibles_inversiones <- data.frame(adCost=c(200, 300))

posibles_inversiones$newUsers <- as_data_frame(predict(object = new_users.lm, newdata = posibles_inversiones , interval='prediction'))
str(posibles_inversiones)
names(posibles_inversiones)


all_data %>% ggplot() + 
  geom_point(data = all_data, aes( x= adCost, y= newUsers)) +
  geom_point(data = posibles_inversiones, aes(x = adCost, y=newUsers), color= "#0057e7",size=5,alpha=0.8, shape=4 ) +
  labs(title="Modelo de regresión lineal", subtitle= "Predicciones del modelo", caption = eq.lm) +
  theme_ipsum_rc(grid=F, axis=T, ticks = F)

all_data %>% ggplot(aes( x= adCost, y= newUsers)) + geom_point(color="#cccccc",size=3,alpha=0.8) +
  geom_point(data = posibles_inversiones, aes(x = adCost, y=newUsers), color= "#0057e7",size=5,alpha=0.8, shape=4 ) +
  geom_segment(aes(xend = adCost, yend = predichos), alpha = .2) +
  # annotate("text", x = 20, y = 50, label = eq, colour = "red", fontface =2) +
  labs(title="Modelo de regresión lineal", subtitle= "Errores del modelo", caption = eq.lm) +
  theme_ipsum_rc(grid=F, axis=T, ticks = F)




# Plot con ggplot para presentar


# Cuál es la media de usuarios nuevos y recurrentes 


new_and_returning_averages <- ga_data %>% summarise(avg_newUsers = mean(newUsers), avg_returningUsers = mean(returningUsers))

#t.test?????
plot(density(ga_data$newUsers))
plot(density(ga_data$returningUsers))

# TODO
ga_data %>% 
  gather(key='dimension', value="metric", -date, -users) %>% ggplot(aes(x=metric, color=dimension)) + geom_density(aes(fill=dimension), size=0, alpha=.8, color="red") +
  scale_fill_manual(name = "", values = c('newUsers'="#2196F3", 'returningUsers'="#3F51B5"), labels = c("Nuevos Usuarios", "Usuarios Recurrentes")) +
  # scale_fill_manual( values = c("red","blue")) +
  xlab("") +
  ylab("# usuarios") + 
  labs(title="Media de usuarios por tipo", subtitle= "", caption = "Fuente: Google Analytics") +
  theme_ipsum_rc(grid='Y', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")

boxplot(ga_data$newUsers)
boxplot(ga_data$returningUsers)

ga_data %>% 
  gather(key='metric', value="value", -date, -users) %>% 
  ggplot(aes(x= metric, y = value)) + geom_boxplot() +
  xlab("") +
  ylab("# usuarios") + 
  labs(title="Media de usuarios por tipo", subtitle= "", caption = "Fuente: Google Analytics") +
  theme_ipsum_rc(grid='Y', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")


t.test(ga_data$newUsers, ga_data$returningUsers)

# Dado que se ha demostrado el éxito de las campañas de adwords



# Comprobar los efectos de las campañas en los usuarios nuevos y recurrentes


# SERIES TEMPORALES
#  Aquí tsoutliers con newUsers y returningUser


### Causal impact de a partir de la fecha de la campaña el ¿23 de enero? ¿Usamos la serie de users como estable?








new_users.ts <- ts(all_data$newUsers, frequency = 365, start=decimal_date(ymd(min(all_data$date))))
plot(new_users.ts)

new_users.ts.fit <- tsoutliers::tso(new_users.ts, types = c("AO","LS","TC","IO"),maxit.iloop=20, tsmethod = "auto.arima")
plot(new_users.ts.fit)
# fit <- new_users.ts.fit$fit
new_users_outliers <- as_data_frame(new_users.ts.fit$outliers)
new_users_outliers$date <- as.Date(new_users_outliers$time,format='%Y:%j')

new_users_outliers <- left_join(all_data,
                                new_users_outliers)


install.packages("ggalt")
library(gridExtra)
library(ggalt)
# PINTAR OUTLIERS EN EL PLOT

outliers.sub <- subset(new_users_outliers, type != "")
outliers.sub2 <- subset(outliers.sub, type != "AO")
new_users_outliers %>% ggplot(aes( x= date, y= newUsers)) + geom_xspline(color="#cccccc", spline_shape=-0.4, size=0.5) +
  geom_point(data=subset(new_users_outliers, type != ""), aes(x=date ,y= newUsers, color = factor(type)),size=3,alpha=0.95) +
  geom_label_repel(data=outliers.sub,  aes(x=date, y=newUsers, label = factor(type)), box.padding = unit(1.55, "lines"),point.padding = unit(0.5, "lines"), segment.color = '#666666') +
  geom_encircle(data=outliers.sub2, colour="#d62d20", expand=0.1) +
  # scale_color_discrete(name = 'type') +
  scale_colour_manual(name = "",   values = c('IO'="#ffa700", 'LS'="#008744", 'AO'="#d62d20"), labels = c("IO: Punto precursor del cambio", "AO: Extremo", "LS: Cambio de nivel")) +
  # scale_colour_manual(name = "Detected changes:",   values = c('IO'="#ffa700", 'LS'="#008744", 'AO'="#d62d20"), labels = c("IO: Innovational", "LS: Shift", "AO: Additive")) +
  scale_x_date(labels = scales::date_format("%m/%Y"), breaks = scales::date_breaks("month"), date_minor_breaks = "1 week") +
  xlab("") +
  ylim(0,150) +
  ylab("# Nuevos usuarios") + 
  labs(title="Adquisición de nuevos usuarios", subtitle= "Rendimiento de las campañas en Google Adwords", caption = "Fuente: Google Analytics - @jrcajide") +
  theme_ipsum_rc(grid='x', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")


# ##### AQUÏ HOTWILTERS forecast

# library("strucchange")
# new_users.bp <- breakpoints(new_users.ts~1)
# summary(new_users.bp)
# breakdates(new_users.bp)
# ci.new_users <- confint(new_users.bp)
# breakdates(ci.new_users)
# plot(new_users.ts)
# lines(ci.new_users)

# resid <- residuals(fit)
# plot(resid)
# pars <- coefs2poly(fit)
# 
# outliers <- locate.outliers(resid, pars)
# 
# y <- log(ga_data.ts)
# res <- locate.outliers.oloop(y, fit, types = c("AO", "LS", "TC"))
# res$outliers
# remove.outliers(res, y, method = "en-masse", tsmethod.call = fit$call)$outliers
min(all_data$date)
pre.period <- as.Date(c("2016-09-01", "2017-01-10"))
post.period <- as.Date(c("2017-01-11", "2017-03-05"))



impact <- CausalImpact(all_data %>% dplyr::select(date, newUsers), 
                       pre.period, 
                       post.period)
plot(impact)
summary(impact, "report")


ga_data2 <- google_analytics(id = "46728973",
                             start="2016-09-01", end="2017-03-05",
                             metrics = c("ga:users", "ga:newUsers", "ga:bounces"),
                             dimensions = c("ga:date, ga:campaign"),
                             segment = c("sessions::condition::ga:sourceMedium=@google;ga:medium=@cpc"),
                             sort = c("ga:date"),
                             max=99999999, samplingLevel="HIGHER_PRECISION"
)


costes_por_campana <- google_analytics(id = "46728973",
                                       start="2016-09-01", end="2017-03-05",
                                       metrics = c("ga:impressions,ga:adClicks,ga:adCost,ga:cpc"),
                                       dimensions = c("ga:date","ga:campaign"),
                                       segment = NULL,
                                       sort = c("ga:date"),
                                       max=99999999, samplingLevel="HIGHER_PRECISION"
)



campanas <- ga_data2 %>% filter(campaign != "(not set)") 
# OJO NO:
left_join(campanas, costes_por_campana)
campanas <- left_join(campanas, costes_por_campana, by = c("date", "campaign"))
# %>% 
# separate(campaign, c("foo", "bar", "sss"), "-")

campanas_adwords.fit <- lm(newUsers ~  0 + adCost + campaign, data=campanas)

summary(campanas_adwords.fit)
campanas_adwords.fit$coefficients
# Plot https://github.com/hrbrmstr/ggalt
library(broom)
campanas_adwords_res <- tidy(campanas_adwords.fit)
r.squared <- glance(campanas_adwords.fit)$r.squared
campanas_adwords_res$term <- tolower(campanas_adwords_res$term)

trim <- function (x) gsub("^campaign", "", x)
campanas_adwords_res$term <- trim(campanas_adwords_res$term )

mejores_campanas <- subset(campanas_adwords_res, estimate > 0)
peores_campanas <- subset(campanas_adwords_res, estimate <= 0)

ggplot( ) +
  geom_lollipop(data = campanas_adwords_res, aes(y=reorder(term, estimate), x=estimate), point.colour="#008744", point.size=2, horizontal=TRUE, color="#cccccc", alpha=.9) +
  geom_lollipop(data = peores_campanas, aes(y=reorder(term, estimate), x=estimate), point.colour="#d62d20", point.size=2, horizontal=TRUE, color="#cccccc", alpha=.9) +
  labs(title="Modelo de regresión lineal múltiple", subtitle= "Peso de las campañas", caption = "Cada punto representa el peso relativo de cada campaña a la hora de captar nuevos usuarios.") +
  xlab(expression(paste("Coeficientes ", beta))) +
  ylab("") +
  theme_ipsum_rc(grid=F, axis=T, ticks = F)

#ANOVA MEDIAS CAMPAÑA CTR
# Nos deshacemos de las campañas generícas
campanas_no_genericas <- campanas %>%  
  filter(!grepl("MARCA|Competencia", campaign)) %>% 
  separate(campaign, c("ciudad", "programa", "nombre"), " - ") %>% View()

campanas_no_genericas <- campanas_no_genericas[complete.cases(campanas_no_genericas),]

campanas_no_genericas %>% ggplot(aes(x=nombre, y=newUsers, color=programa)) + geom_boxplot() + facet_wrap(~ciudad) + coord_flip() +
  xlab("") +
  ylab("# usuarios") + 
  labs(title="Media de usuarios por tipo", subtitle= "", caption = "Fuente: Google Analytics") +
  theme_ipsum_rc(grid='Y', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")

# ESTO EN EDA AL PRINCIPIO
campanas_no_genericas %>%  mutate(returningUsers = users - newUsers) %>% group_by(programa, nombre) %>% 
  summarise(newUsers = sum(newUsers), returningUsers = sum(returningUsers), users = sum(users), adCost=sum(adCost, na.rm=T), bounces=sum(bounces)) %>% ggplot(aes(x=adCost, y=newUsers, color=programa)) + geom_point(aes(size = users)) + 
  geom_text_repel(aes(label = factor(nombre)), color = '#212121' ,box.padding = unit(0.55, "lines")) + 
  # geom_label_repel(aes(label = factor(nombre)), box.padding = unit(.55, "lines"),point.padding = unit(0.5, "lines"), segment.color = '#666666') +
  # scale_color_discrete(name = 'nombre') 
  scale_colour_manual(name = "nombre",   values = c("#ffa700", "#008744", "#d62d20")) +
  xlab("Inversión publicitaria") +
  ylab("# Nuevos usuarios") + 
  labs(title="Análisis de la captación", subtitle= "", caption = "Fuente: Google Analytics") +
  theme_ipsum_rc(grid='', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")

campanas_no_genericas <- campanas_no_genericas %>% mutate(ctr = adClicks / impressions) 

campanas_no_genericas %>%  mutate(returningUsers = users - newUsers) %>% group_by(programa, nombre) %>% 
  summarise(newUsers = sum(newUsers), returningUsers = sum(returningUsers), users = sum(users), adCost=sum(adCost, na.rm=T), bounces=sum(bounces)) %>% ggplot(aes(x=adCost, y=bounces, color=programa)) + geom_point(aes(size = users)) + 
  geom_text_repel(aes(label = factor(nombre)), color = '#212121' ,box.padding = unit(0.55, "lines")) + 
  # geom_label_repel(aes(label = factor(nombre)), box.padding = unit(.55, "lines"),point.padding = unit(0.5, "lines"), segment.color = '#666666') +
  # scale_color_discrete(name = 'nombre') 
  scale_colour_manual(name = "nombre",   values = c("#ffa700", "#008744", "#d62d20")) +
  xlab("Inversión publicitaria") +
  ylab("Rebotes") + 
  labs(title="Análisis de abandonos", subtitle= "", caption = "Fuente: Google Analytics") +
  theme_ipsum_rc(grid='', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")

# Hummm??
campanas_no_genericas %>%  mutate(returningUsers = users - newUsers) %>% group_by(programa, nombre) %>% 
  summarise(newUsers = sum(newUsers), returningUsers = sum(returningUsers), users = sum(users), adCost=sum(adCost, na.rm=T), bounces=sum(bounces)) %>% ggplot(aes(x=newUsers, y=bounces, color=programa)) + geom_point(aes(size = adCost)) + 
  geom_text_repel(aes(label = factor(nombre)), color = '#212121' ,box.padding = unit(0.55, "lines")) + 
  # geom_label_repel(aes(label = factor(nombre)), box.padding = unit(.55, "lines"),point.padding = unit(0.5, "lines"), segment.color = '#666666') +
  # scale_color_discrete(name = 'nombre') 
  scale_colour_manual(name = "nombre",   values = c("#ffa700", "#008744", "#d62d20")) +
  xlab("newUsers") +
  ylab("Rebotes") + 
  labs(title="Análisis de abandonos", subtitle= "", caption = "Fuente: Google Analytics") +
  theme_ipsum_rc(grid='', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")

summary(campanas_no_genericas)

campanas_no_genericas %>% ggplot(aes(x=reorder(factor(nombre),ctr), y=ctr)) + geom_boxplot(aes(color=programa)) + coord_flip() +
  xlab("") +
  ylab("CTR") + 
  labs(title="Click Through Rates", subtitle= "CTR por campaña", caption = "Fuente: Google Analytics") +
  theme_ipsum_rc(grid='Xx', axis=T, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")


# ANOCA

library(gplots) 
plotmeans(newUsers ~ ciudad, data=campanas_no_genericas, digits=2, ccol='red', mean.labels=T, main="Plot of breast cancer means by continent")
aov_campanas_no_genericas <- aov(campanas_no_genericas$newUsers ~ campanas_no_genericas$ciudad)
summary(aov_campanas_no_genericas)

# Good, my F value is 40.28, and p-value is very low too. In other words, the variation of breast cancer means among different continents (numerator) is much larger than the variation of breast cancer within each continents, and our p-value is less than 0.05 (as suggested by normal scientific standard). Hence we can conclude that for our confidence interval we accept the alternative hypothesis H1 that there is a significant relationship between continents and breast cancer.

(tukey <- TukeyHSD(aov_campanas_no_genericas))

plot(tukey)
tukey$`campanas_no_genericas$ciudad`
# mas molong

tky = as.data.frame(tukey$`campanas_no_genericas$ciudad`)
tky$pair = rownames(tky)

# Plot pairwise TukeyHSD comparisons and color by significance level
ggplot(tky, aes(colour=cut(`p adj`, c(0, 0.01, 0.05, 1), 
                           label=c("p<0.01","p<0.05","Non-Sig")))) +
  geom_hline(yintercept=0, lty="11", colour="grey30") +
  geom_errorbar(aes(pair, ymin=lwr, ymax=upr), width=0.2) +
  geom_point(aes(pair, diff)) +
  labs(colour="") + coord_flip() +
  xlab("") +
  ylab("") + 
  labs(title="Adquisción media de usuarios por área", subtitle= "En verde y rojo aquellas áreas con diferencias significativas", caption = "Intervalos de confianza de Tukey con niveles de confianza individuales de 95%") +
  theme_ipsum_rc(grid='Xx', axis=T, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")


######

masters_aw_ds <- campanas_no_genericas %>% dplyr::filter(nombre %in% c("ANALITICA WEB" , "DATA SCIENCE"))


# Son las medias iguales
masters_aw_ds <- masters_aw_ds %>% mutate(ctr = adClicks / impressions) 

masters_aw_ds %>% ggplot(aes(x=reorder(factor(nombre),ctr), y=ctr)) + geom_boxplot(color="#2196F3") + 
  xlab("") +
  ylab("CTR") + 
  labs(title="Comparativa de medias de Click Through Rates", subtitle= "¿Podemos afirmar que los anuncios de #DataScience tienen un CTR menor que los de #AnaliticaWeb?\n", caption = "-¿Son las creatividades o los textos para AW más impactantes?\n-¿Son los futuros científicos de datos menos propensos a realizar click?\n-¿Es más fuerte la competencia en Adwords para DS que para AW?") +
  theme_ipsum_rc(grid='Yy', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")

masters_aw_ds %>% group_by(nombre) %>% summarise(avg_ctr = mean(ctr, na.rm = T))

# Vectores
ctr_aw <- masters_aw_ds %>% filter(nombre == "ANALITICA WEB") %>% dplyr::select(ctr) %>% unlist()

ctr_ds <- masters_aw_ds %>% filter(nombre == "DATA SCIENCE") %>% dplyr::select(ctr) %>% unlist()




plot(density(ctr_aw, na.rm = T))
plot(density(ctr_ds, na.rm = T))

# PLOT AVANZADO
masters_aw_ds %>% dplyr::select(nombre, ctr) %>%  gather(key='nombre', value="ctr") %>% ggplot(aes(x=ctr, color=nombre)) + geom_density(aes(fill=nombre), size=0, alpha=.9, color="red") +
  scale_fill_manual(name = "", values = c('ANALITICA WEB'="#CCCCCC", 'DATA SCIENCE'="#0057e7"), labels = c("ANALITICA WEB", "DATA SCIENCE")) +
  xlab("") +
  ylab("# usuarios") + 
  labs(title="CTR medio por master", subtitle= "", caption = "Fuente: Google Analytics") +
  theme_ipsum_rc(grid='Y', axis=F, ticks = F, grid_col = "#eeeeee") +theme( legend.position = "bottom")

mean(ctr_aw, na.rm = T)
mean(ctr_ds, na.rm = T)

var(ctr_aw, na.rm = T);
var(ctr_ds, na.rm = T)

sd(ctr_aw, na.rm = T)
sd(ctr_ds, na.rm = T)
# $$H_0: \sigma^2_{new} = \sigma^2_{returning}$$ $$H_1: \sigma^2_{new} \neq \sigma^2_{returning}$$

var.test(ctr_aw,ctr_ds)
# El p-value < 0.05, rechazar H0 y por lo tanto ambas varianzas no son iguales. (La variazión de CTR es disinto para cada campaña.)

# $$H_0 = \mathcal{N}(\mu,\,\sigma^{2})$$ $$H_1 \neq \mathcal{N}(\mu,\,\sigma^{2})$$
shapiro.test(ctr_aw); shapiro.test(ctr_ds)
# En ambos casos el p-value es menor que 0.05 , por lo que rechazamos la hipótesis nula de que el número de abandonos sigue una distribución normal en ambos grupos de usuarios.

# No podemos aplicar:
# t.test(ctr ~ nombre, data=masters_aw_ds)
t.test(ctr_aw, ctr_ds)

wilcox.test(ctr_aw, ctr_ds)
# Como el p-value < 0.5, rechazamos la hipótesis nula y por lo tanto ambas poblaciones (camapañas) son disintas

# Aquí análisis como el de wetaca y luego anova con todos los cursos




# AUMNETA EL CPC AL AUMNETAR LOS CLICJS
# Sacar conclusiones sobre la linalidad de las métricas. Nos falta una variable por la cual poder explicar la relación entre cpc y adCost
campanas_no_genericas %>%  ggplot(aes(x=cpc, y =adCost, color=ciudad)) + geom_point() + geom_jitter(width = 0.5, height = 0.5)
plot(costes_por_campana$cpc, costes_por_campana$adCost)