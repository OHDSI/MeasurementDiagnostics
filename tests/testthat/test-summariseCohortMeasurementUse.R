test_that("summariseCohortMeasurementUse works", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)

  res <- summariseCohortMeasurementUse(codes = list("test" = 3001467L), cohort = cdm$my_cohort, timing = "any")
  expect_equal(
    omopgenerics::settings(res),
    dplyr::tibble(
      result_id = 1:3L,
      result_type = c("measurement_summary", "measurement_value_as_number", "measurement_value_as_concept"),
      package_name = "MeasurementDiagnostics",
      package_version = as.character(utils::packageVersion("MeasurementDiagnostics")),
      group = c("cohort_name &&& codelist_name", "cohort_name &&& codelist_name &&& concept_name &&& source_concept_name &&& unit_concept_name", "cohort_name &&& codelist_name &&& concept_name &&& source_concept_name"),
      strata = c(rep("", 3)),
      additional = c("", "concept_id &&& source_concept_id &&& unit_concept_id &&& domain_id", "concept_id &&& source_concept_id &&& value_as_concept_id &&& domain_id"),
      min_cell_count = "0",
      timing = "any"
    )
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_summary") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
    as.character(c(
      '1', '1', '1', '1', '1', '1', '1', '1093', '1206', '14', '16', '1761', '2', '2', '2316', '24', '24', '29', '3', '3320', '4354', '5026', '56.25', '58.3333333333333', '651', '9', '96', '96'
    ))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_summary") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(variable_name) |>
      sort(),
    c(
      rep("measurements_per_subject", 10), "Number records", "Number records",
      "Number subjects", "Number subjects", rep("Subjects with measurement", 4),
      rep("time", 10)
    )
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_summary") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_name) |>
      sort(),
    c(rep("count", 6), rep("max", 4), rep("median", 4), rep("min", 4), rep("percentage", 2), rep("q25", 4), rep("q75", 4))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_number") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_name)|>
      sort() |>
      unique(),
    c("count", "count_missing", "max", "median",
      "min","percentage_missing", 'q01','q05', "q25", "q75", 'q95','q99')
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_number") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name) |>
      sort() |>
      unique(),
    c("count", "count_missing", "density_x", "density_y", "max", "median",
      "min","percentage_missing", "q01", "q05", "q25", "q75", "q95", "q99")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c('1', '1', '25', '25', '30', '30', '36.3636363636364', '36.3636363636364',
      '4', '4', '45', '45', '5', '5', '54.5454545454545', '54.5454545454545',
      '6', '6', '6', '6', '9', '9', '9.09090909090909', '9.09090909090909')
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall") |>
      dplyr::pull(estimate_name) |>
      sort(),
    c('count', 'count', 'count', 'count', 'count', 'count', 'count', 'count', 'count',
    'count', 'count', 'count', 'percentage', 'percentage', 'percentage', 'percentage',
    'percentage', 'percentage', 'percentage', 'percentage', 'percentage', 'percentage',
    'percentage', 'percentage')
  )

  # use codelist attribute ----
  cdm$my_cohort <- cdm$my_cohort |>
    omopgenerics::newCohortTable(
      cohortCodelistRef = dplyr::tibble(
        cohort_definition_id = 1:2L,
        codelist_name = "test",
        concept_id = 3001467L,
        codelist_type = "index event"
      )
    )
  resAttribute <- summariseCohortMeasurementUse(cohort = cdm$my_cohort, timing = "any")
  expect_equal(res |> dplyr::arrange(group_level, estimate_value), resAttribute |> dplyr::arrange(group_level, estimate_value))

  cdm$my_cohort <- cdm$my_cohort |>
    omopgenerics::newCohortTable(
      cohortCodelistRef = dplyr::tibble(
        cohort_definition_id = 1:2L,
        codelist_name = "test",
        concept_id = c(3001467L, 45875977L),
        codelist_type = "index event"
      )
    )
  resAttribute <- summariseCohortMeasurementUse(cohort = cdm$my_cohort, timing = "any")
  expect_equal(
    resAttribute$group_level |> unique(),
    c('cohort_1 &&& test', 'cohort_2 &&& test', 'cohort_1 &&& test &&& kilogram',
      'cohort_1 &&& test &&& NA',
      'cohort_1 &&& test &&& Alkaline phosphatase.bone [Enzymatic activity/volume] in Serum or Plasma &&& Alkaline phosphatase.bone &&& kilogram',
      'cohort_1 &&& test &&& Alkaline phosphatase.bone [Enzymatic activity/volume] in Serum or Plasma &&& Alkaline phosphatase.bone &&& NA',
      'cohort_1 &&& test &&& Alkaline phosphatase.bone [Enzymatic activity/volume] in Serum or Plasma &&& Alkaline phosphatase.bone')
  )
  # "Subjects with measurement" indicating 0 subjects:
  expect_equal(
    resAttribute |>
      omopgenerics::filterGroup(cohort_name == "cohort_2", codelist_name == "test") |>
      dplyr::pull("estimate_value"),
    c("0", "0")
  )

  # Histogram ----
  expect_warning(
    res <- summariseCohortMeasurementUse(
      cohort = cdm$my_cohort,
      codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
      bySex = TRUE,
      ageGroup = list(c(0, 17), c(18, 64), c(65, 150)),
      histogram = list(
        "blahblah" = list("blah" = c(0, Inf)),
        "time" = list('0 to 100' = c(0, 100), '110 to 200' = c(110, 200), '210 to 300' = c(210, 300), '310 to Inf' = c(310, Inf)),
        "measurements_per_subject" = list('0 to 10' = c(0, 10), '11 to 20' = c(11, 20), '21 to 30' = c(21, 30), '31 to Inf' = c(31, Inf)),
        "value_as_number" =  list('0 to 5' = c(0, 5), '6 to 10' = c(6, 10), '11 to 15' = c(11, 15), '>15' = c(16, Inf))
      )
    )
  )

  expect_true(all(
    res$variable_name |> unique() %in% c(
      "number records", "number subjects", "time", "measurements_per_subject",
      "value_as_number", "value_as_concept_name"
    )
  ))
  expect_equal(
    res |> dplyr::filter(.data$estimate_name == "count", .data$variable_name %in% c("time", "measurements_per_subject", "value_as_number")) |> dplyr::pull(variable_level) |> unique(),
    c("0 to 10", ">15" )
  )

  dropCreatedTables(cdm = cdm)
})

