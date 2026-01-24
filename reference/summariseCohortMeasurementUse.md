# Diagnostics of a codelist of measurement codes within a cohort

Diagnostics of a codelist of measurement codes within a cohort

## Usage

``` r
summariseCohortMeasurementUse(
  cohort,
  codes = NULL,
  timing = "during",
  byConcept = TRUE,
  byYear = FALSE,
  bySex = FALSE,
  ageGroup = NULL,
  dateRange = as.Date(c(NA, NA)),
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

- cohort:

  A cohort in which to perform the diagnostics of the measurement codes
  provided.

- codes:

  A codelist of measurement/observation codes for which to perform
  diagnostics. If NULL it uses the codelist used to create each of the
  cohorts.

- timing:

  Three options: 1) "any" if the interest is on measurement recorded any
  time, 2) "during", if interested in measurements while the subject is
  in the cohort (or in observation if cohort = NULL), and 3)
  "cohort_start_date" for measurements occurring at cohort start date
  (or at "observation_period_start_date if cohort = NULL).

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

result <- summariseCohortMeasurementUse(
  codes = list("test_codelist" = c(3001467L, 45875977L)),
  cohort = cdm$my_cohort, timing = "cohort_start_date"
)
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> Summarising timings
#> ℹ The following estimates will be calculated:
#> • time: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-24 17:14:40.124555
#> ✔ Summary finished, at 2026-01-24 17:14:40.276546
#> → Getting measurements per subject.
#> Summarising subjects
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-24 17:14:40.814173
#> ✔ Summary finished, at 2026-01-24 17:14:40.897954
#> ! 2 duplicated rows eliminated.
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-24 17:14:42.144861
#> ✔ Summary finished, at 2026-01-24 17:14:42.388993
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-01-24 17:14:43.029721
#> ✔ Summary finished, at 2026-01-24 17:14:43.172978
#> → Binding all diagnostic results.

result <- summariseCohortMeasurementUse(
  codes = list("test_codelist" = c(3001467L, 45875977L)),
  cohort = cdm$my_cohort, timing = "cohort_start_date",
  histogram = list(
    "time" = list(
      '0 to 100' = c(0, 100), '110 to 200' = c(110, 200),
      '210 to 300' = c(210, 300), '310 to Inf' = c(310, Inf)
    ),
    "measurements_per_subject" = list(
      '0 to 10' = c(0, 10), '11 to 20' = c(11, 20), '21 to 30' = c(21, 30),
      '31 to Inf' = c(31, Inf)
    ),
    "value_as_number" =  list(
      '0 to 5' = c(0, 5), '6 to 10' = c(6, 10), '11 to 15' = c(11, 15),
      '>15' = c(16, Inf)
    )
  )
)
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> Summarising timings
#> ℹ The following estimates will be calculated:
#> • time: min, q25, median, q75, max, density, count
#> • time_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-24 17:14:46.518017
#> ✔ Summary finished, at 2026-01-24 17:14:46.711701
#> → Getting measurements per subject.
#> Summarising subjects
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density, count
#> • measurements_per_subject_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-24 17:14:47.489574
#> ✔ Summary finished, at 2026-01-24 17:14:47.615201
#> ! 2 duplicated rows eliminated.
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> • value_as_number_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-01-24 17:14:49.093638
#> ✔ Summary finished, at 2026-01-24 17:14:49.375027
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-01-24 17:14:50.023973
#> ✔ Summary finished, at 2026-01-24 17:14:50.157849
#> → Binding all diagnostic results.

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
