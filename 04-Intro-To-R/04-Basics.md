Tipos de datos y estructuras en R
================
@jrcajide

Tipos de datos básicos en R
---------------------------

``` r
"a"
2
TRUE
```

### Algunos funciones importantes

-   class() ¿De qué tipo es?
-   length() ¿Qué longitud tiene?
-   attributes() ¿Contiene metadatos?

**Ejemplo:**

``` r
x <- "Hola!"
class(x)
```

    ## [1] "character"

``` r
attributes(x)
```

    ## NULL

``` r
y <- 1:10
class(y)
```

    ## [1] "integer"

``` r
length(y)
```

    ## [1] 10

``` r
attributes(y)
```

    ## NULL

``` r
z <- c(1, 2, 3)
class(z)
```

    ## [1] "numeric"

Estructuras de datos
--------------------

### Vectores

``` r
x <- vector()
x
```

    ## logical(0)

#### Creación de vectores

``` r
x <- c(1, 2, 3)
x
```

    ## [1] 1 2 3

``` r
length(x)
```

    ## [1] 3

``` r
x1 <- c(1, 2, 3)
y <- c(TRUE, TRUE, FALSE, FALSE)
z <- c("Oro", "Plata", "Bronce", "Cobre")
class(z)
```

    ## [1] "character"

``` r
z <- c(z, "Platino")
z
```

    ## [1] "Oro"     "Plata"   "Bronce"  "Cobre"   "Platino"

``` r
x <- c(0.5, 0.7)
x <- c(TRUE, FALSE)
x <- c("a", "b", "c", "d", "e")
x <- 9:100

# usando secuencias

series <- 1:10
seq(10)
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10

``` r
seq(1, 10, by = 0.1)
```

    ##  [1]  1.0  1.1  1.2  1.3  1.4  1.5  1.6  1.7  1.8  1.9  2.0  2.1  2.2  2.3
    ## [15]  2.4  2.5  2.6  2.7  2.8  2.9  3.0  3.1  3.2  3.3  3.4  3.5  3.6  3.7
    ## [29]  3.8  3.9  4.0  4.1  4.2  4.3  4.4  4.5  4.6  4.7  4.8  4.9  5.0  5.1
    ## [43]  5.2  5.3  5.4  5.5  5.6  5.7  5.8  5.9  6.0  6.1  6.2  6.3  6.4  6.5
    ## [57]  6.6  6.7  6.8  6.9  7.0  7.1  7.2  7.3  7.4  7.5  7.6  7.7  7.8  7.9
    ## [71]  8.0  8.1  8.2  8.3  8.4  8.5  8.6  8.7  8.8  8.9  9.0  9.1  9.2  9.3
    ## [85]  9.4  9.5  9.6  9.7  9.8  9.9 10.0

``` r
length(1:10)
```

    ## [1] 10

``` r
# ¿Qué ocurre si mezclamos tipos de datos?
# coercion
(xx <- c(1.7, "a"))
```

    ## [1] "1.7" "a"

``` r
(xx <- c(TRUE, 2))
```

    ## [1] 1 2

``` r
(xx <- c("a", TRUE))
```

    ## [1] "a"    "TRUE"

### Matrices

``` r
m <- matrix(nrow = 2, ncol = 2)
m
```

    ##      [,1] [,2]
    ## [1,]   NA   NA
    ## [2,]   NA   NA

``` r
dim(m)
```

    ## [1] 2 2

``` r
# Se rellenan por columnas
m <- matrix(1:6, nrow = 2, ncol = 3)
m
```

    ##      [,1] [,2] [,3]
    ## [1,]    1    3    5
    ## [2,]    2    4    6

``` r
# Otras formas de construir matrices
m <- 1:10
dim(m) <- c(2, 5)
m
```

    ##      [,1] [,2] [,3] [,4] [,5]
    ## [1,]    1    3    5    7    9
    ## [2,]    2    4    6    8   10

``` r
x <- 1:3
y <- 10:12
(cbind(x, y))
```

    ##      x  y
    ## [1,] 1 10
    ## [2,] 2 11
    ## [3,] 3 12

``` r
# ó
(rbind(x, y))
```

    ##   [,1] [,2] [,3]
    ## x    1    2    3
    ## y   10   11   12

``` r
# byrow nos permite especificar como rellanar la matriz
mdat <- matrix(c(1,2,3, 11,12,13), nrow = 2, ncol = 3, byrow = TRUE,
               dimnames = list(c("row1", "row2"),
                               c("C.1", "C.2", "C.3")))
mdat
```

    ##      C.1 C.2 C.3
    ## row1   1   2   3
    ## row2  11  12  13

### Listas

``` r
# Se crean con list()
x <- list(1, "a", TRUE)
x
```

    ## [[1]]
    ## [1] 1
    ## 
    ## [[2]]
    ## [1] "a"
    ## 
    ## [[3]]
    ## [1] TRUE

``` r
# Podemos transformar otros objetos a lista con as.list()

