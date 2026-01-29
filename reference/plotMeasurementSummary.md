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
  "measurements_per_subject".

- plotType:

  Type of plot, either "boxplot", "barplot", or "densityplot".

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
#> → Sampling measurement table to 20000 subjects
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> Summarising timings
#> ℹ The following estimates will be calculated:
#> • time: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-29 11:55:12.391813
#> ✔ Summary finished, at 2026-01-29 11:55:12.494636
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-29 11:55:13.019626
#> ✔ Summary finished, at 2026-01-29 11:55:13.115175
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-29 11:55:14.652909
#> ✔ Summary finished, at 2026-01-29 11:55:14.93459
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-01-29 11:55:15.630166
#> ✔ Summary finished, at 2026-01-29 11:55:15.770739
#> → Binding all diagnostic results.

result |>
  filter(variable_name == "time") |>
  plotMeasurementSummary()
#> Ignoring unknown labels:
#> • fill : "Cdm name and Codelist name"


CDMConnector::cdmDisconnect(cdm)
# }
```
