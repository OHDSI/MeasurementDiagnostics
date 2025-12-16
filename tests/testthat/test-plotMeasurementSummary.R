test_that("test measurement timing", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)

  result <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test_codelist" = c(3001467L, 45875977L)))

  boxplot1 <- result |>
    plotMeasurementSummary(y = "time",
                           facet = "cdm_name", colour = NULL)
  expect_true(all(c("gg", "ggplot") %in% class(boxplot1)))

  boxplot2 <- result |>
    plotMeasurementSummary(y = "time",
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
    plotMeasurementSummary(y = "time",
                           facet = "cdm_name", plotType = "densityplot")
  expect_true(all(c("gg", "ggplot") %in% class(density2)))

  density3 <- result |>
    plotMeasurementSummary(y = "time",
                           facet = "cdm_name", plotType = "densityplot", timeScale = "years")
  expect_true(all(c("gg", "ggplot") %in% class(density3)))

  expect_error(plotMeasurementSummary(result, y =  "h"))
  expect_error(plotMeasurementSummary(result, facet = "h"))
  expect_error(plotMeasurementSummary(result, colour = "h"))
  expect_error(plotMeasurementSummary(result, timeScale = "h"))
  expect_error(plotMeasurementSummary(result, plotType =  "h"))

  dropCreatedTables(cdm = cdm)
})
