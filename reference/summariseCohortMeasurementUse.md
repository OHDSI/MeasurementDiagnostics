# Diagnostics of a codelist of measurement codes within a cohort

Diagnostics of a codelist of measurement codes within a cohort

## Usage

``` r
summariseCohortMeasurementUse(
  codes,
  cohort,
  timing = "during",
  byConcept = TRUE,
  byYear = FALSE,
  bySex = FALSE,
  ageGroup = NULL,
  dateRange = as.Date(c(NA, NA)),
  checks = c("measurement_timings", "measurement_value_as_numeric",
    "measurement_value_as_concept")
)
```

## Arguments

- codes:

  A codelist of measurement/observation codes for which to perform
  diagnostics.

- cohort:

  A cohort in which to perform the diagnostics of the measurement codes
  provided.

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

- checks:

  Diagnostics to run. Options are: "measurement_timing",
  "measurement_value_as_numeric", and "measurement_value_as_concept".

## Value

A summarised result

## Examples

``` r
# \donttest{
library(MeasurementDiagnostics)
cdm <- mockMeasurementDiagnostics()
#> Warning: ! 2 casted column in measurement as do not match expected column type:
#> • `value_as_concept_id` from numeric to integer
#> • `unit_concept_id` from numeric to integer
result <- summariseCohortMeasurementUse(
  codes = list("test_codelist" = c(3001467L, 45875977L)),
  cohort = cdm$my_cohort, timing = "cohort_start_date"
)
#> → Getting measurement records based on 2 concepts.
#> → Subsetting records to the subjects and timing of interest.
#> → Getting time between records per person.
#> ! 2 duplicated rows eliminated.
#> → Summarising results - value as number.
#> → Summarising results - value as concept.
#> → Binding all diagnostic results.
CDMConnector::cdmDisconnect(cdm = cdm)
# }
```
