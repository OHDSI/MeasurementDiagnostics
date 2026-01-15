# Diagnostics of a codelist of measurement codes in the database

Diagnostics of a codelist of measurement codes in the database

## Usage

``` r
summariseMeasurementUse(
  cdm,
  codes,
  byConcept = TRUE,
  byYear = FALSE,
  bySex = FALSE,
  ageGroup = NULL,
  dateRange = as.Date(c(NA, NA)),
  personSample = 20000,
  estimates = list(measurement_summary = c("min", "q25", "median", "q75", "max",
    "density"), measurement_value_as_number = c("min", "q01", "q05", "q25", "median",
    "q75", "q95", "q99", "max", "count_missing", "percentage_missing", "density"),
    measurement_value_as_concept = c("count", "percentage")),
  histogram = NULL,
  checks = c("measurement_summary", "measurement_value_as_number",
    "measurement_value_as_concept")
)
```

## Arguments

- cdm:

  A reference to the cdm object.

- codes:

  A codelist of measurement/observation codes for which to perform
  diagnostics.

- byConcept:

  TRUE or FALSE. If TRUE code use will be summarised by concept.

- byYear:

  TRUE or FALSE. If TRUE code use will be summarised by year.

- bySex:

  TRUE or FALSE. If TRUE code use will be summarised by sex.

- ageGroup:

  If not NULL, a list of ageGroup vectors of length two.

- dateRange:

  Two dates. The first indicating the earliest measurement date and the
  second indicating the latest possible measurement date.

- personSample:

  Integerish or \`NULL\`. Number of persons to sample the measurement
  and observation tables. If \`NULL\`, no sampling is performed.

- estimates:

  A named list indicating, for each measurement diagnostics check, which
  estimates to retrieve. The names of the list should correspond to the
  diagnostics checks, and each list element should be a character vector
  specifying the estimates to compute.

  Allowed estimates are those supported by the \`summariseResult()\`
  function in the \*\*PatientProfiles\*\* package. If omitted, all
  available estimates for each check will be returned.

- histogram:

  Named list where names point to checks for which to get estimates for
  a histogram, and elements are numeric vectors indicating the
  bind-width. See function examples. Histogram only available for
  "measurement_summary" and "measurement_value_as_number".

- checks:

  Diagnostics to run. Options are: "measurement_summary",
  "measurement_value_as_number", and "measurement_value_as_concept".

## Value

A summarised result

## Examples

``` r
# \donttest{
library(MeasurementDiagnostics)

cdm <- mockMeasurementDiagnostics()

result <- summariseMeasurementUse(
  cdm = cdm, codes = list("test_codelist" = c(3001467L, 45875977L))
)
#> → Sampling measurement table to 20000 subjects
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> Summarising timings
#> ℹ The following estimates will be computed:
#> • time: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-15 11:41:29.338892
#> ✔ Summary finished, at 2026-01-15 11:41:29.455356
#> → Getting measurements per subject.
#> Summarising subjects
#> ℹ The following estimates will be computed:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-15 11:41:29.931957
#> ✔ Summary finished, at 2026-01-15 11:41:30.044196
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be computed:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-15 11:41:31.316738
#> ✔ Summary finished, at 2026-01-15 11:41:31.584976
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be computed:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-01-15 11:41:32.179459
#> ✔ Summary finished, at 2026-01-15 11:41:32.338148
#> → Binding all diagnostic results.

resultHistogram <- summariseMeasurementUse(
  cdm = cdm,
  codes = list("test_codelist" = c(3001467L, 45875977L)),
  byConcept = TRUE,
  byYear = FALSE,
  bySex = FALSE,
  ageGroup = NULL,
  dateRange = as.Date(c(NA, NA)),
  estimates = list(
    "measurement_summary" = c("min", "q25", "median", "q75", "max", "density"),
    "measurement_value_as_number" = c(
      "min", "q01", "q05", "q25", "median", "q75", "q95", "q99", "max",
      "count_missing", "percentage_missing", "density"
    ),
    "measurement_value_as_concept" = c("count", "percentage")
  ),
  histogram = list(
    "time" = list(
      '0 to 100' = c(0, 100), '110 to 200' = c(110, 200),
      '210 to 300' = c(210, 300), '310 to Inf' = c(310, Inf)
    ),
    "measurements_per_subject" = list(
      '0 to 10' = c(0, 10), '11 to 20' = c(11, 20),
      '21 to 30' = c(21, 30), '31 to Inf' = c(31, Inf)
    ),
    "value_as_number" =  list(
      '0 to 5' = c(0, 5), '6 to 10' = c(6, 10),
      '11 to 15' = c(11, 15), '>15' = c(16, Inf)
    )
  ),
  checks = c("measurement_summary", "measurement_value_as_number", "measurement_value_as_concept")
)
#> → Sampling measurement table to 20000 subjects
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> Summarising timings
#> ℹ The following estimates will be computed:
#> • time: min, q25, median, q75, max, density
#> • time_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-15 11:41:35.384028
#> ✔ Summary finished, at 2026-01-15 11:41:35.518773
#> → Getting measurements per subject.
#> Summarising subjects
#> ℹ The following estimates will be computed:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> • measurements_per_subject_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-15 11:41:36.191066
#> ✔ Summary finished, at 2026-01-15 11:41:36.306731
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be computed:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> • value_as_number_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-15 11:41:37.661286
#> ✔ Summary finished, at 2026-01-15 11:41:37.956024
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be computed:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-01-15 11:41:38.570585
#> ✔ Summary finished, at 2026-01-15 11:41:38.732553
#> → Binding all diagnostic results.

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
