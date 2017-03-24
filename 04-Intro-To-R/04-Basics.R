## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----eval=FALSE----------------------------------------------------------
## "a"
## 2
## TRUE

## ------------------------------------------------------------------------
x <- "Hola!"
class(x)

y <- 1:10
class(y)
length(y)

z <- c(1, 2, 3)
class(z)


## ------------------------------------------------------------------------
x <- c(1, 2, 3)
x
length(x)
x1 <- c(1, 2, 3)
y <- c(TRUE, TRUE, FALSE, FALSE)
z <- c("Oro", "Plata", "Bronce", "Cobre")
class(z)

z <- c(z, "Platino")
z

x <- c(0.5, 0.7)
x <- c(TRUE, FALSE)
x <- c("a", "b", "c", "d", "e")
x <- 9:100

# usando secuencias

1:10
seq(10)
seq(1, 10, by = 0.1)

length(1:10)

# ¿Qué ocurre si mezclamos tipos de datos?
# coercion
(xx <- c(1.7, "a"))
(xx <- c(TRUE, 2))
(xx <- c("a", TRUE))



## ------------------------------------------------------------------------
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


## ------------------------------------------------------------------------

# Se crean con list()
x <- list(1, "a", TRUE)
x

# Podemos transformar otros objetos a lista con as.list()

x <- 1:10
x <- as.list(x)
x
length(x)

## ------------------------------------------------------------------------
xlist <- list(a = "Conjunto de datos iris", b = 1:10, data = head(iris))
xlist
xlist$b

## ------------------------------------------------------------------------
sexo <- factor(c("masculino", "femenino", "femenino", "masculino"))
levels(sexo)
nlevels(sexo)
length(levels(sexo))

# Orden de los factores
tallas <- factor(c("s", "xl", "m", "xl", "s", "m", "xl"))
levels(tallas)



## ----eval=FALSE----------------------------------------------------------
## min(tallas)

## ------------------------------------------------------------------------

tallas <- factor(tallas, levels=c("s", "m", "xl"), ordered = TRUE)
levels(tallas)
min(tallas) ## Ahora sí


## ------------------------------------------------------------------------
table(tallas)

## ------------------------------------------------------------------------
as.character(tallas)

## ------------------------------------------------------------------------
df <- data.frame(id = letters[1:10], x = 1:10, y = rnorm(10))
df
# agregar nuevas variables
cbind(df, data.frame(z = 4))

## ----eval=FALSE----------------------------------------------------------
## head()
## tail()
## dim()
## nrow()
## ncol()
## str()
## names()

## ------------------------------------------------------------------------
x <- c(1, 2, NA, 4, 5)
x
is.na(x) 


## ------------------------------------------------------------------------
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

## ------------------------------------------------------------------------
x <- as.list(1:12)
x[1:5]
x[[5]]

## ------------------------------------------------------------------------
a <- matrix(1:9, nrow = 3)
colnames(a) <- c("A", "B", "C")
a
a[1:2, ]
a[c(T, F, T), c("B", "A")]
a[0, -2]

## ------------------------------------------------------------------------
df <-
  data.frame(
    month = month.name[1:12],
    sesiones = round(rnorm(12, mean = 400, sd = 10), 2),
    transacciones = round(rnorm(12, mean = 20, sd = 4), 2)
  )
str(df)

df[df$sesiones < 400, ]
df[c(1, 3), ]

df[, c("month", "transacciones")]
# df[c("month", "transacciones")]



