# Format a measurement_timings object into a visual table

Format a measurement_timings object into a visual table

## Usage

``` r
tableMeasurementTimings(
  result,
  type = "gt",
  header = c(visOmopResults::strataColumns(result)),
  groupColumn = c("codelist_name"),
  settingsColumn = character(),
  hide = c("variable_level"),
  style = NULL,
  .options = list()
)
```

## Arguments

- result:

  A summarised_result object.

- type:

  Type of table. Check supported types with
  \`visOmopResults::tableType()\`.

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
#> Warning: ! 2 casted column in measurement as do not match expected column type:
#> • `value_as_concept_id` from numeric to integer
#> • `unit_concept_id` from numeric to integer

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

tableMeasurementTimings(result)


  

CDM name
```

Variable name

Estimate name

Estimate value

test_codelist

mock database

Number records

N

100

Number subjects

N

67

Time (days)

Median \[Q25 - Q75\]

249 \[67 - 645\]

Range

8 to 2,886

Measurements per subject

Median \[Q25 - Q75\]

2.00 \[1.00 - 2.00\]

Range

1.00 to 4.00

CDMConnector::[cdmDisconnect](https://darwin-eu.github.io/omopgenerics/reference/cdmDisconnect.html)(cdm
= cdm) \# }
