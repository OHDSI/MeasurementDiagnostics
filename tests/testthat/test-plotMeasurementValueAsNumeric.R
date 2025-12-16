test_that("plotMeasurementValueAsNumber works", {
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)

  # Summarise measurement use ----
  result <- summariseMeasurementUse(
    cdm = cdm,
    bySex = TRUE,
    codes = list("test_codelist" = c(3001467L, 45875977L))
  )
  expect_no_error(x <- plotMeasurementValueAsNumber(result))
  expect_true(ggplot2::is_ggplot(x))
  expect_no_error(x <- plotMeasurementValueAsNumber(result, plotType = "densityplot"))
  expect_true(ggplot2::is_ggplot(x))

  # Summarise measurement use ----
  result <- summariseMeasurementUse(
    cdm = cdm,
    byConcept = FALSE,
    codes = list("test_codelist" = c(3001467L, 45875977L))
  )
  expect_no_error(x <- plotMeasurementValueAsNumber(result))
  expect_true(ggplot2::is_ggplot(x))

  # Histogram
  result <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test_codelist" = c(3001467L, 45875977L)),
    histogram = list(
      "time" = list('0 to 100' = c(0, 100), '110 to 200' = c(110, 200), '210 to 300' = c(210, 300), '310 to Inf' = c(310, Inf)),
      "measurements_per_subject" = list('0 to 10' = c(0, 10), '11 to 20' = c(11, 20), '21 to 30' = c(21, 30), '31 to Inf' = c(31, Inf)),
      "value_as_number" =  list('0 to 5' = c(0, 5), '6 to 10' = c(6, 10), '11 to 15' = c(11, 15), '>15' = c(16, Inf))
    )
  )
  plotMeasurementValueAsNumber(result, plotType = "densityplot")
  plotMeasurementValueAsNumber(result, x = "variable_level", plotType = "barplot")


  dropCreatedTables(cdm = cdm)
})
