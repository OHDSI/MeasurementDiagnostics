# Cohort-specific measurement diagnostics

## Introduction

This vignette demonstrates how to use
[`summariseCohortMeasurementUse()`](https://ohdsi.github.io/MeasurementDiagnostics/reference/summariseCohortMeasurementUse.md)
from **MeasurementDiagnostics** to perform measurement diagnostics
restricted to a cohort. The function computes the same three diagnostic
checks available for full-dataset summaries (`measurement_summary`,
`measurement_value_as_number`, and `measurement_value_as_concept`) but
limits the analysis to measurements recorded for subjects in a specified
cohort, and optionally to specific times relative to cohort entry.

We use package-provided mock data to keep the example fully
reproducible.

``` r
library(MeasurementDiagnostics)
library(dplyr)
library(omopgenerics) 
library(CohortConstructor)

cdm <- mockMeasurementDiagnostics()
cdm
```

## Basic usage

We begin by running diagnostics for a simple measurement codelist within
an example cohort. Diagnostics are performed on the measurement concepts
provided in `codes`, restricted to measurement records observed among
subjects while they are part of the cohort.

``` r
result <- summariseCohortMeasurementUse(
  codes = list("measurement_codelist" = c(3001467L, 45875977L)),
  cohort = cdm$my_cohort
)

# Inspect structure
result |> glimpse()
#> Rows: 12,436
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ cdm_name         <chr> "mock database", "mock database", "mock database", "m…
#> $ group_name       <chr> "cohort_name &&& codelist_name", "cohort_name &&& cod…
#> $ group_level      <chr> "cohort_1 &&& measurement_codelist", "cohort_1 &&& me…
#> $ strata_name      <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ variable_name    <chr> "cohort_records", "cohort_subjects", "cohort_records"…
#> $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ estimate_name    <chr> "count", "count", "count", "count", "count", "count",…
#> $ estimate_type    <chr> "integer", "integer", "integer", "integer", "integer"…
#> $ estimate_value   <chr> "100", "62", "100", "61", "21", "10", "8", "67", "44"…
#> $ additional_name  <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ additional_level <chr> "overall", "overall", "overall", "overall", "overall"…
```

Results are returned as a `summarised_result` object (see
**omopgenerics**). As an example, the table below shows the
`measurement_value_as_concept` results. From this output, we can see
that for this codelist and mock dataset, some measurement values are
recorded using concepts for “Low” and “High”, while others are missing a
concept value.

``` r
tableMeasurementValueAsConcept(result)
```

| CDM name             | Cohort name | Concept name                                                               | Concept ID | Source concept name | Source concept ID | Domain ID   | Value as concept name | Value as concept ID | Estimate name | Estimate value |
|----------------------|-------------|----------------------------------------------------------------------------|------------|---------------------|-------------------|-------------|-----------------------|---------------------|---------------|----------------|
| measurement_codelist |             |                                                                            |            |                     |                   |             |                       |                     |               |                |
| mock database        | cohort_1    | overall                                                                    | overall    | overall             | overall           | overall     | Low                   | 4267416             | N (%)         | 10 (18.52%)    |
|                      | cohort_2    | overall                                                                    | overall    | overall             | overall           | overall     | Low                   | 4267416             | N (%)         | 8 (30.77%)     |
|                      | cohort_1    | overall                                                                    | overall    | overall             | overall           | overall     | High                  | 4328749             | N (%)         | 24 (44.44%)    |
|                      | cohort_2    | overall                                                                    | overall    | overall             | overall           | overall     | High                  | 4328749             | N (%)         | 6 (23.08%)     |
|                      | cohort_1    | overall                                                                    | overall    | overall             | overall           | overall     | NA                    | NA                  | N (%)         | 20 (37.04%)    |
|                      | cohort_2    | overall                                                                    | overall    | overall             | overall           | overall     | NA                    | NA                  | N (%)         | 12 (46.15%)    |
|                      | cohort_1    | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | NA                | Measurement | Low                   | 4267416             | N (%)         | 10 (18.52%)    |
|                      | cohort_2    | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | NA                | Measurement | Low                   | 4267416             | N (%)         | 8 (30.77%)     |
|                      | cohort_1    | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | NA                | Measurement | High                  | 4328749             | N (%)         | 24 (44.44%)    |
|                      | cohort_2    | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | NA                | Measurement | High                  | 4328749             | N (%)         | 6 (23.08%)     |
|                      | cohort_1    | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | NA                | Measurement | NA                    | NA                  | N (%)         | 20 (37.04%)    |
|                      | cohort_2    | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | NA                | Measurement | NA                    | NA                  | N (%)         | 12 (46.15%)    |

Next, we examine the `measurement_value_as_number` results. This table
shows the range of numeric measurement values for the overall codelist
and for each individual concept, stratified by unit where available. In
the following results we see some numeric values referring to kilograms
(unit concept), while other are not associated with any unit, and lastly
there are 4 records with missing values as numbers.

``` r
tableMeasurementValueAsNumber(result)
```

| CDM name             | Cohort name | Concept name                                                               | Concept ID | Source concept name | Source concept ID | Domain ID   | Unit concept name | Unit concept ID | Estimate name        | Estimate value        |
|----------------------|-------------|----------------------------------------------------------------------------|------------|---------------------|-------------------|-------------|-------------------|-----------------|----------------------|-----------------------|
| measurement_codelist |             |                                                                            |            |                     |                   |             |                   |                 |                      |                       |
| mock database        | cohort_1    | overall                                                                    | overall    | overall             | overall           | overall     | kilogram          | 9529            | N                    | 32                    |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 7.83 \[6.78 – 9.79\]  |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.44 – 11.73          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.36 – 11.89          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.36 to 11.89         |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 0 (0.00%)             |
|                      |             |                                                                            |            |                     |                   |             | NA                | \-              | N                    | 22                    |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 7.18 \[6.60 – 8.77\]  |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.44 – 10.80          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.44 – 10.80          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.44 to 10.80         |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 4 (18.18%)            |
|                      |             | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | \-                | Measurement | kilogram          | 9529            | N                    | 32                    |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 7.83 \[6.78 – 9.79\]  |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.44 – 11.73          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.36 – 11.89          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.36 to 11.89         |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 0 (0.00%)             |
|                      |             |                                                                            |            |                     |                   |             | NA                | \-              | N                    | 22                    |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 7.18 \[6.60 – 8.77\]  |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.44 – 10.80          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.44 – 10.80          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.44 to 10.80         |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 4 (18.18%)            |
|                      | cohort_2    | overall                                                                    | overall    | overall             | overall           | overall     | kilogram          | 9529            | N                    | 14                    |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 7.10 \[6.60 – 8.41\]  |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.51 – 9.86           |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.51 – 9.86           |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.51 to 9.86          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 0 (0.00%)             |
|                      |             |                                                                            |            |                     |                   |             | NA                | \-              | N                    | 12                    |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 9.57 \[7.03 – 10.95\] |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 6.02 – 11.38          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 6.02 – 11.38          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Range                | 6.02 to 11.38         |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 0 (0.00%)             |
|                      |             | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | \-                | Measurement | kilogram          | 9529            | N                    | 14                    |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 7.10 \[6.60 – 8.41\]  |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.51 – 9.86           |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.51 – 9.86           |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.51 to 9.86          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 0 (0.00%)             |
|                      |             |                                                                            |            |                     |                   |             | NA                | \-              | N                    | 12                    |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 9.57 \[7.03 – 10.95\] |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 6.02 – 11.38          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 6.02 – 11.38          |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Range                | 6.02 to 11.38         |
|                      |             |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 0 (0.00%)             |

## Timing options

The `timing` argument controls which measurement records are considered:

- `"any"` — any measurement record for the person (no timing
  restriction)

- `"during"` — measurements while the person is in the cohort (default)

- `"cohort_start_date"` — measurements recorded on the cohort start date

The following example shows measurement summary results when using
`timing = "any"` and `timing = "cohort_start_date"`:

``` r
result_any <- summariseCohortMeasurementUse(
  codes = list("measurement_codelist" = c(3001467L, 45875977L)),
  cohort = cdm$my_cohort,
  timing = "any"
)

result_cohort_start <- summariseCohortMeasurementUse(
  codes = list("measurement_codelist" = c(3001467L, 45875977L)),
  cohort = cdm$my_cohort,
  timing = "cohort_start_date"
)

tableMeasurementSummary(result_any)
```

| CDM name      | Cohort name | Codelist name        | Variable name             | Estimate name        | Estimate value       |
|:--------------|:------------|:---------------------|:--------------------------|:---------------------|:---------------------|
| mock database | cohort_1    | measurement_codelist | Cohort records            | N                    | 100                  |
|               |             |                      | Cohort subjects           | N                    | 62                   |
|               |             |                      | Number subjects           | N (%)                | 59 (95.16%)          |
|               |             |                      | Days between measurements | Median \[Q25 – Q75\] | 198 \[58 – 921\]     |
|               |             |                      |                           | Range                | 8 to 2,886           |
|               |             |                      | Measurements per subject  | Median \[Q25 – Q75\] | 1.00 \[1.00 – 2.00\] |
|               |             |                      |                           | Range                | 1.00 to 4.00         |
|               | cohort_2    | measurement_codelist | Cohort records            | N                    | 100                  |
|               |             |                      | Cohort subjects           | N                    | 61                   |
|               |             |                      | Number subjects           | N (%)                | 37 (60.66%)          |
|               |             |                      | Days between measurements | Median \[Q25 – Q75\] | 71 \[41 – 710\]      |
|               |             |                      |                           | Range                | 8 to 2,098           |
|               |             |                      | Measurements per subject  | Median \[Q25 – Q75\] | 1.00 \[1.00 – 1.00\] |
|               |             |                      |                           | Range                | 1.00 to 4.00         |

``` r
tableMeasurementSummary(result_cohort_start)
```

| CDM name      | Cohort name | Codelist name        | Variable name             | Estimate name        | Estimate value       |
|:--------------|:------------|:---------------------|:--------------------------|:---------------------|:---------------------|
| mock database | cohort_1    | measurement_codelist | Cohort records            | N                    | 100                  |
|               |             |                      | Cohort subjects           | N                    | 62                   |
|               |             |                      | Number subjects           | N (%)                | 1 (1.61%)            |
|               |             |                      | Days between measurements | Median \[Q25 – Q75\] | –                    |
|               |             |                      |                           | Range                | –                    |
|               |             |                      | Measurements per subject  | Median \[Q25 – Q75\] | 1.00 \[1.00 – 1.00\] |
|               |             |                      |                           | Range                | 1.00 to 1.00         |
|               | cohort_2    | measurement_codelist | Number subjects           | N (%)                | 0 (0.00%)            |

## Measurement cohorts

If no explicit codelist is provided (`codes = NULL`), the function will
use the concept set associated with the cohort (if exists) to perform
diagnostics.

For example, using **CohortConstructor**, we can create a cohort based
on measurement concepts. This cohort stores the codelist used to define
it as an attribute.

``` r
cdm$measurement_cohort <- conceptCohort(
  cdm = cdm,
  conceptSet = list("measurement_codelist" = c(3001467L, 45875977L)),
  name = "measurement_cohort"
)
cohortCodelist(cdm$measurement_cohort)
#> 
#> - measurement_codelist (2 codes)
```

We can then call
[`summariseCohortMeasurementUse()`](https://ohdsi.github.io/MeasurementDiagnostics/reference/summariseCohortMeasurementUse.md)
without specifying codes. In this case, the function automatically uses
the codelist associated with the cohort. The example below runs
diagnostics on the measurement records used to define cohort entry:

``` r
result <- summariseCohortMeasurementUse(
  cohort = cdm$measurement_cohort,
  timing = "cohort_start_date"
)
tableMeasurementValueAsNumber(result)
```

| CDM name             | Cohort name          | Concept name                                                               | Concept ID | Source concept name | Source concept ID | Domain ID   | Unit concept name | Unit concept ID | Estimate name        | Estimate value        |
|----------------------|----------------------|----------------------------------------------------------------------------|------------|---------------------|-------------------|-------------|-------------------|-----------------|----------------------|-----------------------|
| measurement_codelist |                      |                                                                            |            |                     |                   |             |                   |                 |                      |                       |
| mock database        | measurement_codelist | overall                                                                    | overall    | overall             | overall           | overall     | kilogram          | 9529            | N                    | 100                   |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 8.77 \[7.07 – 10.48\] |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.65 – 11.89          |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.36 – 12.18          |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.36 to 12.18         |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 4 (4.00%)             |
|                      |                      |                                                                            |            |                     |                   |             | NA                | \-              | N                    | 100                   |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 8.77 \[7.07 – 10.48\] |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.73 – 11.82          |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.44 – 12.11          |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.44 to 12.11         |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 6 (6.00%)             |
|                      |                      | Alkaline phosphatase.bone \[Enzymatic activity/volume\] in Serum or Plasma | 3001467    | NA                  | \-                | Measurement | kilogram          | 9529            | N                    | 100                   |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 8.77 \[7.07 – 10.48\] |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.65 – 11.89          |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.36 – 12.18          |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.36 to 12.18         |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 4 (4.00%)             |
|                      |                      |                                                                            |            |                     |                   |             | NA                | \-              | N                    | 100                   |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Median \[Q25 – Q75\] | 8.77 \[7.07 – 10.48\] |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Q05 – Q95            | 5.73 – 11.82          |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Q01 – Q99            | 5.44 – 12.11          |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Range                | 5.44 to 12.11         |
|                      |                      |                                                                            |            |                     |                   |             |                   |                 | Missing value, N (%) | 6 (6.00%)             |

## Stratifications

In the following example, we restrict diagnostics to the
`measurement_summary` check and stratify results by **sex**. The
resulting table shows, for each stratum, the number of subjects with
measurements, the number of measurements per subject, and the time
between measurements.

\*Note that the percentage of subjects with measurements
(`Number subjects`) is calculated relative to the total number of
subjects in the cohort, independent of stratification variables such as
sex, age, or year.

``` r
result <- summariseCohortMeasurementUse(
  cohort = cdm$measurement_cohort,
  bySex = TRUE,
  byConcept = FALSE,
  timing = "any",
  checks = "measurement_summary"
)
tableMeasurementSummary(result)
```

[TABLE]

## Other arguments

Additional arguments allow users to further stratify results, restrict
the date range of measurement records, customise the set of summary
estimates, and obtain histogram-based summaries. These options behave in
the same way as in
[`summariseMeasurementUse()`](https://ohdsi.github.io/MeasurementDiagnostics/reference/summariseMeasurementUse.md),
which is described in more detail in the *“Summarising measurement use
in a dataset”* vignette.
