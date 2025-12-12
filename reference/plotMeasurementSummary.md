# Plot summariseMeasurementTiming results.

Plot summariseMeasurementTiming results.

## Usage

``` r
plotMeasurementSummary(
  result,
  y = "time",
  plotType = "boxplot",
  timeScale = "days",
  facet = visOmopResults::strataColumns(result),
  colour = c("cdm_name", "codelist_name"),
  style = NULL
)
```

## Arguments

- result:

  A summarised_result object.

- y:

  Variable to plot on y axis, it can be "time" or
  measurements_per_subject".

- plotType:

  Type of plot, either "boxplot" or "densityplot".

- timeScale:

  Time scale to show, it can be "days" or "years".

- facet:

  Columns to facet by. See options with
  \`visOmopResults::plotColumns(result)\`. Formula input is also allowed
  to specify rows and columns.

- colour:

  Columns to color by. See options with
  \`visOmopResults::plotColumns(result)\`.

- style:

  Pre-defined style to apply: "default" or "darwin" - the latter just
  for gt and flextable. If NULL the "default" style is used.

## Value

A ggplot.

## Examples

``` r
# \donttest{
library(MeasurementDiagnostics)
library(dplyr)
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union

cdm <- mockMeasurementDiagnostics()

result <- summariseMeasurementUse(
  cdm = cdm,
  codes = list("test_codelist" = c(3001467L, 45875977L))
)
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> → Summarising results - value as number.
#> → Summarising results - value as concept.
#> → Binding all diagnostic results.

result |>
  filter(variable_name == "time") |>
  plotMeasurementSummary()

CDMConnector::cdmDisconnect(cdm)
# }
```
