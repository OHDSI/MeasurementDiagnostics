#' Function to create a mock cdm reference.
#'
#' @description
#' Creates an example dataset that can be used to show how
#' the package works
#'
#' @param nPerson Number of people in the cdm.
#' @param recordPerson Average number of measurement records per person.
#' @param seed Seed to use when creating the mock data.
#'
#' @return A cdm object in a temporary duckdb database
#' @export
#'
#' @examples
#' \dontrun{
#' library(MeasurementDiagnostics)
#' cdm <- mockMeasurementDiagnostics()
#' cdm
#'}
mockMeasurementDiagnostics <- function(nPerson = 100,
                                       recordPerson = 2,
                                       seed = 111) {

  rlang::check_installed("omock")
  rlang::check_installed("CDMConnector")

  omopgenerics::assertNumeric(nPerson, length = 1, na = FALSE, null = FALSE)
  omopgenerics::assertNumeric(recordPerson, length = 1, min = 1, na = FALSE, null = FALSE)
  omopgenerics::assertNumeric(seed, length = 1, na = FALSE, null = FALSE)

  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir("empty_cdm", cdmVersion = "5.3"))
  cdm <- CDMConnector::cdmFromCon(con, cdmSchema = "main", writeSchema = "main", cdmName = "Mock Measurement Diagnostics")

  cdm <- cdm |>
    omock::mockPerson(nPerson = nPerson, seed = seed) |>
    omock::mockObservationPeriod(seed = seed) |>
    omock::mockConditionOccurrence(seed = seed) |>
    omock::mockVisitOccurrence(seed = seed) |>
    omock::mockDrugExposure(seed = seed) |>
    omock::mockObservation(seed = seed) |>
    omock::mockMeasurement(recordPerson = as.integer(recordPerson), seed = seed) |>
    omock::mockProcedureOccurrence(seed = seed) |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2, seed = seed)

  return(cdm)
}