test_that("test timings with eunomia", {
  skip_on_cran()
  cdm <- omock::mockCdmFromDataset(datasetName = "GiBleed", source = "local") |>
    copyCdm()

  cohort <- CohortConstructor::conceptCohort(cdm = cdm, conceptSet = list("condition" = 40481087L), name = "cohort")
  res_any <- summariseCohortMeasurementUse(
    codes = list("bmi" = c(4024958L, 36304833L), "egfr" = c(1619025L, 1619026L, 3029829L, 3006322L)),
    cohort = cohort, timing = "any"
  )
  res_during <- summariseCohortMeasurementUse(
    codes = list("bmi" = c(4024958L, 36304833L), "egfr" = c(1619025L, 1619026L, 3029829L, 3006322L)),
    cohort = cohort, timing = "during"
  )
  res_start <- summariseCohortMeasurementUse(
    codes = list("bmi" = c(4024958L, 36304833L), "egfr" = c(1619025L, 1619026L, 3029829L, 3006322L)),
    cohort = cohort, timing = "cohort_start_date"
  )
  expect_equal(
    res_any |>
      omopgenerics::filterSettings(result_type == "measurement_summary") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c('1', '1', '1', '1035', '1487', '15', '17268', '2', '2329', '2442', '2656', '2686', '3', '3', '31573', '31880', '3493', '38', '39', '4962', '5', '6', '7481', '86.7088607594937', '9', '98.8830975428146')
  )
  expect_equal(
    res_during |>
      omopgenerics::filterSettings(result_type == "measurement_summary") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c('1', '1', '1', '1', '1', '1', '1', '1', '1.04244229337305', '1602', '1602', '1602', '1602', '1602', '1602', '1602', '1602', '1602', '1602', '17268', '2', '2', '2.23380491437081', '2686', '28', '60')
  )
  expect_equal(
    res_start |>
      omopgenerics::filterSettings(result_type == "measurement_summary") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c('0', '0', '0.0372300819061802', '1', '1', '1', '1', '1', '1', '17268', '2686')
  )
  expect_equal(
    res_any |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_number") |>
      dplyr::filter(
        strata_name == "overall",
        group_name != "cohort_name &&& codelist_name &&& unit_concept_name",
        estimate_name != "density_x", estimate_name != "density_y"
      ) |>
      dplyr::pull(estimate_value) |>
      sort(),
    c('100', '100', '12852', '12852', '5498', '5498')
  )
  expect_equal(
    res_during |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_number") |>
      dplyr::filter(
        strata_name == "overall",
        group_name != "cohort_name &&& codelist_name &&& unit_concept_name",
        estimate_name != "density_x", estimate_name != "density_y"
      ) |>
      dplyr::pull(estimate_value) |>
      sort(),
    c('100', '100', '29', '29', '61', '61')
  )
  expect_equal(
    res_start |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_number") |>
      dplyr::filter(
        strata_name == "overall",
        group_name != "cohort_name &&& codelist_name &&& unit_concept_name",
        estimate_name != "density_x", estimate_name != "density_y"
      ) |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("1", "1", "100")
  )
  expect_equal(
    res_any |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall", group_name != "cohort_name &&& codelist_name") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("100", "100", "12852", "5498")
  )
  expect_equal(
    res_during |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall", group_name != "cohort_name &&& codelist_name") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("100", "100", "29", "61")
  )
  expect_equal(
    res_start |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_concept") |>
      dplyr::filter(strata_name == "overall", group_name != "cohort_name &&& codelist_name") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("1", "100")
  )

  dropCreatedTables(cdm = cdm)
})

