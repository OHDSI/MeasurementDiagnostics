#' Function to create a mock cdm reference.
#'
#' @description
#' Creates an example dataset that can be used to show how
#' the package works
#'
#' @param nPerson number of people in the cdm.
#' @param source The source where the cdm_reference object is inserted. Choice
#' between 'local' or 'duckdb'.
#' @param con deprecated.
#' @param writeSchema deprecated.
#' @param seed deprecated.
#'
#' @return cdm_reference object
#' @export
#'
#' @examples
#' \donttest{
#' library(MeasurementDiagnostics)
#'
#' cdm <- mockMeasurementDiagnostics(source = "duckdb")
#'
#' cdm
#'}
mockMeasurementDiagnostics <- function(nPerson = 100,
                                       source = "local",
                                       con = lifecycle::deprecated(),
                                       writeSchema = lifecycle::deprecated(),
                                       seed = lifecycle::deprecated()) {
  rlang::check_installed("omock")
  omopgenerics::assertNumeric(nPerson, length = 1, na = FALSE, null = FALSE)
  omopgenerics::assertChoice(source, c("duckdb", "local"), length = 1)

  if (lifecycle::is_present(con)) {
    lifecycle::deprecate_soft(
      when = "0.2.0",
      what = "mockMeasurementDiagnostics(con=)",
      with = "omopgenerics::insertCdmTo()"
    )
  }
  if (lifecycle::is_present(writeSchema)) {
    lifecycle::deprecate_soft(
      when = "0.2.0",
      what = "mockMeasurementDiagnostics(writeSchema=)",
      with = "omopgenerics::insertCdmTo()"
    )
  }
  if (lifecycle::is_present(seed)) {
    lifecycle::deprecate_soft(
      when = "0.2.0",
      what = "mockMeasurementDiagnostics(seed=)",
      with = "set.seed()"
    )
  }

  cdm <- omock::mockCdmReference() |>
    omock::mockPerson(nPerson = 100) |>
    omock::mockObservationPeriod() |>
    omock::mockConditionOccurrence() |>
    omock::mockVisitOccurrence() |>
    omock::mockDrugExposure() |>
    omock::mockObservation() |>
    omock::mockMeasurement() |>
    omock::mockProcedureOccurrence() |>
    omock::mockCohort(name = "my_cohort", numberCohorts = 2)

  # further customisation
  cdm$measurement <- cdm$measurement |>
    dplyr::mutate(
      unit_concept_id = dplyr::if_else(dplyr::row_number()%%2 == 0, 9529, NA),
      value_as_number = dplyr::if_else(dplyr::row_number()<6, NA, seq(from = 5, to = 150, length.out = 2000)),
      value_as_concept_id = dplyr::case_when(
        dplyr::row_number()%%3 == 0 ~ 4328749,
        dplyr::row_number()%%3 == 1 ~ 4267416,
        dplyr::row_number()%%3 == 2 ~ NA,
      )
    )
  cdm$concept <- dplyr::bind_rows(
    cdm$concept,
    dplyr::tibble(
      concept_id = c(4328749L, 4267416L),
      concept_name = c("High", "Low"),
      domain_id = "Meas Value",
      vocabulary_id = "SNOMED",
      concept_class_id = "Qualifier Value",
      standard_concept = "S",
      concept_code = c(62482003, 75540009) |> as.character(),
      valid_start_date = as.Date("1970-01-01"),
      valid_end_date = as.Date("2099-01-01"),
      invalid_reason = NA
    )
  )

  if (source == "duckdb") {
    rlang::check_installed("CDMConnector")
    con <- duckdb::dbConnect(drv = duckdb::duckdb(dbdir = tempfile(fileext = ".duckdb")))
    src <- CDMConnector::dbSource(con = con, writeSchema = "main")
    cdm <- omopgenerics::insertCdmTo(cdm = cdm, to = src)
  }

  return(cdm)
}
