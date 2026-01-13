#' Diagnostics of a codelist of measurement codes within a cohort
#' @param codes A codelist of measurement/observation codes for which to perform
#' diagnostics. If NULL it uses the codelist used to create each of the cohorts.
#' @inheritParams summariseMeasurementDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(MeasurementDiagnostics)
#'
#' cdm <- mockMeasurementDiagnostics()
#'
#' result <- summariseCohortMeasurementUse(
#'   codes = list("test_codelist" = c(3001467L, 45875977L)),
#'   cohort = cdm$my_cohort, timing = "cohort_start_date"
#' )
#'
#' result <- summariseCohortMeasurementUse(
#'   codes = list("test_codelist" = c(3001467L, 45875977L)),
#'   cohort = cdm$my_cohort, timing = "cohort_start_date",
#'   histogram = list(
#'     "time" = list(
#'       '0 to 100' = c(0, 100), '110 to 200' = c(110, 200),
#'       '210 to 300' = c(210, 300), '310 to Inf' = c(310, Inf)
#'     ),
#'     "measurements_per_subject" = list(
#'       '0 to 10' = c(0, 10), '11 to 20' = c(11, 20), '21 to 30' = c(21, 30),
#'       '31 to Inf' = c(31, Inf)
#'     ),
#'     "value_as_number" =  list(
#'       '0 to 5' = c(0, 5), '6 to 10' = c(6, 10), '11 to 15' = c(11, 15),
#'       '>15' = c(16, Inf)
#'     )
#'   )
#' )
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#'}
summariseCohortMeasurementUse <- function(cohort,
                                          codes = NULL,
                                          timing = "during",
                                          byConcept = TRUE,
                                          byYear = FALSE,
                                          bySex = FALSE,
                                          ageGroup = NULL,
                                          dateRange = as.Date(c(NA, NA)),
                                          personSample = 20000,
                                          estimates = list(
                                            "measurement_summary" = c("min", "q25", "median", "q75", "max", "density"),
                                            "measurement_value_as_number" = c("min", "q01", "q05", "q25", "median", "q75", "q95", "q99", "max", "count_missing", "percentage_missing", "density"),
                                            "measurement_value_as_concept" = c("count", "percentage")
                                          ),
                                          histogram = NULL,
                                          checks = c("measurement_summary", "measurement_value_as_number", "measurement_value_as_concept")) {

  # check inputs
  timing <- omopgenerics::assertChoice(timing, choices = c("any", "during", "cohort_start_date"))
  cohort <- omopgenerics::validateCohortArgument(cohort)
  cdm <- omopgenerics::cdmReference(cohort)

  result <- summariseMeasurementUseInternal(
    cdm = cdm,
    codes = codes,
    cohort = cohort,
    timing = timing,
    timingName = timing,
    byConcept = byConcept,
    byYear = byYear,
    bySex = bySex,
    ageGroup = ageGroup,
    personSample = personSample,
    dateRange = dateRange,
    estimates = estimates,
    histogram = histogram,
    checks = checks
  )

  return(result)
}
