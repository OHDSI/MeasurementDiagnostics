#' Plot summariseMeasurementTiming results.
#'
#' @inheritParams resultDoc
#' @inheritParams plotDoc
#'
#' @return A ggplot.
#' @export
#'
#' @examples
#' \donttest{
#' library(MeasurementDiagnostics)
#' cdm <- mockMeasurementDiagnostics()
#' result <- summariseMeasurementUse(
#'               cdm = cdm,
#'               bySex = TRUE,
#'               codes = list("test_codelist" = c(3001467L, 45875977L)))
#' plotMeasurementValueAsNumeric(result)
#' CDMConnector::cdmDisconnect(cdm)
#' }
plotMeasurementValueAsNumeric <- function(result,
                                          x = c("unit_concept_name"),
                                          plotType = "boxplot",
                                          facet = c("codelist_name", "concept_name"),
                                          colour = c("cdm_name", "unit_concept_name", visOmopResults::strataColumns(result))) {
  omopgenerics::assertChoice(plotType, c("boxplot", "densityplot"), length = 1)
  result <- omopgenerics::validateResultArgument(result)
  rlang::check_installed("visOmopResults")

  # remove concept_name/concept_id when byConcept is FALSE
  plotCols <- visOmopResults::plotColumns(result)
  x <- intersect(x, plotCols)
  facet <- intersect(facet, plotCols)
  colour <- intersect(colour, plotCols)

  result <- result |>
    omopgenerics::filterSettings(.data$result_type == "measurement_value_as_numeric")

  if (nrow(result) == 0) {
    cli::cli_warn("There are no results with `result_type = measurement_value_as_numeric`")
    return(visOmopResults::emptyPlot())
  }

  # subset to rows of interest
  if (plotType == "boxplot") {
    result <- result |>
      dplyr::filter(.data$estimate_name %in% c("min", "q25", "median", "q75", "max"))
  } else if (plotType == "densityplot"){
    result <- result |>
      dplyr::filter(grepl("density", .data$estimate_name))
  }

  # Remove overall option when byConcept is TRUE
  if("codelist_name &&& concept_name" %in% result$group_name){
    result <- result |>
      dplyr::filter(.data$group_name %in% c("codelist_name &&& concept_name &&& unit_concept_name",
                                            "codelist_name &&& concept_name"))
  }

  if(length(result |> dplyr::pull("estimate_value") |> unique()) == 1 && is.na((result |> dplyr::pull("estimate_value") |> unique()))){
    cli::cli_warn("Numeric values are all NA")
    return(visOmopResults::emptyPlot())
  }

  checkVersion(result)

  xLab <- visOmopResults::customiseText(
    x, custom = c("unit_concept_name" = "Unit as concept name", "unit_concept_id" = "Unit as concept ID")
  )

  if (plotType == "boxplot") {
    p <-   visOmopResults::boxPlot(
      result = result,
      x = x,
      facet = facet,
      colour = colour,
      label = visOmopResults::plotColumns(result)
    ) +
      ggplot2::xlab(label = paste0(xLab, collapse = ", and "))
  } else if (plotType == "densityplot") {
    p <- visOmopResults::scatterPlot(
      result = result,
      x = "density_x",
      y = "density_y",
      line = TRUE,
      point = FALSE,
      ribbon = FALSE,
      ymin = NULL,
      ymax = NULL,
      facet = facet,
      colour = colour,
      label = visOmopResults::plotColumns(result)
    )
  }
  p +
    ggplot2::ylab(label = "Measurement numeric value") +
    visOmopResults::themeVisOmop()
}
