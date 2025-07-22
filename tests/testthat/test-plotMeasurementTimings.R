test_that("test measurement timing", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)
  result <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test_codelist" = c(3001467L, 45875977L)))

  boxplot1 <- result |>
    dplyr::filter(variable_name == "time") |>
    plotMeasurementTimings(facet = "cdm_name", colour = NULL)
  expect_true(all(c("gg", "ggplot") %in% class(boxplot1)))

  boxplot2 <- result |>
    dplyr::filter(variable_name == "time") |>
    plotMeasurementTimings(facet = "cdm_name", colour = NULL, timeScale = "years")
  expect_true(all(c("gg", "ggplot") %in% class(boxplot2)))

  boxplot3 <- result |>
    dplyr::filter(variable_name == "measurements_per_subject") |>
    plotMeasurementTimings(facet = "cdm_name", colour = "cdm_name")
  expect_true(all(c("gg", "ggplot") %in% class(boxplot3)))

  density1 <- result |>
    dplyr::filter(variable_name == "measurements_per_subject") |>
    plotMeasurementTimings(facet = "cdm_name", plotType = "densityplot")
  expect_true(all(c("gg", "ggplot") %in% class(density1)))

  density2 <- result |>
    dplyr::filter(variable_name == "time") |>
    plotMeasurementTimings(facet = "cdm_name", plotType = "densityplot")
  expect_true(all(c("gg", "ggplot") %in% class(density2)))

  density3 <- result |>
    dplyr::filter(variable_name == "time") |>
    plotMeasurementTimings(facet = "cdm_name", plotType = "densityplot", timeScale = "years")
  expect_true(all(c("gg", "ggplot") %in% class(density3)))

  expect_error(plotMeasurementTimings(result, facet = "h"))
  expect_error(plotMeasurementTimings(result, colour = "h"))
  expect_error(plotMeasurementTimings(result, timeScale = "h"))
  expect_error(plotMeasurementTimings(result, plotType =  "h"))
  expect_error(plotMeasurementTimings(result))
})
