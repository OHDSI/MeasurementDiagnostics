
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- README.md is generated from README.Rmd. Please edit that file -->

# MeasurementDiagnostics <img src="man/figures/logo.png" align="right" height="180"/>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/MeasurementDiagnostics)](https://CRAN.R-project.org/package=MeasurementDiagnostics)
[![R-CMD-check](https://github.com/OHDSI/MeasurementDiagnostics/workflows/R-CMD-check/badge.svg)](https://github.com/OHDSI/MeasurementDiagnostics/actions)
[![Codecov test
coverage](https://codecov.io/gh/OHDSI/MeasurementDiagnostics/branch/main/graph/badge.svg)](https://app.codecov.io/gh/OHDSI/MeasurementDiagnostics?branch=main)
[![Lifecycle:Experimental](https://img.shields.io/badge/Lifecycle-Experimental-339999)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<!-- badges: end -->

The MeasurementDiagnostics package helps us to assess the use of
measurements present in data mapped to the OMOP CDM, either for the
dataset as a whole or for a particular cohort.

## Installation

You can install the development version of MeasurementDiagnostics from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("ohdsi/MeasurementDiagnostics")
```

## Example

Let’s say we are going to do a study where we are going to be using
measurements of respiratory function. We can use MeasurementDiagnostics
to better understand the use of these measurements.

For this example we’ll use the Eunomia data.

``` r
library(duckdb)
library(omopgenerics)
library(CDMConnector)
library(dplyr)
library(MeasurementDiagnostics)
```

``` r
con <- dbConnect(duckdb(), dbdir = eunomiaDir())
cdm <- cdmFromCon(
  con = con, cdmSchem = "main", writeSchema = "main", cdmName = "Eunomia"
)
cdm
#> 
#> ── # OMOP CDM reference (duckdb) of Eunomia ────────────────────────────────────
#> • omop tables: person, observation_period, visit_occurrence, visit_detail,
#> condition_occurrence, drug_exposure, procedure_occurrence, device_exposure,
#> measurement, observation, death, note, note_nlp, specimen, fact_relationship,
#> location, care_site, provider, payer_plan_period, cost, drug_era, dose_era,
#> condition_era, metadata, cdm_source, concept, vocabulary, domain,
#> concept_class, concept_relationship, relationship, concept_synonym,
#> concept_ancestor, source_to_concept_map, drug_strength
#> • cohort tables: -
#> • achilles tables: -
#> • other tables: -
```

Now we have a cdm reference with our data, we will create a codelist
with measurement concepts.

``` r
respiratory_function_codes <- newCodelist(list("respiratory function" = c(4052083L, 4133840L, 3011505L)))
respiratory_function_codes
#> 
#> - respiratory function (3 codes)
```

And now we can run a set of measurement diagnostic checks, here
stratifying results by sex.

``` r
respiratory_function_measurements <- summariseMeasurementUse(cdm, respiratory_function_codes, bySex = TRUE)
```

Among our results is a summary of timings between measurements for
individuals in our dataset. We can quickly create a plot of these
results like so

``` r
plotMeasurementTimings(respiratory_function_measurements |> 
    dplyr::filter(variable_name == "time"))
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />
