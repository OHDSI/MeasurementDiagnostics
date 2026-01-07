# Plot summariseMeasurementTiming results.

Plot summariseMeasurementTiming results.

## Usage

``` r
plotMeasurementValueAsConcept(
  result,
  x = "count",
  y = "codelist_name",
  facet = c("cdm_name"),
  colour = c("concept_name", "variable_level", visOmopResults::strataColumns(result)),
  style = NULL
)
```

## Arguments

- result:

  A summarised_result object.

- x:

  Columns to use as horizontal axes. See options with
  \`visOmopResults::plotColumns(result)\`.

- y:

  Columns to use as horizontal axes. See options with
  \`visOmopResults::plotColumns(result)\`.

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
#> → Start summary of data, at 2026-01-07 17:49:32.987478
#> ✔ Summary finished, at 2026-01-07 17:49:33.249114
#> → Getting measurements per subject.
#> Summarising subjects
#> ℹ The following estimates will be computed:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-07 17:49:33.820734
#> ✔ Summary finished, at 2026-01-07 17:49:34.061553
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be computed:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-07 17:49:35.431694
#> ✔ Summary finished, at 2026-01-07 17:49:36.097346
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be computed:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-01-07 17:49:36.829132
#> ✔ Summary finished, at 2026-01-07 17:49:37.206758
#> → Binding all diagnostic results.

plotMeasurementValueAsConcept(result)


CDMConnector::cdmDisconnect(cdm)
# }
```