x <- 1:10
x <- as.list(x)
x
```

    ## [[1]]
    ## [1] 1
    ## 
    ## [[2]]
    ## [1] 2
    ## 
    ## [[3]]
    ## [1] 3
    ## 
    ## [[4]]
    ## [1] 4
    ## 
    ## [[5]]
    ## [1] 5
    ## 
    ## [[6]]
    ## [1] 6
    ## 
    ## [[7]]
    ## [1] 7
    ## 
    ## [[8]]
    ## [1] 8
    ## 
    ## [[9]]
    ## [1] 9
    ## 
    ## [[10]]
    ## [1] 10

``` r
length(x)
```

    ## [1] 10

**Ejemplo:**

``` r
xlist <- list(a = "Conjunto de datos iris", b = 1:10, data = head(iris))
xlist
```

    ## $a
    ## [1] "Conjunto de datos iris"
    ## 
    ## $b
    ##  [1]  1  2  3  4  5  6  7  8  9 10
    ## 
    ## $data
    ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
    ## 1          5.1         3.5          1.4         0.2  setosa
    ## 2          4.9         3.0          1.4         0.2  setosa
    ## 3          4.7         3.2          1.3         0.2  setosa
    ## 4          4.6         3.1          1.5         0.2  setosa
    ## 5          5.0         3.6          1.4         0.2  setosa
    ## 6          5.4         3.9          1.7         0.4  setosa

``` r
xlist$b
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10

### Factores

``` r
sexo <- factor(c("masculino", "femenino", "femenino", "masculino"))
levels(sexo)
```

    ## [1] "femenino"  "masculino"

``` r
nlevels(sexo)
```

    ## [1] 2

``` r
# Orden de los factores
tallas <- factor(c("s", "xl", "m", "xl", "s", "m", "xl"))
levels(tallas)
```

    ## [1] "m"  "s"  "xl"

``` r
tallas <- factor(tallas, levels=c("s", "m", "xl"))
levels(tallas)
```

    ## [1] "s"  "m"  "xl"

**¿Podemos saber cuál es la talla más pequeña?**

``` r
min(tallas)
```

``` r
tallas <- factor(tallas, levels=c("s", "m", "xl"), ordered = TRUE)
levels(tallas)
```

    ## [1] "s"  "m"  "xl"

``` r
min(tallas) ## Ahora sí
```

    ## [1] s
    ## Levels: s < m < xl

**Muy útil: Tabla de contingencia**

``` r
table(tallas)
```

    ## tallas
    ##  s  m xl 
    ##  2  2  3

**Podemos convertir una variable categórica en texto:**

``` r
as.character(tallas)
```

    ## [1] "s"  "xl" "m"  "xl" "s"  "m"  "xl"

### Dataframes

``` r
df <- data.frame(id = letters[1:10], x = 1:10, y = rnorm(10))
df
```

    ##    id  x          y
    ## 1   a  1  0.4845411
    ## 2   b  2  0.9504657
    ## 3   c  3  1.2096347
    ## 4   d  4  1.5591655
    ## 5   e  5  0.3186032
    ## 6   f  6 -0.2962901
    ## 7   g  7 -0.2319464
    ## 8   h  8  0.1176230
    ## 9   i  9  0.1318751
    ## 10  j 10  0.1728070

``` r
# agregar nuevas variables
cbind(df, data.frame(z = 4))
```

    ##    id  x          y z
    ## 1   a  1  0.4845411 4
    ## 2   b  2  0.9504657 4
    ## 3   c  3  1.2096347 4
    ## 4   d  4  1.5591655 4
    ## 5   e  5  0.3186032 4
    ## 6   f  6 -0.2962901 4
    ## 7   g  7 -0.2319464 4
    ## 8   h  8  0.1176230 4
    ## 9   i  9  0.1318751 4
    ## 10  j 10  0.1728070 4

**Funciones útiles:**

``` r
head()
tail()
dim()
nrow()
ncol()
str()
names()
```

**Ejemplos:**

``` r
# Names: se aplican a vectores
x <- 1:3
names(x) <- c("a", "b", "c")
x
```

    ## a b c 
    ## 1 2 3

``` r
# a listas
x <- as.list(1:4)
names(x) <- letters[seq(along = x)]
x
```

    ## $a
    ## [1] 1
    ## 
    ## $b
    ## [1] 2
    ## 
    ## $c
    ## [1] 3
    ## 
    ## $d
    ## [1] 4

``` r
# a matrices con dimnames
m <- matrix(1:4, nrow = 2)
dimnames(m) <- list(c("a", "b"), c("c", "d")) # (filas, columnas)
m
```

    ##   c d
    ## a 1 3
    ## b 2 4

``` r
dimnames(m)
```

    ## [[1]]
    ## [1] "a" "b"
    ## 
    ## [[2]]
    ## [1] "c" "d"

``` r
colnames(m)
```

    ## [1] "c" "d"

``` r
rownames(m)
```

    ## [1] "a" "b"

### Missing values

``` r
x <- c(1, 2, NA, 4, 5)
x
```

    ## [1]  1  2 NA  4  5

``` r
is.na(x) 
```

    ## [1] FALSE FALSE  TRUE FALSE FALSE

Subset
------

### Sobre vectores

**Usando enteros positivos**

