# Plot summariseMeasurementTiming results.

Plot summariseMeasurementTiming results.

## Usage

``` r
plotMeasurementValueAsNumeric(
  result,
  x = c("unit_concept_name"),
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

  Type of plot, either "boxplot" or "densityplot".

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
#> Warning: ! 2 casted column in measurement as do not match expected column type:
#> • `value_as_concept_id` from numeric to integer
#> • `unit_concept_id` from numeric to integer

result <- summariseMeasurementUse(
  cdm = cdm,
  bySex = TRUE,
  codes = list("test_codelist" = c(3001467L, 45875977L))
)
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> → Summarising results - value as number.
#> → Summarising results - value as concept.
#> → Binding all diagnostic results.

plotMeasurementValueAsNumeric(result)
#> Ignoring unknown labels:
#> • fill : "Cdm name, Unit concept name and Sex"


CDMConnector::cdmDisconnect(cdm)
# }
```
