#' Plot summariseMeasurementTiming results.
#' @param x Variable to plot on the x axis when plotType is "boxlot".
#' @param y Variable to plot, it can be "days_between_measurements" or
#' "measurements_per_subject".
#' @inheritParams resultDoc
#' @inheritParams plotDoc
#'
#' @return A ggplot.
#' @export
#'
#' @examples
#' \donttest{
#' library(MeasurementDiagnostics)
#' library(dplyr)
#'
#' cdm <- mockMeasurementDiagnostics()
#'
#' result <- summariseMeasurementUse(
#'   cdm = cdm,
#'   codes = list("test_codelist" = c(3001467L, 45875977L))
#' )
#'
#' result |>
#'   filter(variable_name == "days_between_measurements") |>
#'   plotMeasurementSummary()
#'
#' CDMConnector::cdmDisconnect(cdm)
#'}
plotMeasurementSummary <- function(result,
                                   x = "codelist_name",
                                   y = "days_between_measurements",
                                   plotType = "boxplot",
                                   facet = visOmopResults::strataColumns(result),
                                   colour = c("cdm_name", "codelist_name"),
                                   style = NULL) {
  # specific checks
  omopgenerics::assertChoice(y, c("days_between_measurements", "measurements_per_subject"), length = 1)
  omopgenerics::assertChoice(plotType, c("boxplot", "densityplot", "barplot"), length = 1)
  result <- omopgenerics::validateResultArgument(result)
  rlang::check_installed("visOmopResults")

  # pre process
  result <- result |>
    omopgenerics::filterSettings(.data$result_type == "measurement_summary")

  if (nrow(result) == 0) {
    mes <- "No results found with `result_type == 'measurement_summary'`"
    cli::cli_warn("{mes}")
    return(visOmopResults::emptyPlot(subtitle = mes))
  }

  result <- result |>
    omopgenerics::filter(.data$variable_name == .env$y)

  if (nrow(result) == 0) {
    mes <- glue::glue("No results found with `variable_name == {y}`")
    cli::cli_warn("{mes}")
    return(visOmopResults::emptyPlot(subtitle = mes))
  }

  checkVersion(result)

  if (y == "days_between_measurements") {
    lab <- "Days between measurements"
  } else {
    lab <- "Number of measurements per subject"
  }

  if (plotType == "densityplot") {
    result <- result |>
      dplyr::filter(grepl("density", .data$estimate_name))
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
      style = style,
      # label = visOmopResults::plotColumns(result)
    ) +
      ggplot2::labs(
        title = "",
        x = lab,
        y = ""
      )
  } else if (plotType == "boxplot") {
    result <- result |>
      dplyr::filter(.data$estimate_name %in% c("min", "q25", "median", "q75", "max"))
    p <- visOmopResults::boxPlot(
      result = result,
      x = x,
      lower = "q25",
      middle = "median",
      upper  = "q75",
      ymin = "min",
      ymax = "max",
      facet  = facet,
      colour = colour,
      style = style,
      label = visOmopResults::plotColumns(result)
    ) +
      ggplot2::labs(
        title = "",
        y = lab,
        x = ""
      )
  } else if (plotType == "barplot") {
    result <- result |>
      dplyr::filter(.data$estimate_name == "count")
    p <- result |>
      visOmopResults::barPlot(
        x = "variable_level",
        y = "count",
        just = 0.5,
        position = "dodge",
        facet = facet,
        colour = colour,
        style = style,
        label = visOmopResults::plotColumns(result)
      ) +
      ggplot2::labs(
        title = "",
        x = lab,
        y = ""
      )
  }
  p
}

# change to visOmopResults in next release
emptyPlot <- function(title = "No result to plot",
                      subtitle = "") {
  ggplot2::ggplot() +
    ggplot2::theme_void() +
    ggplot2::labs(
      title = title,
      subtitle = subtitle
    )
}
