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
#> • days_between_measurements: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:39.944741
#> ✔ Summary finished, at 2026-02-06 18:45:40.086858
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:40.606549
#> ✔ Summary finished, at 2026-02-06 18:45:40.690621
#> ℹ summarising data
#> ℹ summarising cohort cohort_1
#> ℹ summarising cohort cohort_2
#> ✔ summariseCharacteristics finished!
#> `group` is not present in settings.
#> ! 2 duplicated rows eliminated.
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:43.22977
#> ✔ Summary finished, at 2026-02-06 18:45:43.462994
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-02-06 18:45:44.090633
#> ✔ Summary finished, at 2026-02-06 18:45:44.227116
#> → Binding all diagnostic results.

# Histogram
result <- summariseCohortMeasurementUse(
  codes = list("test_codelist" = c(3001467L, 45875977L)),
  cohort = cdm$my_cohort, timing = "cohort_start_date",
  histogram = list(
    "days_between_measurements" = list(
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
#> • days_between_measurements: min, q25, median, q75, max, density, count
#> • days_between_measurements_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:47.441728
#> ✔ Summary finished, at 2026-02-06 18:45:47.627899
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density, count
#> • measurements_per_subject_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:48.315229
#> ✔ Summary finished, at 2026-02-06 18:45:48.445957
#> ℹ summarising data
#> ℹ summarising cohort cohort_1
#> ℹ summarising cohort cohort_2
#> ✔ summariseCharacteristics finished!
#> `group` is not present in settings.
#> ! 2 duplicated rows eliminated.
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> • value_as_number_band: count
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:51.089036
#> ✔ Summary finished, at 2026-02-06 18:45:51.361394
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-02-06 18:45:51.983865
#> ✔ Summary finished, at 2026-02-06 18:45:52.114848
#> → Binding all diagnostic results.

# Different age groups
result <- summariseCohortMeasurementUse(
  codes = list("test_codelist" = c(3001467L, 45875977L)),
  cohort = cdm$my_cohort,
  ageGroup = list(
    "age_group_1" = list(c(0, 17), c(18, 64), c(65, 150)),
    "age_group_2" = list(c(0, 19), c(20, 39), c(40, 59), c(60, 79), c(80, 99), c(100, 120))
  )
)
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> Summarising timings
#> ℹ The following estimates will be calculated:
#> • days_between_measurements: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:55.804392
#> ✔ Summary finished, at 2026-02-06 18:45:56.306933
#> → Getting measurements per subject.
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:56.851999
#> ✔ Summary finished, at 2026-02-06 18:45:56.949872
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:57.556753
#> ✔ Summary finished, at 2026-02-06 18:45:57.685869
#> ℹ The following estimates will be calculated:
#> • measurements_per_subject: min, q25, median, q75, max, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:45:58.293216
#> ✔ Summary finished, at 2026-02-06 18:45:58.44565
#> ℹ summarising data
#> ℹ summarising cohort cohort_1
#> ℹ summarising cohort cohort_2
#> ✔ summariseCharacteristics finished!
#> `group` is not present in settings.
#> → Summarising results - value as number.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_number: min, q01, q05, q25, median, q75, q95, q99, max,
#>   count_missing, percentage_missing, density
#> ! Table is collected to memory as not all requested estimates are supported on
#>   the database side
#> → Start summary of data, at 2026-02-06 18:46:01.28206
#> ✔ Summary finished, at 2026-02-06 18:46:02.655591
#> → Summarising results - value as concept.
#> Summarising value as number
#> ℹ The following estimates will be calculated:
#> • value_as_concept_id: count, percentage
#> → Start summary of data, at 2026-02-06 18:46:03.74991
#> ✔ Summary finished, at 2026-02-06 18:46:04.172557
#> → Binding all diagnostic results.

CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
