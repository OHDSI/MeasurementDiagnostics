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
#> ℹ The following estimates will be calculated:
#> • days_between_measurements: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:20.183363
#> ✔ Summary finished, at 2026-02-08 20:40:20.280128
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:20.799641
#> ✔ Summary finished, at 2026-02-08 20:40:20.903574
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:22.403119
#> ✔ Summary finished, at 2026-02-08 20:40:22.667105
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-02-08 20:40:23.315245
#> ✔ Summary finished, at 2026-02-08 20:40:23.463952
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
    "days_between_measurements" = list(
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
#> ℹ The following estimates will be calculated:
#> • days_between_measurements: min, q25, median, q75, max, density
#> • days_between_measurements_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:26.683708
#> ✔ Summary finished, at 2026-02-08 20:40:26.798902
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> • measurements_per_subject_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:27.445686
#> ✔ Summary finished, at 2026-02-08 20:40:27.559013
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> • value_as_number_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:29.14019
#> ✔ Summary finished, at 2026-02-08 20:40:29.428083
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-02-08 20:40:30.055285
#> ✔ Summary finished, at 2026-02-08 20:40:30.181926
#> → Binding all diagnostic results.

# more than one age group:
result <- summariseMeasurementUse(
  cdm = cdm,
  codes = list("test_codelist" = c(3001467L, 45875977L)),
  ageGroup = list(
    "age_group_1" = list(c(0, 17), c(18, 64), c(65, 150)),
    "age_group_2" = list(c(0, 19), c(20, 39), c(40, 59), c(60, 79), c(80, 99), c(100, 120))
  )
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
#> → Start summary of data, at 2026-02-08 20:40:33.676125
#> ✔ Summary finished, at 2026-02-08 20:40:33.996627
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:34.50804
#> ✔ Summary finished, at 2026-02-08 20:40:34.59229
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:35.161671
#> ✔ Summary finished, at 2026-02-08 20:40:35.278224
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:35.851459
#> ✔ Summary finished, at 2026-02-08 20:40:35.96382
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-08 20:40:37.593256
#> ✔ Summary finished, at 2026-02-08 20:40:38.582121
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-02-08 20:40:39.375051
#> ✔ Summary finished, at 2026-02-08 20:40:39.784895
#> → Binding all diagnostic results.

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