test_that("summariseCohortMeasurementUse straifications work", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)

  res <- summariseCohortMeasurementUse(
    cohort = cdm$my_cohort,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = TRUE,
    byYear = TRUE,
    ageGroup = NULL,
    dateRange = as.Date(c("1995-01-01", "2020-01-01"))
  )
  expect_equal(
    res$strata_level |> unique(), c("overall", "Male", "2015" )
  )
  expect_equal(
    res |>
      dplyr::filter(result_id == 3, estimate_name == "count", strata_name == "year", group_level == "cohort_1 &&& test") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("1")
  )
  expect_equal(
    omopgenerics::settings(res),
    dplyr::tibble(
      result_id = 1:3L,
      result_type = c("measurement_summary", "measurement_value_as_number", "measurement_value_as_concept"),
      package_name = "MeasurementDiagnostics",
      package_version = as.character(utils::packageVersion("MeasurementDiagnostics")),
      group = c("cohort_name &&& codelist_name", "cohort_name &&& codelist_name &&& concept_name &&& source_concept_name &&& unit_concept_name", "cohort_name &&& codelist_name &&& concept_name &&& source_concept_name"),
      strata = c(rep("sex &&& year", 3)),
      additional = c("", "concept_id &&& source_concept_id &&& unit_concept_id &&& domain_id", "concept_id &&& source_concept_id &&& value_as_concept_id &&& domain_id"),
      min_cell_count = "0",
      date_range = "1995-01-01 to 2020-01-01",
      timing = "during"
    )
  )

  res <- summariseCohortMeasurementUse(
    cohort = cdm$my_cohort,
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
      result_type = c("measurement_summary", "measurement_value_as_number", "measurement_value_as_concept"),
      package_name = "MeasurementDiagnostics",
      package_version = as.character(utils::packageVersion("MeasurementDiagnostics")),
      group = c("cohort_name &&& codelist_name", "cohort_name &&& codelist_name &&& unit_concept_name", "cohort_name &&& codelist_name"),
      strata = c(rep("", 3)),
      additional = c("", "unit_concept_id", "value_as_concept_id"),
      min_cell_count = "0",
      timing = "during"
    )
  )
  expect_equal(
    res |>
      dplyr::filter(group_level == "cohort_1 &&& test3") |>
      dplyr::pull("estimate_value"),
    c("0", "0")
  )

  dropCreatedTables(cdm = cdm)
})

test_that("summariseMeasurementUse checks", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)

  res <- summariseCohortMeasurementUse(
    cohort = cdm$my_cohort,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = FALSE,
    byYear = FALSE,
    ageGroup = NULL,
    checks = "measurement_summary"
  )
  expect_true(unique(res$result_id) == 1)
  expect_true(omopgenerics::settings(res)$result_type == "measurement_summary")

  res <- summariseCohortMeasurementUse(
    cohort = cdm$my_cohort,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = FALSE,
    byYear = FALSE,
    ageGroup = NULL,
    checks = c("measurement_value_as_number", "measurement_value_as_concept")
  )
  expect_true(all(omopgenerics::settings(res)$result_type %in% c("measurement_value_as_number", "measurement_value_as_concept")))

  expect_null(
    summariseCohortMeasurementUse(
      cohort = cdm$my_cohort,
      codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
      bySex = FALSE,
      byYear = FALSE,
      ageGroup = NULL,
      dateRange = as.Date(c("2000-01-01", "2005-01-01")),
      checks = character()
    )
  )

  dropCreatedTables(cdm = cdm)
})
