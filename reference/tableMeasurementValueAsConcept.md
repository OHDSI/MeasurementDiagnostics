# Format a measurement_summary object into a visual table

Format a measurement_summary object into a visual table

## Usage

``` r
tableMeasurementValueAsConcept(
  result,
  header = c(visOmopResults::strataColumns(result)),
  groupColumn = c("codelist_name"),
  settingsColumn = character(),
  hide = character(),
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
#> • time: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-02 16:29:34.86779
#> ✔ Summary finished, at 2026-02-02 16:29:34.965023
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-02 16:29:35.471718
#> ✔ Summary finished, at 2026-02-02 16:29:35.558932
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-02 16:29:37.02514
#> ✔ Summary finished, at 2026-02-02 16:29:37.281597
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-02-02 16:29:37.910842
#> ✔ Summary finished, at 2026-02-02 16:29:38.051414
#> → Binding all diagnostic results.

tableMeasurementValueAsConcept(result)


  

CDM name
```

Concept name

Concept ID

Source concept name

Source concept ID

Domain ID

Value as concept name

Value as concept ID

Estimate name

Estimate value

test_codelist

mock database

overall

overall

overall

overall

overall

Low

4267416

N (%)

68 (34.00%)

High

4328749

N (%)

66 (33.00%)

NA

NA

N (%)

66 (33.00%)

Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or
Plasma

3001467

NA

NA

Measurement

Low

4267416

N (%)

68 (34.00%)

High

4328749

N (%)

66 (33.00%)

NA

NA

N (%)

66 (33.00%)

CDMConnector::[cdmDisconnect](https://darwin-eu.github.io/omopgenerics/reference/cdmDisconnect.html)(cdm
= cdm) \# }
