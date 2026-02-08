# Results Visualisation

## Introduction

This vignette demonstrates how to use table and plotting functions
provided by **MeasurementDiagnostics** to visualise results.

We use the package mock data so examples are fully reproducible.

``` r
library(MeasurementDiagnostics)
library(dplyr)
library(omopgenerics) 
library(ggplot2)

cdm <- mockMeasurementDiagnostics()

# Example codelist we'll use in the examples
alkaline_phosphatase_codes <- list("alkaline_phosphatase" = c(3001467L, 45875977L))
```

## Create diagnostics results

We call
[`summariseMeasurementUse()`](https://ohdsi.github.io/CohortConstructor/reference/summariseMeasurementUse.md)
once and obtain histogram bins for all numeric variables. This returns a
`summarised_result` containing all the diagnostics checks, summary
estimates, and density and histogram estimates to visualise
distributions of numeric variables; all for the overall measurements
codelist and stratified by sex.

``` r
result <- summariseMeasurementUse(
  cdm = cdm,
  codes = alkaline_phosphatase_codes,
  bySex = TRUE,
  byYear = FALSE,
  byConcept = FALSE,
  histogram = list(
    days_between_measurements = list(
      "0-30" = c(0, 30), "31-90" = c(31, 90), "91-365" = c(91, 365), "366+" = c(366, Inf)
    ),
    measurements_per_subject = list(
      "0" = c(0, 0), "1" = c(1, 1), "2-3" = c(2, 3), "4+" = c(4, 1000)
    ),
    value_as_number = list(
      "low" = c(0, 5.999), "mid" = c(6, 10.999), "high" = c(11, Inf)
    )
  )
)
```

## Tables

There is one table function corresponding to each diagnostic check:

- [`tableMeasurementSummary()`](https://ohdsi.github.io/CohortConstructor/reference/tableMeasurementSummary.md)
  — subjects with measurements, counts per subject, days between
  measurements.

- [`tableMeasurementValueAsNumber()`](https://ohdsi.github.io/CohortConstructor/reference/tableMeasurementValueAsNumber.md)
  — numeric value summaries (by unit where available).

- [`tableMeasurementValueAsConcept()`](https://ohdsi.github.io/CohortConstructor/reference/tableMeasurementValueAsConcept.md)
  — frequency of concept values.

You can customise which columns appear in the *header*, which are used
as *grouping columns*, and which to *hide*.

``` r
# 1. Measurement summary table (timings / counts)
tableMeasurementSummary(
  result, 
  header = c("codelist_name", "sex"),
  hide = c("cdm_name", "domain_id")
)
```

[TABLE]

``` r

# 2. Numeric-value summary table (values recorded as numbers)
tableMeasurementValueAsNumber(result)
```

[TABLE]

``` r

# 3. Concept-value summary table (values recorded as concepts)
tableMeasurementValueAsConcept(result)
```

[TABLE]

## Plots

The plotting helpers allow to plot certain types of graphics, while
giving flexibility for variables to use for colouring, facetting, and
which to have in the horizontla and vertical axes. They return `ggplot`
objects, which allows further customisation using standard
[**ggplot2**](https://ggplot2.tidyverse.org) layers.

### Measurement summary

[`plotMeasurementSummary()`](https://ohdsi.github.io/CohortConstructor/reference/plotMeasurementSummary.md)
visualises `days_between_measurements`, and `measurements_per_subject`.
Supported plot type are `"boxplot"`, `"barplot"`, and `"densityplot"`.

The variable specified in `y` must be either “days_between_measurements”
or “measurements_per_subject” as it is used to filter which of the
summary results to plot.

``` r
result |>
  plotMeasurementSummary(
    x = "codelist_name",
    y = "days_between_measurements",
    plotType = "boxplot"
  )
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-5-1.png)

``` r
result |>
  plotMeasurementSummary(
    x = "sex",
    y = "measurements_per_subject",
    plotType = "boxplot",
    colour = "sex",
    facet = NULL
  ) +
  theme(legend.position = "none")
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-6-1.png)

If we got `density` estimates we can also use `densityplot` for these
variables. To choose which variable to plot, we use the `y` argument,
while the `x` argument is ignored for this plot type.

``` r
result |>
  plotMeasurementSummary(
    plotType = "densityplot",
    colour = "sex", 
    facet = NULL
  )
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-7-1.png)

``` r
result |>
  plotMeasurementSummary(
    y = "measurements_per_subject",
    plotType = "densityplot",
    colour = "sex", 
    facet = NULL
  )
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-8-1.png)

Since we got specific bin-counts to plot histograms for these variables,
we can also use `plotType = "barplot"`

``` r
result |>
  plotMeasurementSummary(
    x = "variable_level",
    plotType = "barplot",
    colour = "variable_level", 
    facet = "sex"
  )
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-9-1.png)

``` r
result |>
  plotMeasurementSummary(
    y = "measurements_per_subject",
    plotType = "barplot",
    colour = "sex", 
    facet = "variable_level"
  )
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-10-1.png)

### Numeric-value summary

[`plotMeasurementValueAsNumber()`](https://ohdsi.github.io/CohortConstructor/reference/plotMeasurementValueAsNumber.md)
visualises distributions of numeric measurement values. We demonstrate
the three plot types, similar to the measurement summary plots.

#### boxplot

``` r
result |> 
  plotMeasurementValueAsNumber(
    x = "sex",
    plotType = "boxplot",
    facet = "unit_concept_name",
    colour = "sex"
  )
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-11-1.png)

#### densityplot

``` r
result |> 
  plotMeasurementValueAsNumber(
    plotType = "densityplot",
    facet = "unit_concept_name",
    colour = "sex"
  )
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-12-1.png)

#### barplot

``` r
result |> 
  plotMeasurementValueAsNumber(
    x = "unit_concept_name",
    plotType = "barplot",
    facet = c("sex"),
    colour = "variable_level"
  )
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-13-1.png)

### Concept-value summary

[`plotMeasurementValueAsConcept()`](https://ohdsi.github.io/CohortConstructor/reference/plotMeasurementValueAsConcept.md)
visualises concept-coded measurement values and their frequencies. Next
we plot counts for each concept value in the codelist.

``` r
result |>
  plotMeasurementValueAsConcept(
    x = "count",
    y = "variable_level",
    facet = "cdm_name",
    colour = "sex"
  ) +
  ylab("Value as Concept Name")
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-14-1.png)

Instead of counts, we can also plot the percentage for each concept:

``` r
result |>
  plotMeasurementValueAsConcept(
    x = "variable_level",
    y = "percentage",
    facet = "cdm_name",
    colour = "sex"
  ) +
  xlab("Value as Concept Name") 
```

![](a03_resultsVisualisation_files/figure-html/unnamed-chunk-15-1.png)

## Visualisation with other packages

### Shiny Apps with OmopViewer

The [**OmopViewer**](https://ohdsi.github.io/OmopViewer/) package
supports results produced by **MeasurementDiagnostics** and provides a
user-friendly way to quickly generate a Shiny application to explore
diagnostic results in an interactive way.

For example, the following code exports a static Shiny app that allows
users to navigate the tables and plots generated in this vignette.

``` r
library(OmopViewer)
exportStaticApp(result = result, directory = tempdir())
```

### Customisation of plots and tables with visOmopResults

Tables and plots in **MeasurementDiagnostics** are generated using the
[**visOmopResults**](https://darwin-eu.github.io/visOmopResults/)
package. Users who wish to create custom tables or visualisations
directly from a `summarised_result` object can do so by leveraging the
functions provided by this package.

### Application of MeasurementDiagnostics in PhenotypeR

**MeasurementDiagnostics** is integrated into the
[**PhenotypeR**](https://ohdsi.github.io/PhenotypeR/) package. When
cohorts are defined based on measurement codes, **PhenotypeR**
automatically applies
[`summariseCohortMeasurementUse()`](https://ohdsi.github.io/CohortConstructor/reference/summariseCohortMeasurementUse.md)
to generate measurement diagnostics during cohort construction, using
the codelists linked to each cohort.

This integration allows users to assess measurement codelists and
cohorts as part of a broader phenotype development workflow.
