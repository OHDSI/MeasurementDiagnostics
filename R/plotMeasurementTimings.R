#' Plot summariseMeasurementTiming results.
#'
#' @inheritParams resultDoc
#' @inheritParams timeScaleDoc
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
#'               codes = list("test_codelist" = c(3001467L, 45875977L))
#'            )
#' result |>
#'   dplyr::filter(variable_name == "time") |>
#'   plotMeasurementTimings()
#' CDMConnector::cdmDisconnect(cdm)
#'}
plotMeasurementTimings <- function(result,
                                   plotType = "boxplot",
                                   timeScale = "days",
                                   facet = visOmopResults::strataColumns(result),
                                   colour = c("cdm_name", "codelist_name")) {
  # specific checks
  omopgenerics::assertChoice(plotType, c("boxplot", "densityplot"), length = 1)
  omopgenerics::assertChoice(timeScale, c("days", "years"), length = 1)
  result <- omopgenerics::validateResultArgument(result)
  rlang::check_installed("visOmopResults")

  # pre process
  result <- result |>
    omopgenerics::filterSettings(.data$result_type == "measurement_timings")

  if (nrow(result) == 0) {
    mes <- cli::cli_warn("No results found with `result_type == 'measurement_timings'`")
    return(emptyPlot(mes))
  }

  # Check variables
  variables <- result$variable_name |> unique()
  time <- "time" %in% variables
  nmeasurements <- "measurements_per_subject" %in% variables
  if ((time & nmeasurements) | (!time & !nmeasurements)) {
    cli::cli_abort("Variables to plot must be either `time` or `measurements_per_subject`")
  }

  checkVersion(result)

  if (time) {
    lab <- "Days between measurements"
    if (timeScale == "years") {
      result <- result |>
        dplyr::mutate("estimate_value" = as.character(as.numeric(.data$estimate_value)/365.25))
      lab <- "Years between measurements"
    }
  } else if (nmeasurements) {
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
      label = visOmopResults::plotColumns(result)
    ) +
      ggplot2::labs(
        title = ggplot2::element_blank(),
        x = lab,
        y = ggplot2::element_blank()
      )
  } else if (plotType == "boxplot") {
    result <- result |>
      dplyr::filter(.data$estimate_name %in% c("min", "q25", "median", "q75", "max"))
    p <- visOmopResults::boxPlot(
      result = result,
      x = "codelist_name",
      lower = "q25",
      middle = "median",
      upper  = "q75",
      ymin = "min",
      ymax = "max",
      facet  = facet,
      colour = colour,
      label = visOmopResults::plotColumns(result)
    ) +
      ggplot2::labs(
        title = ggplot2::element_blank(),
        y = lab,
        x = ggplot2::element_blank()
      )
  }

  p  +
    visOmopResults::themeVisOmop()
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
