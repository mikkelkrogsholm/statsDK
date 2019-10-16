
<!-- README.md is generated from README.Rmd. Please edit that file -->

[![](https://img.shields.io/badge/lifecycle-mature-blue.svg)](https://www.tidyverse.org/lifecycle/#mature)
[![](https://img.shields.io/github/last-commit/mikkelkrogsholm/statsDK.svg)](https://github.com/mikkelkrogsholm/statsDK/commits/master)
[![](https://img.shields.io/badge/devel%20version-0.1.1-blue.svg)](https://github.com/mikkelkrogsholm/statsDK)

[![](https://www.r-pkg.org/badges/version/statsDK?color=orange)](https://cran.r-project.org/package=statsDK)
[![](http://cranlogs.r-pkg.org/badges/grand-total/badger?color=orange)](https://cran.r-project.org/package=badger)

# statsDK

The goal of statsDK is to make it easy to call the API of Statistics
Denmark.

## Installation

You can install statsDK from github with:

``` r
# install.packages("devtools")
devtools::install_github("mikkelkrogsholm/statsDK")
```

## Example

This little vignette shows you how to get started with the `statsDK`
package.

## The retrievers

The package has a few “retriever”-functions that are used to retrieve
data from Statistics Denmark. Those are: `sdk_retrieve_subjects()`,
`sdk_retrieve_tables()`, `sdk_retrieve_metadata()` and the
`sdk_retrieve_data()` functions.

### retrieve\_subjects

This function retrieves the overall subjects that are available in the
API.

### retrieve\_tables

This function retrieves an overview of all the tables in the API. Lets
use it to see what data we would like to
fetch:

``` r
library(statsDK); library(dplyr); library(stringr); library(lubridate); library(ggplot2); library(tidyr)

tables <- sdk_retrieve_tables()

glimpse(tables)
#> Observations: 2,051
#> Variables: 8
#> $ id           <chr> "FOLK1A", "FOLK1B", "FOLK1C", "FOLK1D", "FOLK1E", "…
#> $ text         <chr> "Population at the first day of the quarter", "Popu…
#> $ unit         <chr> "number", "number", "number", "number", "number", "…
#> $ updated      <chr> "2019-08-09T08:00:00", "2019-08-09T08:00:00", "2019…
#> $ firstPeriod  <chr> "2008Q1", "2008Q1", "2008Q1", "2008Q1", "2008Q1", "…
#> $ latestPeriod <chr> "2019Q3", "2019Q3", "2019Q3", "2019Q3", "2019Q3", "…
#> $ active       <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRU…
#> $ variables    <list> [<"region", "sex", "age", "marital status", "time"…
```

Lets say we are interested in marriages. Maybe there is an official data
set about marriages that we can use?

First we unnest the variables column:

``` r
tables_long <- tables %>%
  unnest(variables)
```

Then we see if we can find something with marriage. We use the
`str_detect()` function from the `stringr` package to detect a text
pattern matching marriage:

``` r

marriage_tables <- tables_long %>%
  filter(str_detect(tables_long$variables, "marriage"))

glimpse(marriage_tables)
#> Observations: 10
#> Variables: 8
#> $ id           <chr> "VIEDAG", "VIEDAG", "VIE8", "VIE6", "VIE307", "VIE3…
#> $ text         <chr> "Marriages", "Marriages", "Marriages between two of…
#> $ unit         <chr> "number", "number", "number", "number", "number", "…
#> $ updated      <chr> "2019-02-14T08:00:00", "2019-02-14T08:00:00", "2019…
#> $ firstPeriod  <chr> "2007", "2007", "2007", "2012", "2006", "2006", "20…
#> $ latestPeriod <chr> "2018", "2018", "2018", "2018", "2018", "2018", "20…
#> $ active       <lgl> TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRU…
#> $ variables    <chr> "day of marriage", "month of the marriage", "type o…
```

Indeed there is. There is the `VIEDAG` table that seems to have data on
marriage that we might be interested in. Lets therefore have a look at
the meta data for that particular table.

### retrieve\_metadata

This function retrieves meta data for a table - like our `VIEDAG` table.

``` r
viedag_meta <- sdk_retrieve_metadata("VIEDAG")
#> Metadata collected succesfully

glimpse(viedag_meta)
#> List of 11
#>  $ id                 : chr "VIEDAG"
#>  $ text               : chr "Marriages"
#>  $ description        : chr "Marriages by day of marriage, month of the marriage and time"
#>  $ unit               : chr "number"
#>  $ suppressedDataValue: chr "0"
#>  $ updated            : chr "2019-02-14T08:00:00"
#>  $ active             : logi TRUE
#>  $ contacts           :'data.frame': 1 obs. of  3 variables:
#>   ..$ name : chr "Connie Østberg"
#>   ..$ phone: chr "+4539173384"
#>   ..$ mail : chr "cbn@dst.dk"
#>  $ documentation      :List of 2
#>   ..$ id : chr "fc512ffc-7334-4237-aab9-b776fcc6748c"
#>   ..$ url: chr "https://www.dst.dk/documentationofstatistics/fc512ffc-7334-4237-aab9-b776fcc6748c"
#>  $ footnote           : NULL
#>  $ variables          :'data.frame': 3 obs. of  5 variables:
#>   ..$ id         : chr [1:3] "VDAG" "VIMDR" "Tid"
#>   ..$ text       : chr [1:3] "day of marriage" "month of the marriage" "time"
#>   ..$ elimination: logi [1:3] TRUE TRUE FALSE
#>   ..$ time       : logi [1:3] FALSE FALSE TRUE
#>   ..$ values     :List of 3
#>   .. ..$ :'data.frame':  32 obs. of  2 variables:
#>   .. ..$ :'data.frame':  13 obs. of  2 variables:
#>   .. ..$ :'data.frame':  12 obs. of  2 variables:
```

The list of meta data has a lot of information that we can use to
determine wether or not to use the data. There is an URL under
documentation that we can follow to read a lot more about the data and
how it is collected. There is contact information if we still have
unanswered questions that need to be answered.

And there is also a part of the list called variables. This is the part
we need to determine what we can get from calling that table directly
and also how we should call it. We will use the helper function
`get_variables()` to get a nice tidy tibble to inspect.

``` r
variables <- sdk_get_variables(viedag_meta)

glimpse(variables)
#> Observations: 57
#> Variables: 4
#> $ param       <chr> "VDAG", "VDAG", "VDAG", "VDAG", "VDAG", "VDAG", "VDA…
#> $ setting     <chr> "TOT", "D01", "D02", "D03", "D04", "D05", "D06", "D0…
#> $ type        <chr> "day of marriage", "day of marriage", "day of marria…
#> $ description <chr> "Total", "1.", "2.", "3.", "4.", "5.", "6.", "7.", "…
```

Lets see if we can get a short overview of all the different options we
have. Lets make a tibble for this vignette that shows the first, middle
and last row of each parameter:

``` r
variable_overview <- variables %>% 
  group_by(param) %>%
  slice(c(1, round(n()/2), n())) %>%
  ungroup()

variable_overview
#> # A tibble: 9 x 4
#>   param setting type                  description
#>   <chr> <chr>   <chr>                 <chr>      
#> 1 Tid   2007    time                  2007       
#> 2 Tid   2012    time                  2012       
#> 3 Tid   2018    time                  2018       
#> 4 VDAG  TOT     day of marriage       Total      
#> 5 VDAG  D15     day of marriage       15.        
#> 6 VDAG  D31     day of marriage       31.        
#> 7 VIMDR TOT     month of the marriage Total      
#> 8 VIMDR 005     month of the marriage May        
#> 9 VIMDR 012     month of the marriage December
```

From this overview it looks like `Tid` is the year, `VDAG` is the day of
the month and `VIMDR` is the month. `VDAG` and `VIMDR` also has a `TOT`
that is the total.

With this newfound knowledge we can now construct an API call to get the
data we are interested in.

### retrieve\_data

This is the function that actually retrieves the data that we need.

Lets get the total data for each month of june and december for all the
available years. This forces us to construct an API call that shows
different aspects.

From the variable overview we did earlier we can see that in order to
get the `Total` for days of marriage then we have to use the `TOT`
setting for the `VDAG` parameter. And in order to get the month of
`June` and `December` we will have to use the `006` and `012` setting
for the `VIMDR` parameter. But how do we call all years? Easy, we just
have to set that to be an asterix `*`.

Below is the call to the
API:

``` r
VIEDAG <- sdk_retrieve_data("VIEDAG", Tid = "*", VDAG = "TOT", VIMDR = "006,012")
#> Getting data. This can take a while, if the data is very large.
#> Data collected succesfully
names(VIEDAG) <- c("time", "day", "month", "count")
```

Let us have a glimpse at the data:

``` r
glimpse(VIEDAG)
#> Observations: 24
#> Variables: 4
#> $ time  <dbl> 2007, 2007, 2008, 2008, 2009, 2009, 2010, 2010, 2011, 2011…
#> $ day   <chr> "Total", "Total", "Total", "Total", "Total", "Total", "Tot…
#> $ month <chr> "June", "December", "June", "December", "June", "December"…
#> $ count <dbl> 4486, 2092, 3838, 1894, 3546, 1824, 3396, 1596, 3462, 1394…
```

Finally lets plot it and see what is going on in our new marriage data
set:

``` r

VIEDAG$time <- ymd(paste0(VIEDAG$time, "-01-01"))

my_y <- VIEDAG %>%
  filter(time == max(time)) %>%
  pull(count)

ggplot(VIEDAG) +
  geom_line(aes(x = time, count, group = month)) +
  annotate("text", x = max(VIEDAG$time) %m+% months(1) , y = my_y, 
           label = c("June", "December"), hjust = 0) +
  annotate("point", x = max(VIEDAG$time), y = my_y) +
  xlim(min(VIEDAG$time), max(VIEDAG$time) %m+% years(1) ) +
  labs(y = "Total marriages for the given month", x = "Years") +
  theme_minimal()
```

![](README-unnamed-chunk-10-1.png)<!-- -->

There is quite a spike in the data for December 2012. A lot of people
got married in December in that particular year…

Can you figure out why? Make your own API call that calls all days in
December for all years and see if you can figure out what made that
particular year so different…

## Further ressources

Visit the <http://statbank.dk/> and <http://api.statbank.dk/console> for
further exploration of Statistics Denmark data.
