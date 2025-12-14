# Summarising measurement use in a dataset

## Introduction

In this vignette we will see how we can summarise the use of measurement
concepts in our dataset as a whole. For our example we’re going to be
interested in measurement concepts related to respiratory function and
will use the Eunomia synthetic dataset.

First we will connect to the database and create a cdm reference.

``` r
library(duckdb)
library(omopgenerics)
library(CDMConnector)
library(dplyr)
```

``` r
con <- dbConnect(duckdb(), dbdir = eunomiaDir())
#> Creating CDM database /tmp/RtmptU4YMz/GiBleed_5.3.zip
cdm <- cdmFromCon(
  con = con, cdmSchem = "main", writeSchema = "main", cdmName = "Eunomia"
)
cdm
#> 
#> ── # OMOP CDM reference (duckdb) of Eunomia ────────────────────────────────────
#> • omop tables: care_site, cdm_source, concept, concept_ancestor, concept_class,
#> concept_relationship, concept_synonym, condition_era, condition_occurrence,
#> cost, death, device_exposure, domain, dose_era, drug_era, drug_exposure,
#> drug_strength, fact_relationship, location, measurement, metadata, note,
#> note_nlp, observation, observation_period, payer_plan_period, person,
#> procedure_occurrence, provider, relationship, source_to_concept_map, specimen,
#> visit_detail, visit_occurrence, vocabulary
#> • cohort tables: -
#> • achilles tables: -
#> • other tables: -
```

Now we’ll create a codelist with measurement concepts.

``` r
repiratory_function_codes <- newCodelist(list("respiratory function" = c(4052083, 4133840, 3011505)))
repiratory_function_codes
#> 
#> - respiratory function (3 codes)
```

For a general summary of the use of these codes in our dataset we can
use summariseCodeUse from the CodelistGenerator R package.

``` r
library(CodelistGenerator)
code_use <- summariseCodeUse(repiratory_function_codes, cdm)
tableCodeUse(code_use)
```

[TABLE]

Although we now have a general summary of the use of our measurement
codes, we may well want more information on these measurements to inform
study feasibility and design.

MeasurementDiagnostics helps us to perform additional, measurement
specific, diagnostic checks. For this we’ll simply call the
summariseMeasurementUse() function which will run a series of checks.

``` r
library(MeasurementDiagnostics)

repiratory_function_measurements <- summariseMeasurementUse(cdm, repiratory_function_codes)
```

As with similar packages, our results are returned in the
summarised_result format as defined by the omopgenerics package.

``` r
repiratory_function_measurements |> 
  glimpse()
#> Rows: 2,116
#> Columns: 13
#> $ result_id        <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ cdm_name         <chr> "Eunomia", "Eunomia", "Eunomia", "Eunomia", "Eunomia"…
#> $ group_name       <chr> "codelist_name", "codelist_name", "codelist_name", "c…
#> $ group_level      <chr> "respiratory function", "respiratory function", "resp…
#> $ strata_name      <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ strata_level     <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ variable_name    <chr> "number records", "number subjects", "time", "time", …
#> $ variable_level   <chr> NA, NA, NA, NA, NA, NA, NA, "density_001", "density_0…
#> $ estimate_name    <chr> "count", "count", "min", "q25", "median", "q75", "max…
#> $ estimate_type    <chr> "integer", "integer", "integer", "integer", "integer"…
#> $ estimate_value   <chr> "26184", "2096", "0", "0", "371", "1726", "33541", "-…
#> $ additional_name  <chr> "overall", "overall", "overall", "overall", "overall"…
#> $ additional_level <chr> "overall", "overall", "overall", "overall", "overall"…
```

We can see each of the checks performed.

``` r
settings(repiratory_function_measurements) |> 
  pull("result_type") |> 
  unique()
#> [1] "measurement_summary"          "measurement_value_as_number" 
#> [3] "measurement_value_as_concept"
```

One of the checks summarises the numeric values associated with tests.
We can quickly create a table summarising these results.

``` r
tableMeasurementValueAsNumber(repiratory_function_measurements)
```

