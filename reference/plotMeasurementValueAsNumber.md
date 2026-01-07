# Plot summariseMeasurementTiming results.

Plot summariseMeasurementTiming results.

## Usage

``` r
plotMeasurementValueAsNumber(
  result,
  x = "unit_concept_name",
  plotType = "boxplot",
  facet = c("codelist_name", "concept_name"),
  colour = c("cdm_name", "unit_concept_name", visOmopResults::strataColumns(result)),
  style = NULL
)
```

## Arguments

- result:

  A summarised_result object.

- x:

  Columns to use as horizontal axes. See options with
  \`visOmopResults::plotColumns(result)\`.

- plotType:

  Type of plot, either "boxplot", "barplot", or "densityplot".

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

cdm <- mockMeasurementDiagnostics()

result <- summariseMeasurementUse(
  cdm = cdm,
  bySex = TRUE,
  codes = list("test_codelist" = c(3001467L, 45875977L))
)
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> Summarising timings
#> ℹ The following estimates will be computed:
#> • time: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-07 17:49:45.713848
#> ✔ Summary finished, at 2026-01-07 17:49:45.994068
#> → Getting measurements per subject.
#> Summarising subjects
#> ℹ The following estimates will be computed:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-07 17:49:46.5679
#> ✔ Summary finished, at 2026-01-07 17:49:46.834292
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be computed:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-07 17:49:48.182871
#> ✔ Summary finished, at 2026-01-07 17:49:48.850064
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be computed:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-01-07 17:49:49.564574
#> ✔ Summary finished, at 2026-01-07 17:49:50.099433
#> → Binding all diagnostic results.

plotMeasurementValueAsNumber(result)
#> Ignoring unknown labels:
#> • fill : "Cdm name, Unit concept name and Sex"


CDMConnector::cdmDisconnect(cdm)
# }
```
