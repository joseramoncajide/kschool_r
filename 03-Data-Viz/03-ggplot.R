###########################################################################
# @jrcajide, 2017-03
# ggplot
##########################################################################

# Intalación y carga de librerías necesarias ------------------------------

list.of.packages <- c("tidyverse", "RColorBrewer", "ggthemes", "scales")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)


# El lenguaje ggplot ------------------------------------------------------

# https://www.rstudio.com/wp-content/uploads/2016/12/ggplot2-cheatsheet-2.1-Spanish.pdf

ggplot()

(vector_y <- sample(10)) # Variable dependiente
(vector_x <- sample(10)) # Variable independiente

ggplot(mapping = aes(y = vector_y, x = vector_x))

ggplot(mapping = aes(y = vector_y, x = vector_x))  + geom_point()



# Importamos datos --------------------------------------------------------

mis_datos <- read_csv('03-Data-Viz/data/adwords.csv')

summary(mis_datos)

dim(mis_datos)

View(mis_datos)


# Basics ------------------------------------------------------------------

ggplot(mis_datos, aes(y = adClicks, x = impressions))

ggplot(mis_datos, aes(y = adClicks, x = impressions)) + geom_point()

ggplot(mis_datos, aes(y = adClicks, x = impressions, color = nombre)) + geom_point()

# EJ. Asigna el color a la variable programa
ggplot(mis_datos, aes(y = adClicks, x = impressions, color = programa)) + geom_point()

#¿Qué pasa si asignas un shape a una varible discreta con muchos valores?
ggplot(mis_datos, aes(y = adClicks, x = impressions, shape = nombre)) + geom_point() 

# ¿y aquí?
ggplot(mis_datos, aes(y = adClicks, x = impressions, size = nombre)) + geom_point() 

# Usando una variable cuantitativa
ggplot(mis_datos, aes(y = adClicks, x = impressions, size = ctr)) + geom_point() 


ggplot(mis_datos, aes(y = adClicks, x = impressions, alpha = ctr)) + geom_point() 


#Podemos combinar varias propiedades 'aesthetics' en un mismo gráfico.
ggplot(mis_datos, aes(y = adClicks, x = impressions, color = programa, size = ctr)) + geom_point()


# geoms -------------------------------------------------------------------
# Tipos de gráficos o de objetos geométricos

#Geometric objects: Variables continuas

ggplot(mis_datos, aes(y = adClicks, x = impressions)) + geom_line()
ggplot(mis_datos, aes(y = adClicks, x = impressions)) + geom_smooth()
ggplot(mis_datos, aes(y = adClicks, x = impressions)) + geom_point() + geom_smooth()


# Geometric objects: Variables discretas
ggplot(mis_datos, aes(y = adClicks, x = programa)) + geom_bar(stat="identity")
ggplot(mis_datos, aes(y = adClicks, x = programa, fill = ciudad)) + geom_bar(stat="identity")
ggplot(mis_datos, aes(y = adClicks, x = programa, fill = ciudad)) + geom_bar(stat="identity", position = 'dodge')
ggplot(mis_datos, aes(y = adClicks, x = programa, fill = ciudad)) + geom_bar(stat="identity", position = 'fill') 

ggplot(mis_datos, aes(x = factor(1), fill = ciudad)) + geom_bar(width = 1) 
ggplot(mis_datos, aes(x = factor(1), fill = ciudad)) + geom_bar(width = 1) + coord_polar(theta = "y")

#Ejercicio: Dibuja el siguiente gráfico y transfórmalo en un boxplot. Ayuda: http://docs.ggplot2.org/current/
ggplot(mis_datos, aes(y = adClicks, x = programa)) + geom_boxplot()

ggplot(mis_datos, aes(y = adClicks, x = programa)) + geom_violin()

# faceting ----------------------------------------------------------------

ggplot(mis_datos, aes(y = adClicks, x = impressions)) + 
  geom_point() + 
  geom_smooth(method = 'lm') +
  facet_wrap(~ ciudad) 

ggplot(mis_datos, aes(y = adClicks, x = impressions)) + 
  geom_point() + 
  geom_smooth(method = 'lm') +
  facet_wrap( ~ nombre, scales = "free") 


# Superposición de puntos

ggplot(mis_datos, aes(y = adClicks, x = impressions, color = programa)) + geom_point()

ggplot(mis_datos, aes(y = adClicks, x = impressions, color = programa)) + geom_point(position = 'jitter')

ggplot(mis_datos, aes(y = adClicks, x = impressions, color = programa)) + geom_jitter(width = 0.8, height = 0.8)




# Mejorando lo gráficos ---------------------------------------------------
# Creamos un nuevo conjunto de datos

nuevos_usuarios <- mis_datos %>% 
  group_by(nombre, programa) %>% 
  summarise(newUsers = sum(newUsers)) 

ggplot(nuevos_usuarios, aes(x = nombre, y = newUsers, fill = programa)) +
  geom_bar(stat = 'identity') +
  coord_flip()


# reorder -----------------------------------------------------------------

#El eje X se ordena alfabéticamente, un problema p.e. en cambios de idiomas de las etiquetas

ggplot(nuevos_usuarios, aes(x = reorder(nombre, newUsers), y = newUsers, fill = programa)) + 
  geom_bar(stat = 'identity') + 
  coord_flip()

# color schemes -----------------------------------------------------------

base <- ggplot(nuevos_usuarios, aes(x = reorder(nombre, newUsers), y = newUsers, fill = programa)) + 
  geom_bar(stat = 'identity') + 
  coord_flip()

base

base + scale_fill_brewer()

base + scale_fill_brewer(palette = "Blues")

display.brewer.all()

# Ej. Probar con otras paletas de colores

base + scale_fill_brewer(palette = "Set1")

# themes ------------------------------------------------------------------

base + theme_grey()

base + theme_bw()

base + theme_minimal() + scale_fill_brewer(palette = "Set1")

#Crear nuestros propios temas
base + theme(panel.border=element_rect(color = 'white', fill = NA), 
             panel.background = element_rect(color = 'white', fill = NA) )

base + theme_grey()  + theme_minimal() + scale_fill_brewer(palette = "Set1") + theme(
  axis.title.x = element_text(size = 13), 
  text = element_text(family="Arial", colour="grey50", size=12),
  panel.grid.major.y = element_blank(),
  panel.grid.minor.y = element_blank(),  
  panel.grid.major.x = element_blank(),
  panel.grid.minor.x = element_blank()
) 

# Con ggthemes: library("ggthemes")

base + theme_excel() + scale_fill_excel()

base + theme_economist() + scale_fill_economist()

base + theme_wsj() + scale_fill_wsj(palette = "black_green")

base + theme_tufte() + scale_fill_tableau()

# labels and legends ------------------------------------------------------

(base <- base + ylab("Usuarios") + xlab("Cursos y masters"))

(base <- base + geom_text(aes(label=newUsers, hjust=-.2), size=3.9))

# scales

base + scale_y_log10()
base + scale_y_sqrt()
base + scale_y_continuous(labels = scales::percent)


# titles and captions -----------------------------------------------------

base <- base + labs(title="Rendimiento de la campañas", 
            subtitle= "Volmen de nuevos usuarios adquiridos por campaña", 
            caption = "Fuente: Google Analytics")

# saving plots ------------------------------------------------------------

final <- base + 
  theme_minimal() + 
  scale_fill_brewer(palette = "Set1") + 
  theme(legend.position = "bottom")

ggsave("my_plot.png", final)
ggsave("my_plot.pdf", final)
ggsave("my_plot.png", width = 6, height = 4)




