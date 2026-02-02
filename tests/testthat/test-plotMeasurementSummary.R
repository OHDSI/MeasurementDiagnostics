test_that("test measurement timing", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)

  result <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test_codelist" = c(3001467L, 45875977L)))

  boxplot1 <- result |>
    plotMeasurementSummary(y = "days_between_measurements",
                           facet = "cdm_name", colour = NULL)
  expect_true(all(c("gg", "ggplot") %in% class(boxplot1)))

  boxplot2 <- result |>
    plotMeasurementSummary(y = "days_between_measurements",
                           facet = "cdm_name", colour = NULL, timeScale = "years")
  expect_true(all(c("gg", "ggplot") %in% class(boxplot2)))

  boxplot3 <- result |>
    plotMeasurementSummary(y = "measurements_per_subject",
                           facet = "cdm_name", colour = "cdm_name")
  expect_true(all(c("gg", "ggplot") %in% class(boxplot3)))

  density1 <- result |>
    plotMeasurementSummary(y = "measurements_per_subject",
                           facet = "cdm_name", plotType = "densityplot")
  expect_true(all(c("gg", "ggplot") %in% class(density1)))

  density2 <- result |>
    plotMeasurementSummary(y = "days_between_measurements",
                           facet = "cdm_name", plotType = "densityplot")
  expect_true(all(c("gg", "ggplot") %in% class(density2)))

  density3 <- result |>
    plotMeasurementSummary(y = "days_between_measurements",
                           facet = "cdm_name", plotType = "densityplot", timeScale = "years")
  expect_true(all(c("gg", "ggplot") %in% class(density3)))

  # Histogram
  result <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test_codelist" = c(3001467L, 45875977L)),
    histogram = list(
      "days_between_measurements" = list('0 to 100' = c(0, 100), '110 to 200' = c(110, 200), '210 to 300' = c(210, 300), '310 to Inf' = c(310, Inf)),
      "measurements_per_subject" = list('0 to 10' = c(0, 10), '11 to 20' = c(11, 20), '21 to 30' = c(21, 30), '31 to Inf' = c(31, Inf)),
      "value_as_number" =  list('0 to 5' = c(0, 5), '6 to 10' = c(6, 10), '11 to 15' = c(11, 15), '>15' = c(16, Inf))
    )
  )
  plotMeasurementSummary(result, plotType = "barplot")
  plotMeasurementSummary(result, y = "measurements_per_subject", plotType = "barplot")

  expect_error(plotMeasurementSummary(result, y =  "h"))
  expect_error(plotMeasurementSummary(result, facet = "h"))
  expect_error(plotMeasurementSummary(result, colour = "h"))
  expect_error(plotMeasurementSummary(result, timeScale = "h"))
  expect_error(plotMeasurementSummary(result, plotType =  "h"))

  dropCreatedTables(cdm = cdm)
})
