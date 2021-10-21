##########################################################################
# Jose Cajide - @jrcajide
# Primeros pasos con R
##########################################################################


# R como calculadora ------------------------------------------------------

1 + 100

1 + 
  
  4 + 5 * 2

2/10000
2 * 10^(-4)

5e3


# Comparando variables ----------------------------------------------------

1 == 1 
1 != 2
1 < 2
1 <= 1
1 >= -9


# obteniendo ayuda --------------------------------------------------------

?round

# Funciones matemáticas ---------------------------------------------------

pi
round(pi, 0)
round(pi, 4)
floor(pi)
cos(pi) #sin #tan
abs(cos(pi))
log(10)
log10(10)
exp(0.5)


# Tipos de variables ------------------------------------------------------

x <- c(1, 2, 3)
class(x)
length(x)

x <- 1:10
class(x)
length(x)

y <- c(TRUE, TRUE, FALSE, FALSE)
class(y)
length(y)

z <- c("Oro", "Plata", "Bronce", "Cobre")
class(z)
length(z)

z <- c(z, "Platino")
length(z)


# usando secuencias

1:10
seq(10)
seq(1, 10, by = 0.1)

length(1:10)

# ¿Qué ocurre si mezclamos tipos de datos?
# Conversión de formatos
(xx <- c(1.7, "a"))
(xx <- c(TRUE, 2))
(xx <- c("a", TRUE))


# Trabajando con vectores -------------------------------------------------
x <- c(5.4, 6.2, 7.1, 4.8)
x[1]
x[c(3, 1)]
x[1:3]
x[c(1, 1)]

## ------------------------------------------------------------------------
x[-1]
x[-c(1, 5)]

## ------------------------------------------------------------------------
x[c(TRUE, TRUE, FALSE, FALSE)]
x[x > 6]


# NA's --------------------------------------------------------------------
x <- c(1, 2, NA, 4, 5)
x
is.na(x) 
# Aplicación:
x[!is.na(x)]

# Comparación de vectores -------------------------------------------------

x <- c(1, 4, 9, 12)
y <- c(4, 4, 9, 13)
x == y
# Qué  está calculando?
sum(x == y) 

# Y esto?
which(x == y)    

# Y si los combinamos?
x[which(x == y)] 



# Matrices ----------------------------------------------------------------

m <- matrix(nrow = 2, ncol = 2)
m
dim(m)

# Se rellenan por columnas
m <- matrix(1:6, nrow = 2, ncol = 3)
m

# Otras formas de construir matrices
x <- 1:3
y <- 10:12
(cbind(x, y))

# ó
(rbind(x, y))



# listas ------------------------------------------------------------------

# Se crean con list()
x <- list(1, "a", TRUE)
length(x)
x

# Podemos transformar otros objetos a lista con as.list()

## ------------------------------------------------------------------------
xlist <- list(texto = c("Conjunto de datos iris"), secuencia = 1:10, tabla_datos = head(iris))
xlist
length(xlist)
xlist$texto


# variables categóricas ---------------------------------------------------

tallas <- factor(x = c("s", "xl", "m", "m", "xl", "s", "m", "xl", "m"))
levels(tallas)
unique(tallas)

length(levels(tallas)) 
min(tallas)

## ------------------------------------------------------------------------

tallas <- factor(x = c("s", "xl", "m", "m", "xl", "s", "m", "xl", "m"), 
                 levels=c("s", "m", "xl"), 
                 ordered = TRUE)
levels(tallas)
min(tallas) ## Ahora sí
max(tallas)

## ------------------------------------------------------------------------
table(tallas)
barplot(table(tallas))


# dataframes --------------------------------------------------------------

df <- data.frame(letras = letters[1:10], 
                 secuencia = 1:10, 
                 numeros_aleatorios = rnorm(10))
df
# agregar nuevas variables
df$valor_fijo <- 4

## Prueba las siguientes funciones sobre el anterior dataframe
## head()
## tail()
## dim()
## nrow()
## ncol()
## str()
## names()


# Paquetes R --------------------------------------------------------------
# https://github.com/qinwf/awesome-R
installed.packages()
install.packages("tidyverse")
# update.packages()
library(tidyverse)

df <- as_tibble(df)
