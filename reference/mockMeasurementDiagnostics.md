# Function to create a mock cdm reference.

Creates an example dataset that can be used to show how the package
works

## Usage

``` r
mockMeasurementDiagnostics(
  nPerson = 100,
  con = DBI::dbConnect(duckdb::duckdb()),
  writeSchema = "main",
  seed = 111
)
```

## Arguments

- nPerson:

  number of people in the cdm.

- con:

  A DBI connection to create the cdm mock object.

- writeSchema:

  Name of an schema on the same connection with writing permissions.

- seed:

  seed to use when creating the mock data.

## Value

cdm object

## Examples

``` r
# \donttest{
library(MeasurementDiagnostics)
cdm <- mockMeasurementDiagnostics()
cdm
#> 
#> ── # OMOP CDM reference (duckdb) of mock database ──────────────────────────────
#> • omop tables: cdm_source, concept, concept_ancestor, concept_relationship,
#> concept_synonym, condition_occurrence, drug_exposure, drug_strength,
#> measurement, observation, observation_period, person, procedure_occurrence,
#> visit_occurrence, vocabulary
#> • cohort tables: my_cohort
#> • achilles tables: -
#> • other tables: -
# }
```
