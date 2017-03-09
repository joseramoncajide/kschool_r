02-The-Big-Mistake.R
================
The Big Mistake
Fri Mar 10 00:18:59 2017

**¿Por qué no coinciden las métricas de ambos datasets?**

``` r
list.of.packages <- c("tidyverse", "googleAnalyticsR", "knitr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)
```

    ## Loading required package: tidyverse

    ## Warning: package 'tidyverse' was built under R version 3.3.2

    ## Loading tidyverse: ggplot2
    ## Loading tidyverse: tibble
    ## Loading tidyverse: tidyr
    ## Loading tidyverse: readr
    ## Loading tidyverse: purrr
    ## Loading tidyverse: dplyr

    ## Warning: package 'ggplot2' was built under R version 3.3.2

    ## Conflicts with tidy packages ----------------------------------------------

    ## filter(): dplyr, stats
    ## lag():    dplyr, stats

    ## Loading required package: googleAnalyticsR

    ## Loading required package: knitr

    ## Warning: package 'knitr' was built under R version 3.3.2

    ## [[1]]
    ## [1] TRUE
    ## 
    ## [[2]]
    ## [1] TRUE
    ## 
    ## [[3]]
    ## [1] TRUE

``` r
ga_auth()
```

    ## Authenticated

Dataset A
---------

``` r
dataset_a <- as_data_frame(google_analytics(id = "46728973",
                                            start="2016-09-01", end="2017-03-05",
                                            metrics = c("ga:users", "ga:newUsers", "ga:bounces"),
                                            dimensions = c("ga:date, ga:campaign"),
                                            segment = c("sessions::condition::ga:sourceMedium=@google;ga:medium=@cpc"),
                                            sort = c("ga:date"),
                                            max=99999999, 
                                            samplingLevel="HIGHER_PRECISION"))
```

    ## Finding number of results to fetch

    ## Request to profileId: 46728973 (01 - GLOBAL)

    ## Fetched: date campaign users newUsers bounces. [2546] total results out of a possible [2546], Start-Index: 1

    ## All data found. [2546] total results out of a possible [2546]

``` r
dataset_a
```

    ## # A tibble: 2,546 × 5
    ##          date                         campaign users newUsers bounces
    ##        <date>                            <chr> <dbl>    <dbl>   <dbl>
    ## 1  2016-09-01                        (not set)     2        1       1
    ## 2  2016-09-01                        0 - MARCA     5        2       4
    ## 3  2016-09-01  ALI - MASTER - MARKETING ONLINE     1        0       1
    ## 4  2016-09-01     BCN - MASTER - ANALITICA WEB     1        1       1
    ## 5  2016-09-01                BCN - MASTER - UX     1        0       0
    ## 6  2016-09-01        MAD - CURSO - ESTADISTICA     1        1       0
    ## 7  2016-09-01         MAD - CURSO - OPEN STACK     1        1       1
    ## 8  2016-09-01       MAD - CURSO - PROGRAMACION     1        1       1
    ## 9  2016-09-01                  MAD - CURSO - R     1        0       1
    ## 10 2016-09-01 MAD - CURSO - SOLUCIONES NEGOCIO     2        2       2
    ## # ... with 2,536 more rows

### Agrupación manual de datos por campaña

En el dataset A he agrupado los datos por campaña y he sumado todoas las métricas para tener el número total de usuarios, nuevos usuarios y rebotes para todo el periodo

``` r
dataset_a <- dataset_a %>% 
  dplyr::select(-date) %>% 
  group_by(campaign) %>% 
  summarise_all(funs(dataset_a = sum))
```

**Así queda el primer data set**

``` r
dataset_a
```

    ## # A tibble: 38 × 4
    ##                           campaign users_dataset_a newUsers_dataset_a
    ##                              <chr>           <dbl>              <dbl>
    ## 1                        (not set)              11                  8
    ## 2                        0 - MARCA            3534               1836
    ## 3                    0 - MARCA BCN             558                323
    ## 4  ALI - MASTER - MARKETING ONLINE              30                 29
    ## 5     AND - MASTER - ANALITICA WEB               2                  1
    ## 6  AND - MASTER - MARKETING ONLINE               2                  2
    ## 7         AND - MASTER - SEO y SEM              47                 34
    ## 8     BCN - CURSO INT - CRO IGNITE              25                 11
    ## 9     BCN - MASTER - ANALITICA WEB             101                 72
    ## 10 BCN - MASTER - MARKETING ONLINE             100                 91
    ## # ... with 28 more rows, and 1 more variables: bounces_dataset_a <dbl>

Dataset B
---------

### Agrupación automática de datos por campaña

Solicito los datos agrupados a la api. Para ello pido que no dimensione por fecha

``` r
dataset_b <- as_data_frame(google_analytics(id = "46728973",
                                            start="2016-09-01", end="2017-03-05",
                                            metrics = c("ga:users", "ga:newUsers", "ga:bounces"),
                                            dimensions = c("ga:campaign"),
                                            segment = c("sessions::condition::ga:sourceMedium=@google;ga:medium=@cpc"),
                                            max=99999999, 
                                            samplingLevel="HIGHER_PRECISION"))
```

    ## Finding number of results to fetch

    ## Request to profileId: 46728973 (01 - GLOBAL)

    ## Fetched: campaign users newUsers bounces. [38] total results out of a possible [38], Start-Index: 1

    ## All data found. [38] total results out of a possible [38]

``` r
names(dataset_b)[2:4] <- c("users_dataset_b", "newUsers_dataset_b", "bounces_dataset_b")
```

**Y así queda el segundo data set**