| CDM name             | Concept name                        | Concept ID | Domain ID   | Unit concept name   | Unit concept ID | Estimate name        | Estimate value   |
|----------------------|-------------------------------------|------------|-------------|---------------------|-----------------|----------------------|------------------|
| respiratory function |                                     |            |             |                     |                 |                      |                  |
| Eunomia              | overall                             | overall    | overall     | No matching concept | 0               | N                    | 26,184           |
|                      |                                     |            |             |                     |                 | Median \[Q25 - Q75\] | –                |
|                      |                                     |            |             |                     |                 | Q05 - Q95            | –                |
|                      |                                     |            |             |                     |                 | Q01 - Q99            | –                |
|                      |                                     |            |             |                     |                 | Range                | –                |
|                      |                                     |            |             |                     |                 | Missing value, N (%) | 26,184 (100.00%) |
|                      | Measurement of respiratory function | 4052083    | Measurement | No matching concept | 0               | N                    | 12,264           |
|                      |                                     |            |             |                     |                 | Median \[Q25 - Q75\] | –                |
|                      |                                     |            |             |                     |                 | Q05 - Q95            | –                |
|                      |                                     |            |             |                     |                 | Q01 - Q99            | –                |
|                      |                                     |            |             |                     |                 | Range                | –                |
|                      |                                     |            |             |                     |                 | Missing value, N (%) | 12,264 (100.00%) |
|                      | FEV1/FVC                            | 3011505    | Measurement | No matching concept | 0               | N                    | 6,960            |
|                      |                                     |            |             |                     |                 | Median \[Q25 - Q75\] | –                |
|                      |                                     |            |             |                     |                 | Q05 - Q95            | –                |
|                      |                                     |            |             |                     |                 | Q01 - Q99            | –                |
|                      |                                     |            |             |                     |                 | Range                | –                |
|                      |                                     |            |             |                     |                 | Missing value, N (%) | 6,960 (100.00%)  |
|                      | Spirometry                          | 4133840    | Measurement | No matching concept | 0               | N                    | 6,960            |
|                      |                                     |            |             |                     |                 | Median \[Q25 - Q75\] | –                |
|                      |                                     |            |             |                     |                 | Q05 - Q95            | –                |
|                      |                                     |            |             |                     |                 | Q01 - Q99            | –                |
|                      |                                     |            |             |                     |                 | Range                | –                |
|                      |                                     |            |             |                     |                 | Missing value, N (%) | 6,960 (100.00%)  |

Similarly, we can see a summary of concept values associated with
measurements. We can see from this that our respiratory function
measurements do not have concept value results (instead having numeric
values which we see in the table above).

``` r
tableMeasurementValueAsConcept(repiratory_function_measurements)
```

| CDM name             | Concept name                        | Concept ID | Domain ID   | Variable name         | Value as concept name | Value as concept ID | Estimate name | Estimate value   |
|----------------------|-------------------------------------|------------|-------------|-----------------------|-----------------------|---------------------|---------------|------------------|
| respiratory function |                                     |            |             |                       |                       |                     |               |                  |
| unknown              | overall                             | overall    | overall     | Value as concept name | No matching concept   | 0                   | N (%)         | 26,184 (100.00%) |
|                      | FEV1/FVC                            | 3011505    | Measurement | Value as concept name | No matching concept   | 0                   | N (%)         | 6,960 (100.00%)  |
|                      | Measurement of respiratory function | 4052083    | Measurement | Value as concept name | No matching concept   | 0                   | N (%)         | 12,264 (100.00%) |
|                      | Spirometry                          | 4133840    | Measurement | Value as concept name | No matching concept   | 0                   | N (%)         | 6,960 (100.00%)  |

As well as overview of the values of measurements, we can also see a
summary of the timing between measurements for individuals in the
dataset.

``` r
tableMeasurementSummary(repiratory_function_measurements)
```

| CDM name             | Variable name            | Estimate name        | Estimate value       |
|----------------------|--------------------------|----------------------|----------------------|
| respiratory function |                          |                      |                      |
| Eunomia              | Number records           | N                    | 26,184               |
|                      | Number subjects          | N                    | 2,096                |
|                      | Time (days)              | Median \[Q25 - Q75\] | 371 \[0 - 1,726\]    |
|                      |                          | Range                | 0 to 33,541          |
|                      | Measurements per subject | Median \[Q25 - Q75\] | 2.00 \[1.00 - 3.00\] |
|                      |                          | Range                | 1.00 to 138.00       |
