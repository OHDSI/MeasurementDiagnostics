#' Function to create a mock cdm reference.
#'
#' @description
#' Creates an example dataset that can be used to show how
#' the package works
#'
#' @param nPerson number of people in the cdm.
#' @param seed seed to use when creating the mock data.
#'
#' @return cdm object
#' @export
#'
#' @examples
#' \donttest{
#' library(MeasurementDiagnostics)
#' cdm <- mockMeasurementDiagnostics()
#' cdm
#'}
mockMeasurementDiagnostics <- function(nPerson = 100,
                                       seed = 111) {

  rlang::check_installed("omock")
  rlang::check_installed("CDMConnector")

  omopgenerics::assertNumeric(nPerson, length = 1, na = FALSE, null = FALSE)
  omopgenerics::assertNumeric(seed, length = 1, na = FALSE, null = FALSE)

  cdm_local <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = nPerson, seed = seed) |>
    omock::mockObservationPeriod(seed = seed) |>
    omock::mockConditionOccurrence(seed = seed) |>
    omock::mockVisitOccurrence(seed = seed) |>
    omock::mockDrugExposure(seed = seed) |>
    omock::mockObservation(seed = seed) |>
    omock::mockMeasurement(seed = seed) |>
    omock::mockProcedureOccurrence(seed = seed) |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2, seed = seed)

  randomMeasurements <- randomMeasurementTable(nrow(cdm_local$measurement))

  cdm_local$measurement <- dplyr::bind_cols(
    cdm_local$measurement %>% dplyr::select(-dplyr::any_of(names(randomMeasurements))),
    randomMeasurements
  ) |>
    dplyr::select(colnames(cdm_local$measurement))

  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir("empty_cdm", cdmVersion = "5.3"))
  cdm <- CDMConnector::cdmFromCon(con, cdmSchema = "main", writeSchema = "main", cdmName = "Mock Measurement Diagnostics")

  for (nm in names(cdm_local)) {
    # skip the vocab tables since they are already in the cdm
    if (nm %in% c("concept", "vocabulary", "concept_relationship", "concept_synonym", "concept_ancestor")) next
    omopgenerics::insertTable(cdm, nm, cdm_local[[nm]], overwrite = TRUE, temporary = FALSE)
  }

  cdm$my_cohort <- dplyr::tbl(con, "my_cohort")

  cdm$my_cohort <- omopgenerics::newCohortTable(
    table = cdm$my_cohort ,
    cohortSetRef = omopgenerics::settings(cdm_local$my_cohort),
    cohortAttritionRef = omopgenerics::attrition(cdm_local$my_cohort),
    cohortCodelistRef = NULL
  )

  return(cdm)
}

# This function returns a random tibble with columns measurement_concept_id, unit_concept_id, value_as_number, value_as_concept_id
randomMeasurementTable <- local({

  # helper to create a simulator from quantiles
  createSimFunc <- function(xmin, p01, p10, p25, p50, p75, p90, p99, xmax) {
    if (is.na(xmin)) return(function(n = 1) rep(NA_real_, n))
    probs <- c(0, 0.01, 0.10, 0.25, 0.50, 0.75, 0.90, 0.99, 1)
    qvals <- c(xmin, p01, p10,  p25,  p50,  p75,  p90, p99, xmax)
    Q <- approxfun(probs, qvals, method = "linear", rule = 2)
    function(n = 1) Q(runif(n))
  }

  cache <- NULL   # will store the fully-prepped table (including simfunc)

  function(nrows) {
    # build + cache once
    if (is.null(cache)) {
      zip_path <- system.file("simdata.csv.zip", package = "MeasurementDiagnostics", mustWork = TRUE)
      cache <<- tibble::tibble(read.csv(unz(zip_path, "simdata.csv"))) |>
        # artificially create the p01 and p99 quantiles so we get a skewed distribution for outliers
        dplyr::mutate(
          p01 = p10 - 0.1 * (p10 - xmin),
          p99 = p90 + 0.1 * (xmax - p90)
        ) |>
        dplyr::mutate(
          simfunc = purrr::pmap(
            list(xmin, p01, p10, p25, p50, p75, p90, p99, xmax),
            createSimFunc
          )
        )
    }

    cache |>
      dplyr::slice_sample(n = nrows, replace = TRUE, weight_by = wt) |>
      dplyr::mutate(
        value_as_number = purrr::map_dbl(simfunc, ~.x(n = 1))
      ) |>
      dplyr::select(measurement_concept_id, unit_concept_id, value_as_number, value_as_concept_id = value_concept_id)
  }
})