``` r
x <- c(5.4, 6.2, 7.1, 4.8)
x[1]
```

    ## [1] 5.4

``` r
x[c(3, 1)]
```

    ## [1] 7.1 5.4

``` r
x[1:3]
```

    ## [1] 5.4 6.2 7.1

``` r
x[c(1, 1)]
```

    ## [1] 5.4 5.4

**Usando enteros negativos**

``` r
x[-1]
```

    ## [1] 6.2 7.1 4.8

``` r
x[-c(1, 5)]
```

    ## [1] 6.2 7.1 4.8

**Usando valores lógicos**

``` r
x[c(TRUE, TRUE, FALSE, FALSE)]
```

    ## [1] 5.4 6.2

``` r
x[x > 6]
```

    ## [1] 6.2 7.1

``` r
x[which(x > 6)]
```

    ## [1] 6.2 7.1

``` r
x[which.max(x)]
```

    ## [1] 7.1

``` r
x[which.min(x)]
```

    ## [1] 4.8

**Referenciando objetos por sus nombres**

``` r
(y <- setNames(x, letters[1:4]))
```

    ##   a   b   c   d 
    ## 5.4 6.2 7.1 4.8

``` r
y[c("d", "c", "a")]
```

    ##   d   c   a 
    ## 4.8 7.1 5.4

``` r
y[c("a", "a", "a")]
```

    ##   a   a   a 
    ## 5.4 5.4 5.4

### Sobre listas

**Usando enteros**

``` r
x <- as.list(1:12)
x[1:5]
```

    ## [[1]]
    ## [1] 1
    ## 
    ## [[2]]
    ## [1] 2
    ## 
    ## [[3]]
    ## [1] 3
    ## 
    ## [[4]]
    ## [1] 4
    ## 
    ## [[5]]
    ## [1] 5

``` r
x[[5]]
```

    ## [1] 5

``` r
class(x[[5]])
```

    ## [1] "integer"

**Por su nombre**

``` r
names(x) <- month.name[1:length(x)] # Les damos un nombre
x
```

    ## $January
    ## [1] 1
    ## 
    ## $February
    ## [1] 2
    ## 
    ## $March
    ## [1] 3
    ## 
    ## $April
    ## [1] 4
    ## 
    ## $May
    ## [1] 5
    ## 
    ## $June
    ## [1] 6
    ## 
    ## $July
    ## [1] 7
    ## 
    ## $August
    ## [1] 8
    ## 
    ## $September
    ## [1] 9
    ## 
    ## $October
    ## [1] 10
    ## 
    ## $November
    ## [1] 11
    ## 
    ## $December
    ## [1] 12

``` r
x[["March"]]
```

    ## [1] 3

### De matrices

``` r
a <- matrix(1:9, nrow = 3)
colnames(a) <- c("A", "B", "C")
a
```

    ##      A B C
    ## [1,] 1 4 7
    ## [2,] 2 5 8
    ## [3,] 3 6 9

``` r
a[1:2, ]
```

    ##      A B C
    ## [1,] 1 4 7
    ## [2,] 2 5 8

``` r
a[c(T, F, T), c("B", "A")]
```

    ##      B A
    ## [1,] 4 1
    ## [2,] 6 3

``` r
a[0, -2]
```

    ##      A C

### De data frames

``` r
df <-
  data.frame(
    month = month.name[1:12],
    sesiones = round(rnorm(12, mean = 400, sd = 10), 2),
    transacciones = round(rnorm(12, mean = 20, sd = 4), 2)
  )
str(df)
```

    ## 'data.frame':    12 obs. of  3 variables:
    ##  $ month        : Factor w/ 12 levels "April","August",..: 5 4 8 1 9 7 6 2 12 11 ...
    ##  $ sesiones     : num  405 409 403 405 404 ...
    ##  $ transacciones: num  23.9 13.1 24.7 14.7 22.4 ...

``` r
df[df$sesiones < 400, ]
```

    ##      month sesiones transacciones
    ## 7     July   395.23         18.64
    ## 8   August   397.93         14.32
    ## 10 October   392.38         18.60

``` r
df[c(1, 3), ]
```

    ##     month sesiones transacciones
    ## 1 January   404.64         23.91
    ## 3   March   402.99         24.66

``` r
# Como en las listas
df[c("month", "transacciones")]
```

    ##        month transacciones
    ## 1    January         23.91
    ## 2   February         13.13
    ## 3      March         24.66
    ## 4      April         14.70
    ## 5        May         22.38
    ## 6       June         21.73
    ## 7       July         18.64
    ## 8     August         14.32
    ## 9  September         21.51
    ## 10   October         18.60
    ## 11  November         20.23
    ## 12  December         18.94

``` r
# Como en las matrices
df[, c("month", "transacciones")]
```

    ##        month transacciones
    ## 1    January         23.91
    ## 2   February         13.13
    ## 3      March         24.66
    ## 4      April         14.70
    ## 5        May         22.38
    ## 6       June         21.73
    ## 7       July         18.64
    ## 8     August         14.32
    ## 9  September         21.51
    ## 10   October         18.60
    ## 11  November         20.23
    ## 12  December         18.94