``` r
dataset_b
```

    ## # A tibble: 38 × 4
    ##                           campaign users_dataset_b newUsers_dataset_b
    ##                              <chr>           <dbl>              <dbl>
    ## 1                        (not set)              11                  8
    ## 2                        0 - MARCA            2479               1836
    ## 3                    0 - MARCA BCN             418                323
    ## 4  ALI - MASTER - MARKETING ONLINE              30                 29
    ## 5     AND - MASTER - ANALITICA WEB               2                  1
    ## 6  AND - MASTER - MARKETING ONLINE               2                  2
    ## 7         AND - MASTER - SEO y SEM              41                 34
    ## 8     BCN - CURSO INT - CRO IGNITE              14                 11
    ## 9     BCN - MASTER - ANALITICA WEB              91                 72
    ## 10 BCN - MASTER - MARKETING ONLINE              94                 91
    ## # ... with 28 more rows, and 1 more variables: bounces_dataset_b <dbl>

Dataset A+B
-----------

Para facilitar la comparación, he fusionado ambos en un único y he puesto las métricas de dos en dos:

``` r
dataset_a_b <- full_join(dataset_a, dataset_b) %>% 
  dplyr::select(campaign, starts_with('users_'), starts_with('newUsers_'), starts_with('bounces_')) 
```

    ## Joining, by = "campaign"

``` r
knitr::kable(dataset_a_b)
```

| campaign                               |  users\_dataset\_a|  users\_dataset\_b|  newUsers\_dataset\_a|  newUsers\_dataset\_b|  bounces\_dataset\_a|  bounces\_dataset\_b|
|:---------------------------------------|------------------:|------------------:|---------------------:|---------------------:|--------------------:|--------------------:|
| (not set)                              |                 11|                 11|                     8|                     8|                    7|                    7|
| 0 - MARCA                              |               3534|               2479|                  1836|                  1836|                 1278|                 1278|
| 0 - MARCA BCN                          |                558|                418|                   323|                   323|                  169|                  169|
| ALI - MASTER - MARKETING ONLINE        |                 30|                 30|                    29|                    29|                   26|                   26|
| AND - MASTER - ANALITICA WEB           |                  2|                  2|                     1|                     1|                    2|                    2|
| AND - MASTER - MARKETING ONLINE        |                  2|                  2|                     2|                     2|                    2|                    2|
| AND - MASTER - SEO y SEM               |                 47|                 41|                    34|                    34|                   39|                   39|
| BCN - CURSO INT - CRO IGNITE           |                 25|                 14|                    11|                    11|                   19|                   19|
| BCN - MASTER - ANALITICA WEB           |                101|                 91|                    72|                    72|                   74|                   74|
| BCN - MASTER - MARKETING ONLINE        |                100|                 94|                    91|                    91|                   76|                   76|
| BCN - MASTER - SEO y SEM               |                173|                155|                   142|                   142|                  133|                  133|
| BCN - MASTER - UX                      |                205|                193|                   185|                   185|                  152|                  152|
| Competencia                            |                587|                565|                   557|                   557|                  512|                  512|
| MAD - CURSO - APACHE FLINK             |                  2|                  1|                     0|                     0|                    3|                    3|
| MAD - CURSO - ESTADISTICA              |                128|                112|                   104|                   104|                   87|                   87|
| MAD - CURSO - HADOOP & SPARK           |                  2|                  2|                     1|                     1|                    2|                    2|
| MAD - CURSO - INBOUND MK               |                 24|                 21|                    20|                    20|                   17|                   17|
| MAD - CURSO - INTRO BLOCKCHAIN         |                571|                536|                   526|                   526|                  494|                  494|
| MAD - CURSO - MK CONTENIDO PERIODISTAS |                 41|                 39|                    34|                    34|                   29|                   29|
| MAD - CURSO - OPEN STACK               |                 12|                 11|                    10|                    10|                   10|                   10|
| MAD - CURSO - PROGRAMACION             |                 62|                 62|                    58|                    58|                   43|                   43|
| MAD - CURSO - R                        |                 53|                 50|                    40|                    40|                   39|                   39|
| MAD - CURSO - SOLUCIONES NEGOCIO       |                 59|                 56|                    50|                    50|                   45|                   45|
| MAD - CURSO INT - CRO IGNITE           |                 11|                  5|                     1|                     1|                    4|                    4|
| MAD - MASTER - ANALITICA WEB           |                243|                228|                   174|                   174|                  172|                  172|
| MAD - MASTER - BIG DATA                |                337|                319|                   295|                   295|                  255|                  255|
| MAD - MASTER - DATA SCIENCE            |                431|                393|                   329|                   329|                  308|                  308|
| MAD - MASTER - MARKETING ONLINE        |                208|                199|                   187|                   187|                  163|                  163|
| MAD - MASTER - SEO y SEM               |                309|                285|                   250|                   250|                  242|                  242|
| MAD - MASTER - UX                      |                377|                354|                   315|                   315|                  269|                  269|
| NAC - CURSO INT - CRO IGNITE           |                  8|                  7|                     6|                     6|                    7|                    7|
| NAC - MASTER - ANALITICA WEB           |                135|                121|                   100|                   100|                   81|                   81|
| NAC - MASTER - BIG DATA                |                116|                111|                   104|                   104|                   79|                   79|
| NAC - MASTER - DATA SCIENCE            |                175|                168|                   155|                   155|                  116|                  116|
| NAC - MASTER - MARKETING ONLINE        |                114|                110|                   106|                   106|                   72|                   72|
| NAC - MASTER - SEO y SEM               |                300|                274|                   259|                   259|                  231|                  231|
| NAC - MASTER - UX                      |                283|                275|                   260|                   260|                  241|                  241|
| VAL - MASTER - SEO y SEM               |                 55|                 49|                    45|                    45|                   48|                   48|
