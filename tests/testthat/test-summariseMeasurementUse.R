test_that("summariseMeasurementUse works", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)
  res <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = TRUE,
    ageGroup = list(c(0, 17), c(18, 64), c(65, 150))
  )
  expect_equal(
    omopgenerics::settings(res),
    dplyr::tibble(
      result_id = 1:3L,
      result_type = c("measurement_timings", "measurement_value_as_numeric", "measurement_value_as_concept"),
      package_name = "MeasurementDiagnostics",
      package_version = as.character(utils::packageVersion("MeasurementDiagnostics")),
      group = c("codelist_name", "codelist_name &&& concept_name &&& unit_concept_name", "codelist_name &&& concept_name"),
      strata = c(rep("sex &&& age_group", 3)),
      additional = c("", "concept_id &&& unit_concept_id &&& domain_id", "concept_id &&& value_as_concept_id &&& domain_id"),
      min_cell_count = "0"
    )
  )

  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c('0', '0', '1', '1', '100', '1426.75', '14973', '2', '2', '3', '3521.5', '5334', '64', '96')
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(variable_name) |>
      sort(),
    c(rep("measurements_per_subject", 5), rep("number records", 2), rep("number subjects", 2), rep("time", 5))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_name) |>
      sort(),
    c(rep("count", 4), "max",  "max", "median", "median", "min", "min", "q25", "q25", "q75", "q75")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name) |>
      sort() |>
      unique(),
    c("count", "density_x", "density_y", "max", "median", "min", "q25", "q75")
  )

  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::filter(estimate_name == "q25",
                    additional_level == "9529") |>
      dplyr::pull(estimate_value) |>
      as.numeric(),
    cdm$measurement |>
      dplyr::filter(measurement_concept_id == 3001467) |>
      dplyr::pull("value_as_number") |>
      stats::quantile(0.25,na.rm = TRUE) |>
      as.numeric())
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_name) |>
      unique() |>
      sort(),
    c('count','count_missing',
      'max',  'median',
      'min', 'q01','q05',
      'percentage_missing',
      'q25','q75', 'q95','q99')|>
      sort()
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name) |>
      sort() |>
      unique(),
    c("count", "count_missing", "density_x", "density_y", "max", "median",
      "min","percentage_missing", 'q01','q05', "q25", "q75", 'q95','q99')
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c('33', '33', '33', '33', '33', '33', '33', '33', '34', '34', '34', '34')
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name) |>
      sort(),
    c('count', 'count', 'count', 'count', 'count', 'count', 'percentage', 'percentage', 'percentage', 'percentage', 'percentage', 'percentage')
  )

  # suppress
  resSup <- res |> omopgenerics::suppress(minCellCount = 68)
  expect_equal(resSup$estimate_value |> unique(), c("100", "-", "81", "0"))
})

test_that("summariseMeasurementUse straifications work", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)
  res <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = TRUE,
    byYear = TRUE,
    ageGroup = NULL,
    dateRange = as.Date(c("2000-01-01", "2005-01-01"))
  )
  expect_equal(
    res$strata_level |> unique(), c("overall", "Female", "Male", "2000", "2001", "2002", "2003", "2004")
  )
  expect_equal(
    res |>
      dplyr::filter(strata_level == "2000", result_id == 3, estimate_name == "count") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("1", "1", "1", "1")
  )
  expect_true(unique(omopgenerics::settings(res)$date_range) == "2000-01-01 to 2005-01-01")

  expect_equal(
    res |>
      dplyr::filter(group_name == "codelist_name", result_id != 1) |>
      dplyr::select(strata_name, strata_level, variable_name, variable_level, estimate_name, estimate_type, estimate_value),
    res |>
      dplyr::filter(group_name == "codelist_name &&& concept_name") |>
      dplyr::select(strata_name, strata_level, variable_name, variable_level, estimate_name, estimate_type, estimate_value)
  )

  res <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    byConcept = FALSE,
    bySex = FALSE,
    byYear = FALSE,
    ageGroup = NULL
  )
  expect_equal(
    omopgenerics::settings(res),
    dplyr::tibble(
      result_id = 1:3L,
      result_type = c("measurement_timings", "measurement_value_as_numeric", "measurement_value_as_concept"),
      package_name = "MeasurementDiagnostics",
      package_version = as.character(utils::packageVersion("MeasurementDiagnostics")),
      group = c("codelist_name", "codelist_name &&& unit_concept_name", "codelist_name"),
      strata = c(rep("", 3)),
      additional = c("", "unit_concept_id", "value_as_concept_id"),
      min_cell_count = "0"
    )
  )
  expect_equal(
    res |>
      dplyr::filter(group_level == "test3") |>
      dplyr::pull("estimate_value"),
    c("0", "0")
  )

})

test_that("summariseMeasurementUse expected fails", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)

  expect_error(summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = TRUE,
    byYear = TRUE,
    ageGroup = NULL,
    dateRange = as.Date(c("2006-01-01", "2005-01-01"))
  ))
  expect_error(summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = TRUE,
    byYear = 0,
    ageGroup = NULL,
    dateRange = as.Date(c("2000-01-01", "2005-01-01"))
  ))
  expect_error(summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = TRUE,
    byYear = TRUE,
    ageGroup = "0 to 10",
    dateRange = as.Date(c("2000-01-01", "2005-01-01"))
  ))
  expect_error(summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = TRUE,
    byYear = TRUE,
    ageGroup = NULL,
    dateRange = c(0, as.Date("2005-01-01"))
  ))
  expect_error(summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = TRUE,
    byYear = TRUE,
    ageGroup = NULL,
    checks = "measurement_records"
  ))
})

test_that("summariseMeasurementUse checks", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)
  res <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = FALSE,
    byYear = FALSE,
    ageGroup = NULL,
    dateRange = as.Date(c("2000-01-01", "2005-01-01")),
    checks = "measurement_timings"
  )

  expect_true(unique(res$result_id) == 1)
  expect_true(omopgenerics::settings(res)$result_type == "measurement_timings")

  res <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = FALSE,
    byYear = FALSE,
    ageGroup = NULL,
    dateRange = as.Date(c("2000-01-01", "2005-01-01")),
    checks = c("measurement_value_as_numeric", "measurement_value_as_concept")
  )
  expect_true(all(omopgenerics::settings(res)$result_type %in% c("measurement_value_as_numeric", "measurement_value_as_concept")))

  expect_null(
    summariseMeasurementUse(
      cdm = cdm,
      codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
      bySex = FALSE,
      byYear = FALSE,
      ageGroup = NULL,
      dateRange = as.Date(c("2000-01-01", "2005-01-01")),
      checks = character()
    )
  )
})

test_that("summariseMeasurementUse observation domain", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)
  res <- summariseMeasurementUse(
    cdm = cdm,
    codes = list("mix" = c(3001467, 45875977, 194152, 4092121, 1033535)),
    bySex = FALSE,
    byYear = FALSE,
    ageGroup = NULL,
    dateRange = as.Date(c("2000-01-01", "2005-01-01")),
    checks = c("measurement_value_as_numeric", "measurement_value_as_concept")
  )
  tab <- res |> visOmopResults::splitAdditional() |> dplyr::filter(result_id == 2) |> dplyr::distinct(concept_id, domain_id)
  expect_equal(
    tab$concept_id |> sort(),
    c("3001467", "4092121", "overall")
  )
  expect_equal(
    tab$domain_id |> sort(),
    c("Measurement", "Observation", "overall")
  )
})

