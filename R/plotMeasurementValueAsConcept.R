#' Plot summariseMeasurementTiming results.
#'
#' @inheritParams resultDoc
#' @inheritParams plotDoc
#'
#' @return A ggplot.
#' @export
#'
#' @examples
#' \dontrun{
#' library(MeasurementDiagnostics)
#'
#' cdm <- mockMeasurementDiagnostics()
#'
#' result <- summariseMeasurementUse(
#'               cdm = cdm,
#'               bySex = TRUE,
#'               codes = list("test_codelist" = c(3001467L, 45875977L)))
#' plotMeasurementValueAsConcept(result)
#'
#' cdmDisconnect(cdm)
#' }
plotMeasurementValueAsConcept <- function(result,
                                          x = "count",
                                          y = "variable_level",
                                          facet = c("codelist_name", "concept_name"),
                                          colour = c("cdm_name", visOmopResults::strataColumns(result))) {
  result <- omopgenerics::validateResultArgument(result)
  rlang::check_installed("visOmopResults")
  plotCols <- visOmopResults::plotColumns(result)
  # to remove concept_name when byConcept is FALSE
  x <- intersect(x, plotCols)
  facet <- intersect(facet, plotCols)
  colour <- intersect(colour, plotCols)

  # subset to rows of interest
  result <- result |>
    omopgenerics::filterSettings(.data$result_type == "measurement_value_as_concept")

  if (nrow(result) == 0) {
    cli::cli_warn("There are no results with `result_type = measurement_value_as_concept`")
    return(visOmopResults::emptyPlot())
  }

  checkVersion(result)

  yLab <- visOmopResults::customiseText(
    y, custom = c("variable_level" = "Value as concept name", "value_as_concept_id" = "Value as concept ID")
  )

  visOmopResults::barPlot(
    result = result,
    x = x,
    y = y,
    width = NULL,
    just = 0.5,
    facet = facet,
    colour = colour,
    label = visOmopResults::plotColumns(result)
  ) +
    ggplot2::ylab(label = paste0(yLab, collapse = ", and ")) +
    visOmopResults::themeVisOmop()
}
