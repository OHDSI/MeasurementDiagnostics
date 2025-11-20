test_that("summariseCohortMeasurementUse works", {
  skip_on_cran()
  cdm <- testMockCdm()
  cdm <- copyCdm(cdm)
  res <- summariseCohortMeasurementUse(codes = list("test" = 3001467L), cohort = cdm$my_cohort, timing = "any")
  expect_equal(
    omopgenerics::settings(res),
    dplyr::tibble(
      result_id = 1:3L,
      result_type = c("measurement_timings", "measurement_value_as_numeric", "measurement_value_as_concept"),
      package_name = "MeasurementDiagnostics",
      package_version = as.character(utils::packageVersion("MeasurementDiagnostics")),
      group = c("cohort_name &&& codelist_name", "cohort_name &&& codelist_name &&& concept_name &&& unit_concept_name", "cohort_name &&& codelist_name &&& concept_name"),
      strata = c(rep("", 3)),
      additional = c("", "concept_id &&& unit_concept_id &&& domain_id", "concept_id &&& value_as_concept_id &&& domain_id"),
      min_cell_count = "0",
      timing = "any"
    )
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("0", "0", "1", "1", "1", "1", "1", "10", "11", "1206", "14",
      "15", "1506", "1761", "18.1818181818182", "2", "2", "2", "2",
      "2.25", "20", "2316", "27.2727272727273", "3", "3", "35", "4",
      "4", "40", "4323", "5026", "54.5454545454545", "6", "651", "7",
      "8", "9", "96")
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(variable_name) |>
      sort(),
    c(rep("measurements_per_subject", 24), "number records", "number records", "number subjects", "number subjects", rep("time", 10))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_name) |>
      sort(),
    c(rep("count", 11), rep("max", 4), rep("median", 4), rep("min", 4), rep("percentage", 7), rep("q25", 4), rep("q75", 4))
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_name)|>
      sort() |>
      unique(),
    c("count", "count_missing", "max", "median",
      "min","percentage_missing", 'q01','q05', "q25", "q75", 'q95','q99')
  )
  expect_equal(
    res |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
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
})

test_that("test timings with eunomia", {
  skip_on_cran()
  skip_if(Sys.getenv("EUNOMIA_DATA_FOLDER") == "")
  # without cohort
  con <- DBI::dbConnect(duckdb::duckdb(), CDMConnector::eunomiaDir())
  cdm <- CDMConnector::cdmFromCon(con, cdmName = "eunomia", cdmSchema = "main", writeSchema = "main")
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
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("0.327391778828665", "0.350140056022409", "0.544662309368192",
      "0.582029829028738", "1", "1", "1.11266728913788", "1.25272331154684",
      "1.58730158730159", "1016", "1035", "112", "1160", "12.895598399418",
      "1227", "12852", "14.0989729225023", "14.5424836601307", "1426",
      "143", "1487", "15", "15.3672580143168", "15.406162464986", "1518",
      "161", "18", "18.4794470716624", "1812", "1869", "1975", "1980",
      "2", "2.03710440160058", "2.48210395269219", "204", "2329", "2442",
      "25.9367042560931", "252", "2656", "27.6100400145507", "3", "31573",
      "31880", "319", "32", "3493", "38", "39", "4", "4", "4.04606286959228",
      "4.54403983815749", "4.58348490360131", "415", "45", "4962",
      "520", "5498", "584", "6", "6.09243697478992", "7.54819934521644",
      "70", "709", "7481", "783", "8", "9", "9.02583255524432", "9.54715219421102"
    )
  )
  expect_equal(
    res_during |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
    c("1", "1", "1", "1", "1", "1", "1", "1", "1602", "1602", "1602",
      "1602", "1602", "1602", "1602", "1602", "1602", "1602", "2",
      "2", "2", "2", "27", "28", "29", "3.27868852459016", "59", "6.89655172413793",
      "60", "61", "93.1034482758621", "96.7213114754098")
  )
  expect_equal(
   res_start |>
      omopgenerics::filterSettings(result_type == "measurement_timings") |>
      dplyr::filter(strata_name == "overall", estimate_name != "density_x", estimate_name != "density_y") |>
      dplyr::pull(estimate_value) |>
      sort(),
   c("0", "0", "1", "1", "1", "1", "1", "1", "1", "1", "100")
  )
  expect_equal(
    res_any |>
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
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
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
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
      omopgenerics::filterSettings(result_type == "measurement_value_as_numeric") |>
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
      result_type = c("measurement_timings", "measurement_value_as_numeric", "measurement_value_as_concept"),
      package_name = "MeasurementDiagnostics",
      package_version = as.character(utils::packageVersion("MeasurementDiagnostics")),
      group = c("cohort_name &&& codelist_name", "cohort_name &&& codelist_name &&& concept_name &&& unit_concept_name", "cohort_name &&& codelist_name &&& concept_name"),
      strata = c(rep("sex &&& year", 3)),
      additional = c("", "concept_id &&& unit_concept_id &&& domain_id", "concept_id &&& value_as_concept_id &&& domain_id"),
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
      result_type = c("measurement_timings", "measurement_value_as_numeric", "measurement_value_as_concept"),
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
    checks = "measurement_timings"
  )
  expect_true(unique(res$result_id) == 1)
  expect_true(omopgenerics::settings(res)$result_type == "measurement_timings")

  res <- summariseCohortMeasurementUse(
    cohort = cdm$my_cohort,
    codes = list("test" = 3001467L, "test2" = 1L, "test3" = 45875977L),
    bySex = FALSE,
    byYear = FALSE,
    ageGroup = NULL,
    checks = c("measurement_value_as_numeric", "measurement_value_as_concept")
  )
  expect_true(all(omopgenerics::settings(res)$result_type %in% c("measurement_value_as_numeric", "measurement_value_as_concept")))

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
})
