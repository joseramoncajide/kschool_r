## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----eval=FALSE----------------------------------------------------------
## "a"
## 2
## TRUE

## ------------------------------------------------------------------------
x <- "Hola!"
class(x)
attributes(x)

y <- 1:10
class(y)
length(y)
attributes(y)

z <- c(1, 2, 3)
class(z)



## ------------------------------------------------------------------------
x <- vector()
x

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

series <- 1:10
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
m <- 1:10
dim(m) <- c(2, 5)
m

x <- 1:3
y <- 10:12
(cbind(x, y))

# ó
(rbind(x, y))

# byrow nos permite especificar como rellanar la matriz
mdat <- matrix(c(1,2,3, 11,12,13), nrow = 2, ncol = 3, byrow = TRUE,
               dimnames = list(c("row1", "row2"),
                               c("C.1", "C.2", "C.3")))
mdat



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

# Orden de los factores
tallas <- factor(c("s", "xl", "m", "xl", "s", "m", "xl"))
levels(tallas)
tallas <- factor(tallas, levels=c("s", "m", "xl"))
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
# Names: se aplican a vectores
x <- 1:3
names(x) <- c("a", "b", "c")
x

# a listas
x <- as.list(1:4)
names(x) <- letters[seq(along = x)]
x

# a matrices con dimnames
m <- matrix(1:4, nrow = 2)
dimnames(m) <- list(c("a", "b"), c("c", "d")) # (filas, columnas)
m
dimnames(m)
colnames(m)
rownames(m)


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
x[which(x > 6)]
x[which.max(x)]
x[which.min(x)]

## ------------------------------------------------------------------------
(y <- setNames(x, letters[1:4]))
y[c("d", "c", "a")]
y[c("a", "a", "a")]


## ------------------------------------------------------------------------
x <- as.list(1:12)
x[1:5]
x[[5]]
class(x[[5]])

## ------------------------------------------------------------------------
names(x) <- month.name[1:length(x)] # Les damos un nombre
x
x[["March"]]



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

# Como en las listas
df[c("month", "transacciones")]

# Como en las matrices
df[, c("month", "transacciones")]

