test_that("plotMeasurementValueAsNumber works", {
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)

  # Summarise measurement use ----
  result <- summariseMeasurementUse(
    cdm = cdm,
    bySex = TRUE,
    codes = list("test_codelist" = c(3001467L, 45875977L))
  )
  # Table types
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
  # Table types
  expect_no_error(x <- plotMeasurementValueAsNumber(result))
  expect_true(ggplot2::is_ggplot(x))

  dropCreatedTables(cdm = cdm)
})
