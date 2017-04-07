Tipos de datos y estructuras en R
================
@jrcajide

Tipos de datos básicos en R
---------------------------

``` r
# Esto es un comentario
"a"
2
TRUE
```

### Funciones

-   c()
-   length() ¿Qué longitud tiene?
-   class() ¿De qué tipo es?
-   paste()
-   seq()
-   sum()

**Ejemplo:**

``` r
x <- "hola!"
class(x)
```

    ## [1] "character"

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
z <- c(1, 2, 3)
class(z)
```

    ## [1] "numeric"

**Cargando nuevas funciones**

``` r
# install.packages("stringr")
library(stringr)
```

    ## Warning: package 'stringr' was built under R version 3.3.2

``` r
str_length(x)
```

    ## [1] 5

``` r
str_to_upper(x)
```

    ## [1] "HOLA!"

``` r
str_to_title(x)
```

    ## [1] "Hola!"

**Creando nuestras funciones**

``` r
suma <- function(a, b) {
  
  respuesta <- a + b

  return (respuesta)
}

suma(3, 6)
```

    ## [1] 9

``` r
# Afortunadamente :)

sum(3,6)
```

    ## [1] 9

Estructuras de datos
--------------------

#### Vectores

``` r
dispositivos <- c('Mobile', 'Tablet')
print(dispositivos) 
```

    ## [1] "Mobile" "Tablet"

``` r
mas.dispositivos <- c(dispositivos, 'Desktop')
print(mas.dispositivos)
```

    ## [1] "Mobile"  "Tablet"  "Desktop"

``` r
# Indexing
dispositivo_tablet <- dispositivos[2]
print(dispositivo_tablet)
```

    ## [1] "Tablet"

``` r
dispositivos <- c('Mobile', 'Tablet', 'Desktop')
todos.menos.tablet <- dispositivos[-2]  
dispositivos[c(2, 3)]
```

    ## [1] "Tablet"  "Desktop"

``` r
indices <- c(2, 3)
dispositivos[indices]
```

    ## [1] "Tablet"  "Desktop"

``` r
navegadores <- c('Chrome', 'Safari', 'Explorer', 'Firefox', 'Lynx', 'Opera')
navegadores[2:5]
```

    ## [1] "Safari"   "Explorer" "Firefox"  "Lynx"

``` r
tamano.pantallas <- c(7, 6.5, 4, 11, 8)
tamano.pantallas[c(TRUE, FALSE, FALSE, TRUE, TRUE)]
```

    ## [1]  7 11  8

``` r
pantalla.es.grande <- tamano.pantallas > 6.5
pantallas.grandes <- tamano.pantallas[ pantalla.es.grande ] 

tamano.pantallas[tamano.pantallas > 6.5] 
```

    ## [1]  7 11  8

``` r
# Modificando un vector
medios <- c('', 'Buscadores', 'Mail')
medios[3] <- 'Email'
medios[c(1,2)] <- c('Directo', 'Organic')

# Operaciones vectorizadas

v1 <- c(1, 1, 1, 1, 1)
v2 <- c(1, 2, 3, 4, 5)

v1 + v2  
```

    ## [1] 2 3 4 5 6

``` r
v1 - v2  
```

    ## [1]  0 -1 -2 -3 -4

``` r
v1 * v2  
```

    ## [1] 1 2 3 4 5

``` r
v1 / v2
```

    ## [1] 1.0000000 0.5000000 0.3333333 0.2500000 0.2000000

``` r
v3 <- v1 + v1 

v4 <- (v1 + v2) / v3
```

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
length(levels(sexo))
```

    ## [1] 2

``` r
# Orden de los factores
tallas <- factor(c("s", "xl", "m", "xl", "s", "m", "xl"))
levels(tallas)
```

    ## [1] "m"  "s"  "xl"

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

### Dataframes

``` r
df <- data.frame(id = letters[1:10], x = 1:10, y = rnorm(10))
df
```

    ##    id  x           y
    ## 1   a  1  1.52440667
    ## 2   b  2 -0.93409308
    ## 3   c  3  1.87509944
    ## 4   d  4  0.03558504
    ## 5   e  5  0.24471947
    ## 6   f  6 -0.60568154
    ## 7   g  7 -1.19267434
    ## 8   h  8 -0.12182857
    ## 9   i  9 -1.15942674
    ## 10  j 10 -0.22898682

``` r
# agregar nuevas variables
cbind(df, data.frame(z = 4))
```

    ##    id  x           y z
    ## 1   a  1  1.52440667 4
    ## 2   b  2 -0.93409308 4
    ## 3   c  3  1.87509944 4
    ## 4   d  4  0.03558504 4
    ## 5   e  5  0.24471947 4
    ## 6   f  6 -0.60568154 4
    ## 7   g  7 -1.19267434 4
    ## 8   h  8 -0.12182857 4
    ## 9   i  9 -1.15942674 4
    ## 10  j 10 -0.22898682 4

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

**Subset**

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
    ##  $ sesiones     : num  404 381 389 398 387 ...
    ##  $ transacciones: num  20.9 20.2 18.6 20.9 24.3 ...

``` r
df[df$sesiones < 400, ]
```

    ##        month sesiones transacciones
    ## 2   February   381.39         20.21
    ## 3      March   388.83         18.56
    ## 4      April   398.00         20.90
    ## 5        May   387.22         24.30
    ## 6       June   393.03         15.63
    ## 8     August   399.40         27.22
    ## 9  September   399.11         24.02
    ## 10   October   390.16         15.99

``` r
df[c(1, 3), ]
```

    ##     month sesiones transacciones
    ## 1 January   404.28         20.88
    ## 3   March   388.83         18.56

``` r
df[, c("month", "transacciones")]
```

    ##        month transacciones
    ## 1    January         20.88
    ## 2   February         20.21
    ## 3      March         18.56
    ## 4      April         20.90
    ## 5        May         24.30
    ## 6       June         15.63
    ## 7       July         20.17
    ## 8     August         27.22
    ## 9  September         24.02
    ## 10   October         15.99
    ## 11  November         23.64
    ## 12  December         15.99

``` r
# df[c("month", "transacciones")]
```
