# Format a measurement_summary object into a visual table

Format a measurement_summary object into a visual table

## Usage

``` r
tableMeasurementSummary(
  result,
  header = c(visOmopResults::strataColumns(result)),
  groupColumn = character(),
  settingsColumn = character(),
  hide = c("variable_level"),
  style = NULL,
  type = NULL,
  .options = list()
)
```

## Arguments

- result:

  A summarised_result object.

- header:

  Columns to use as header. See options with
  \`visOmopResults::tableColumns(result)\`.

- groupColumn:

  Columns to group by. See options with
  \`visOmopResults::tableColumns(result)\`.

- settingsColumn:

  Columns from settings to include in results. See options with
  \`visOmopResults::settingsColumns(result)\`.

- hide:

  Columns to hide from the visualisation. See options with
  \`visOmopResults::tableColumns(result)\`.

- style:

  Named list that specifies how to style the different parts of the
  table generated. It can either be a pre-defined style ("default" or
  "darwin" - the latter just for gt and flextable), or NULL which
  converts to "default" style, or custom code.

- type:

  Type of table. Check supported types with
  \`visOmopResults::tableType()\`. If NULL 'gt' type will be used.

- .options:

  A named list with additional formatting options.
  \`visOmopResults::tableOptions()\` shows allowed arguments and their
  default values.

## Value

A formatted table

## Examples

``` r
# \donttest{
library(MeasurementDiagnostics)

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
#> • days_between_measurements: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:46:38.22578
#> ✔ Summary finished, at 2026-02-06 18:46:38.314731
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:46:38.79803
#> ✔ Summary finished, at 2026-02-06 18:46:38.888471
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:46:40.315175
#> ✔ Summary finished, at 2026-02-06 18:46:40.56601
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-02-06 18:46:41.181456
#> ✔ Summary finished, at 2026-02-06 18:46:41.315142
#> → Binding all diagnostic results.

tableMeasurementSummary(result)


  

CDM name
```

Codelist name

Variable name

Estimate name

Estimate value

mock database

test_codelist

Number subjects

N (%)

67 (67.00%)

Days between measurements

Median \[Q25 – Q75\]

249 \[67 – 645\]

Range

8 to 2,886

Measurements per subject

Median \[Q25 – Q75\]

1.00 \[1.00 – 2.00\]

Range

1.00 to 4.00

CDMConnector::[cdmDisconnect](https://darwin-eu.github.io/omopgenerics/reference/cdmDisconnect.html)(cdm
= cdm) \# }
