#' Diagnostics of a codelist of measurement codes in the database
#'
#' @inheritParams summariseMeasurementDoc
#'
#' @return A summarised result
#' @export
#'
#' @examples
#' \donttest{
#' library(MeasurementDiagnostics)
#'
#' cdm <- mockMeasurementDiagnostics()
#'
#' result <- summariseMeasurementUse(
#'   cdm = cdm, codes = list("test_codelist" = c(3001467L, 45875977L))
#' )
#'
#' resultHistogram <- summariseMeasurementUse(
#'   cdm = cdm,
#'   codes = list("test_codelist" = c(3001467L, 45875977L)),
#'   byConcept = TRUE,
#'   byYear = FALSE,
#'   bySex = FALSE,
#'   ageGroup = NULL,
#'   dateRange = as.Date(c(NA, NA)),
#'   estimates = list(
#'     "measurement_summary" = c("min", "q25", "median", "q75", "max", "density"),
#'     "measurement_value_as_number" = c(
#'       "min", "q01", "q05", "q25", "median", "q75", "q95", "q99", "max",
#'       "count_missing", "percentage_missing", "density"
#'     ),
#'     "measurement_value_as_concept" = c("count", "percentage")
#'   ),
#'   histogram = list(
#'     "days_between_measurements" = list(
#'       '0 to 100' = c(0, 100), '110 to 200' = c(110, 200),
#'       '210 to 300' = c(210, 300), '310 to Inf' = c(310, Inf)
#'     ),
#'     "measurements_per_subject" = list(
#'       '0 to 10' = c(0, 10), '11 to 20' = c(11, 20),
#'       '21 to 30' = c(21, 30), '31 to Inf' = c(31, Inf)
#'     ),
#'     "value_as_number" =  list(
#'       '0 to 5' = c(0, 5), '6 to 10' = c(6, 10),
#'       '11 to 15' = c(11, 15), '>15' = c(16, Inf)
#'     )
#'   ),
#'   checks = c("measurement_summary", "measurement_value_as_number", "measurement_value_as_concept")
#' )
#'
#' # more than one age group:
#' result <- summariseMeasurementUse(
#'   cdm = cdm,
#'   codes = list("test_codelist" = c(3001467L, 45875977L)),
#'   ageGroup = list(
#'     "age_group_1" = list(c(0, 17), c(18, 64), c(65, 150)),
#'     "age_group_2" = list(c(0, 19), c(20, 39), c(40, 59), c(60, 79), c(80, 99), c(100, 120))
#'   )
#' )
#'
#' CDMConnector::cdmDisconnect(cdm = cdm)
#'}
#'

summariseMeasurementUse <- function(cdm,
                                    codes,
                                    byConcept = TRUE,
                                    byYear = FALSE,
                                    bySex = FALSE,
                                    ageGroup = NULL,
                                    dateRange = as.Date(c(NA, NA)),
                                    personSample = 20000,
                                    estimates = list(
                                      "measurement_summary" = c("min", "q25", "median", "q75", "max", "density"),
                                      "measurement_value_as_number" = c("min", "q01", "q05", "q25", "median", "q75", "q95", "q99", "max", "count_missing", "percentage_missing", "density"),
                                      "measurement_value_as_concept" = c("count", "percentage")
                                    ),
                                    histogram = NULL,
                                    checks = c("measurement_summary", "measurement_value_as_number", "measurement_value_as_concept")) {
  # check inputs
  cdm <- omopgenerics::validateCdmArgument(cdm)

  result <- summariseMeasurementUseInternal(
    cdm = cdm,
    codes = codes,
    cohort = NULL,
    timing = "any",
    timingName = NULL,
    byConcept = byConcept,
    byYear = byYear,
    bySex = bySex,
    ageGroup = ageGroup,
    dateRange = dateRange,
    personSample = personSample,
    estimates = estimates,
    histogram = histogram,
    checks = checks
  )

  return(result)
}


summariseMeasurementUseInternal <- function(cdm,
                                            codes,
                                            cohort,
                                            timing,
                                            timingName,
                                            byConcept,
                                            byYear,
                                            bySex,
                                            ageGroup,
                                            dateRange,
                                            personSample,
                                            estimates,
                                            histogram,
                                            checks) {
  # checks
  if (is.null(codes)) {
    codesTable <- attr(cohort, "cohort_codelist")
    codes <- omopgenerics::newCodelist(codesTable)
  } else {
    codesTable <- NULL
    codes <- omopgenerics::validateConceptSetArgument(codes)
  }
  ageGroup <- omopgenerics::validateAgeGroupArgument(ageGroup = ageGroup)
  omopgenerics::assertNumeric(personSample, min = 1, null = TRUE, length = 1)
  omopgenerics::assertLogical(byConcept, length = 1)
  omopgenerics::assertLogical(byYear, length = 1)
  omopgenerics::assertLogical(bySex, length = 1)
  omopgenerics::assertDate(dateRange, length = 2, na = TRUE)
  allowedChecks <- c("measurement_summary", "measurement_value_as_number", "measurement_value_as_concept")
  omopgenerics::assertChoice(checks, choices = allowedChecks)
  estimates <- validateEstimates(estimates, allowedChecks)
  histogram <- validateHistogram(histogram)
  if (all(!is.na(dateRange))) {
    if (dateRange[1] > dateRange[2]) {
      cli::cli_abort("First date component in `dateRange` must be smaller than the second.")
    }
  }

  if (length(checks) == 0) return(NULL)

  prefix <- omopgenerics::tmpPrefix()

  if (is.null(cohort)) {
    cohortName <- NULL
  } else {
    cohort <- omopgenerics::validateCohortArgument(cohort)
    cohortName <- omopgenerics::tableName(cohort)
  }

  installedVersion <- as.character(utils::packageVersion("MeasurementDiagnostics"))

  if (length(estimates) == 0 & length(histogram) == 0) {
    return(omopgenerics::emptySummarisedResult())
  }

  ## measurement cohort
  # settings
  measurementSettings <- purrr::imap_dfr(
    .x = codes,
    .f = ~ dplyr::tibble(cohort_name = paste0(.y, "_", .x), codelist_name = .y, concept_id = .x)
  ) |>
    dplyr::mutate(cohort_definition_id = dplyr::row_number())
  settingsTableName <- omopgenerics::uniqueTableName(prefix = prefix)
  cdm <- omopgenerics::insertTable(
    cdm = cdm,
    name = settingsTableName,
    table = measurementSettings
  )
  cdm[[settingsTableName]] <- cdm[[settingsTableName]] |>
    dplyr::left_join(
      cdm$concept |> dplyr::select(dplyr::all_of(c("concept_id", "concept_name", "domain_id"))),
      by = "concept_id"
    )

  nStart <- dplyr::pull(dplyr::tally(cdm[[settingsTableName]]))
  cdm[[settingsTableName]] <- cdm[[settingsTableName]] |>
    dplyr::filter(tolower(.data$domain_id) %in% c("measurement", "observation")) |>
    dplyr::compute(name = settingsTableName, temporary = FALSE)
  nEnd <- dplyr::pull(dplyr::tally(cdm[[settingsTableName]]))
  if (nStart != nEnd) cli::cli_inform(c("!" = "{nStart-nEnd} concept{?s} excluded for not being in the measurement/observation domain"))
  addIndex(cdm[[settingsTableName]], cols = "concept_id")

  # cohort
  measurementCohortName <- omopgenerics::uniqueTableName(prefix = prefix)
  cdm[[measurementCohortName]] <- getCohortFromCodes(
    cdm = cdm, codes = codes,  settingsTableName = settingsTableName,
    name = measurementCohortName, personSample = personSample, prefix = prefix
  )

  cli::cli_inform(c(">" = "Subsetting records to the subjects and timing of interest."))
  # subset to cohort and timing
  measurement <- subsetMeasurementTable(
    cdm = cdm, cohortName = cohortName, codesTable = codesTable,
    timing = timing, name = measurementCohortName, dateRange = dateRange,
    prefix = prefix
  )
  measurement <- measurement |>
    dplyr::rename("subject_id" = "person_id", "cohort_start_date" = "record_date") |>
    dplyr::mutate(cohort_end_date = .data$cohort_start_date) |>
    dplyr::compute(name = measurementCohortName, temporary = FALSE) |>
    omopgenerics::newCohortTable(
      cohortSetRef = measurementSettings,
      .softValidation = TRUE # allow overlap
    )
  if (dplyr::pull(dplyr::tally(measurement)) == 0) {
    cli::cli_warn("No records were found.")
    return(omopgenerics::emptySummarisedResult())
  }

  # histogram flags
  timeHistogramFlag <- "days_between_measurements" %in% names(histogram) & "measurement_summary" %in% checks
  measurementsSubjectHistogramFlag <- "measurements_per_subject" %in% names(histogram) & "measurement_summary" %in% checks
  numericHistogramFlag <- "value_as_number" %in% names(histogram) & "measurement_value_as_number" %in% checks

  # prepare table according to checks to do
  summaryFlag <- "measurement_summary" %in% checks & "measurement_summary" %in% names(estimates)
  valueAsNumberFlag <- "measurement_value_as_number" %in% checks & "measurement_value_as_number" %in% names(estimates)
  valueAsConceptFlag <- "measurement_value_as_concept" %in% checks & "measurement_value_as_concept" %in% names(estimates)
  sourceConceptFlag <- byConcept & (valueAsNumberFlag | valueAsConceptFlag  | timeHistogramFlag | measurementsSubjectHistogramFlag | numericHistogramFlag)
  indexCols <- c("codelist_name", "unit_concept_id", "source_concept_id", "value_as_concept_id")[c(TRUE, valueAsNumberFlag, sourceConceptFlag, valueAsConceptFlag)]
  addIndex(measurement, cols = indexCols)
  # unit concept name
  if (valueAsNumberFlag | numericHistogramFlag) {
    measurement <- measurement |> addConceptName(prefix = "unit")
  }
  # source concept name
  if (sourceConceptFlag) {
    measurement <- measurement |> addConceptName(prefix = "source")
  }
  # value as concept name
  if (valueAsConceptFlag) {
    measurement <- measurement |> addConceptName(prefix = "value_as")
  }

  # group and strata
  baseGroup <- c("cohort_name", "codelist_name")[c(!is.null(cohort), TRUE)]
  byConceptGroup <- c("concept_id", "source_concept_id", "source_concept_name")
  unitGroup <- c("unit_concept_id", "unit_concept_name")
  ageStrata <- names(ageGroup)
  strata <- as.list(c("sex"[bySex], ageStrata[length(ageGroup)>0], "year"[byYear]))
  measurement <- measurement |> addStrata(bySex, byYear, ageGroup, measurementCohortName)

  ## measurements per subject
  if (summaryFlag | measurementsSubjectHistogramFlag | timeHistogramFlag) {
    cli::cli_inform(c(">" = "Getting time between records per person."))
    groupCols <- c("cohort_name"[!is.null(cohort)], "codelist_name", "subject_id")

    measurement <- measurement |>
      dplyr::group_by_at(groupCols) |>
      dplyr::arrange(.data$cohort_start_date) |>
      dplyr::mutate(previous_measurement = dplyr::lag(.data$cohort_start_date)) |>
      dplyr::mutate(
        days_between_measurements = as.integer(clock::date_count_between(
          start = .data$previous_measurement,
          end = .data$cohort_start_date,
          precision = "day"
        ))
      ) |>
      dplyr::ungroup() |>
      dplyr::compute(name = measurementCohortName, temporary = FALSE)

    if (timeHistogramFlag) {
      measurement <- measurement |>
        dplyr::mutate(!!!histogramBandExpr(histogram[["days_between_measurements"]], name = "days_between_measurements", newName = "days_between_measurements_band")) |>
        dplyr::compute(name = measurementCohortName, temporary = FALSE)
    }

    if (summaryFlag | timeHistogramFlag) {
      measurementSummary <- list()
      for (codelistName in unique(measurementSettings$codelist_name)) {
        measurementTimingTbl <- measurement |>
          dplyr::inner_join(
            cdm[[settingsTableName]] |>
              dplyr::filter(.data$codelist_name == .env$codelistName) |>
              dplyr::select("codelist_name"),
            by = "codelist_name"
          )
        if (hasRecords(measurementTimingTbl)) {
          cli::cli_inform("Summarising timings")
          measurementSummary[[codelistName]] <- measurementTimingTbl |>
            PatientProfiles::summariseResult(
              group = list(baseGroup),
              includeOverallGroup = FALSE,
              strata = strata,
              includeOverallStrata = TRUE,
              variables = c("days_between_measurements", "days_between_measurements_band")[c(summaryFlag, timeHistogramFlag)],
              estimates = c(estimates$measurement_summary[c(rep(summaryFlag, length(estimates$measurement_summary)))], "count"[timeHistogramFlag]),
              counts = TRUE
            )
        }
      }
    } else {
      measurementSummary[["counts"]] <- measurement |>
        PatientProfiles::summariseResult(
          group = list(baseGroup),
          includeOverallGroup = FALSE,
          strata = strata,
          includeOverallStrata = TRUE,
          counts = TRUE
        )
    }

    if (summaryFlag | measurementsSubjectHistogramFlag) {
      cli::cli_inform(c(">" = "Getting measurements per subject."))

      measurementsSubjectName <- omopgenerics::uniqueTableName(prefix = prefix)
      measurement <- measurement |>
        dplyr::mutate(overall = "overall")

      for (strataName in c("overall", unlist(strata))) {
        measurementSubjects <- measurement |>
          dplyr::group_by_at(c(unlist(baseGroup), strataName, "subject_id")) |>
          dplyr::summarise(
            measurements_per_subject = dplyr::n(),
            .groups = "drop"
          ) |>
          dplyr::compute(name = measurementsSubjectName, temporary = FALSE)

        if (measurementsSubjectHistogramFlag) {
          measurementSubjects <- measurementSubjects |>
            dplyr::mutate(!!!histogramBandExpr(histogram[["measurements_per_subject"]], name = "measurements_per_subject", newName = "measurements_per_subject_band")) |>
            dplyr::compute(name = measurementsSubjectName, temporary = FALSE)
        }

        x <- measurementSubjects |>
          PatientProfiles::summariseResult(
            group = list(baseGroup),
            includeOverallGroup = FALSE,
            strata = strataName,
            includeOverallStrata = FALSE,
            variables = c("measurements_per_subject"[summaryFlag], "measurements_per_subject_band"[measurementsSubjectHistogramFlag]),
            estimates = c(estimates$measurement_summary[c(rep(summaryFlag, length(estimates$measurement_summary)))], "count"[measurementsSubjectHistogramFlag]),
            counts = FALSE
          )
        measurementSummary[[paste0("subjects_", strataName)]] <- x |>
          omopgenerics::newSummarisedResult(
            settings = omopgenerics::settings(x) |>
              dplyr::mutate(strata = paste0(unlist(.env$strata), collapse = " &&& "))
          )
      }
    }

    measurementSummary <- measurementSummary |>
      addSubjectsWithMeasurement(cdm, cohortName, baseGroup, strata, prefix, bySex, byYear, ageGroup) |>
      transformMeasurementRecords(
        cdm, newSet = cdm[[settingsTableName]] |> dplyr::collect(),
        installedVersion, timingName, cohortName, dateRange
      )
  } else {
    measurementSummary <- NULL
  }

  ## measurement value as numeric
  if (valueAsNumberFlag | numericHistogramFlag) {
    cli::cli_inform(c(">" = "Summarising results - value as number."))
    valueAsNumber <- list()

    if (numericHistogramFlag) {
      measurement <- measurement |>
        dplyr::mutate(!!!histogramBandExpr(histogram[["value_as_number"]], name = "value_as_number", newName = "value_as_number_band")) |>
        dplyr::compute(name = measurementCohortName, temporary = FALSE)
    }

    for (codelistName in unique(measurementSettings$codelist_name)) {
      valueAsNumberTbl <- measurement |>
        dplyr::inner_join(
          cdm[[settingsTableName]] |>
            dplyr::filter(.data$codelist_name == .env$codelistName) |>
            dplyr::select("codelist_name"),
          by = "codelist_name"
        ) |>
        dplyr::select(!dplyr::any_of(c("value_as_concept_id", "value_as_concept_name")))
      if (hasRecords(valueAsNumberTbl)) {
        cli::cli_inform("Summarising value as number")
        valueAsNumber[[codelistName]] <- valueAsNumberTbl |>
          PatientProfiles::summariseResult(
            group = list(c(baseGroup, unitGroup), c(baseGroup, byConceptGroup, unitGroup))[c(TRUE, byConcept)],
            includeOverallGroup = FALSE,
            strata = strata,
            includeOverallStrata = TRUE,
            variables = c("value_as_number"[valueAsNumberFlag], "value_as_number_band"[numericHistogramFlag]),
            estimates = c(estimates$measurement_value_as_number[c(rep(valueAsNumberFlag, length(estimates$measurement_value_as_number)))], "count"[numericHistogramFlag]),
            counts = TRUE,
            weights = NULL
          )
      }
    }
    measurementNumber <- omopgenerics::bind(valueAsNumber) |>
      dplyr::filter(.data$variable_name != "number subjects") |>
      dplyr::filter(!(.data$variable_name %in% c("days_between_measurements", "measurements_per_subject") & .data$estimate_name == "count")) |>
      dplyr::mutate(variable_name = gsub("_band", "", .data$variable_name)) |>
      transformMeasurementValue(
        cdm = cdm, newSet = cdm[[settingsTableName]] |> dplyr::collect(),
        cohortName = cohortName, installedVersion = installedVersion,
        timing = timingName, byConcept = byConcept, dateRange
      )
  } else {
    measurementNumber <- NULL
  }

  ## measurement value as concept
  if (valueAsConceptFlag) {
    cli::cli_inform(c(">" = "Summarising results - value as concept."))
    valueAsConcept <- list()
    for (codelistName in unique(measurementSettings$codelist_name)) {
      valueAsConceptTbl <-  measurement |>
        dplyr::inner_join(
          cdm[[settingsTableName]] |>
            dplyr::filter(.data$codelist_name == .env$codelistName) |>
            dplyr::select("codelist_name"),
          by = "codelist_name"
        ) |>
        dplyr::collect() |>
        dplyr::mutate(
          value_as_concept_id = paste0(as.character(.data$value_as_concept_id), " &&& ", .data$value_as_concept_name)
        )
      if (hasRecords(valueAsConceptTbl)) {
        cli::cli_inform("Summarising value as number")
        valueAsConcept[[codelistName]] <- valueAsConceptTbl |>
          PatientProfiles::summariseResult(
            group = list(baseGroup, c(baseGroup, byConceptGroup))[c(TRUE, byConcept)],
            includeOverallGroup = FALSE,
            strata = strata,
            includeOverallStrata = TRUE,
            variables = "value_as_concept_id",
            estimates = estimates$measurement_value_as_concept,
            counts = FALSE,
            weights = NULL
          )
      }
    }
    measurementConcept <- omopgenerics::bind(valueAsConcept) |>
      transformMeasurementConcept(
        cdm = cdm, newSet = cdm[[settingsTableName]] |> dplyr::collect(),
        cohortName = cohortName, installedVersion = installedVersion,
        timing = timingName, byConcept = byConcept, dateRange
      )
  } else {
    measurementConcept <- NULL
  }

  cli::cli_inform(c(">" = "Binding all diagnostic results."))
  omopgenerics::dropSourceTable(cdm = cdm, name = dplyr::starts_with(prefix))

  return(
    omopgenerics::bind(
      measurementSummary, measurementNumber, measurementConcept
    ) |>
      dplyr::mutate(cdm_name = omopgenerics::cdmName(cdm))
  )
}


groupIdToName <- function(x, newSet, cols = c("codelist_name", "concept_name")) {
  x |>
    dplyr::left_join(
      newSet |>
        dplyr::select(dplyr::all_of(c("concept_id", "concept_name", "domain_id"))) |>
        dplyr::mutate(concept_id = as.character(.data$concept_id)),
      by = "concept_id"
    ) |>
    omopgenerics::uniteGroup(cols = cols)
}

subsetMeasurementTable <- function(cdm, cohortName, codesTable, timing, name, dateRange, prefix) {
  # if ANY : no need to filter for dates
  # if DURING : needs to be in observation / in cohort
  # if COHORT_START_DATE : cohort_start_date/observation_period_start_date = measurement date

  if (is.null(cohortName) & timing == "any") {
    return(cdm[[name]] |> measurementInDateRange(dateRange, name))
  }

  codelistAttribute <- !is.null(codesTable)
  cohort <- cdm[[cohortName]]
  if (codelistAttribute) {
    cohort <- cohort |>
      dplyr::select(!dplyr::any_of(c("codelist_name", "concept_id"))) |>
      dplyr::inner_join(
        codesTable |>
          dplyr::distinct(.data$cohort_definition_id, .data$codelist_name, .data$concept_id),
        by = "cohort_definition_id"
      ) |>
      dplyr::compute(name = omopgenerics::uniqueTableName(prefix = prefix), temporary = FALSE) |>
      omopgenerics::newCohortTable()
  }
  cohort <- CohortConstructor::addCohortTableIndex(cohort)

  if (timing == "during") {
    measurement <- cdm[[name]] |>
      dplyr::inner_join(
        cohort |>
          PatientProfiles::addCohortName() |>
          dplyr::select(
            "person_id" = "subject_id", "cohort_start_date", "cohort_end_date", "cohort_name", "codelist_name"[codelistAttribute], "concept_id"[codelistAttribute]
          ),
        by = c("person_id", "codelist_name"[codelistAttribute], "concept_id"[codelistAttribute]),
        relationship = "many-to-many"
      ) |>
      dplyr::filter(
        .data$record_date >= .data$cohort_start_date,
        .data$record_date <= .data$cohort_end_date
      ) |>
      dplyr::select(!dplyr::all_of(c("cohort_start_date", "cohort_end_date"))) |>
      dplyr::compute(name = name, temporary = FALSE)
  }
  if (timing == "cohort_start_date") {
    measurement <- cdm[[name]] |>
      dplyr::inner_join(
        cohort |>
          PatientProfiles::addCohortName() |>
          dplyr::select(
            "person_id" = "subject_id", "record_date" = "cohort_start_date", "cohort_name", "codelist_name"[codelistAttribute], "concept_id"[codelistAttribute]
          ),
        by = c("person_id", "record_date", "codelist_name"[codelistAttribute], "concept_id"[codelistAttribute]),
        relationship = "many-to-many"
      ) |>
      dplyr::compute(name = name, temporary = FALSE)
  }
  if (timing == "any") {
    measurement <- cdm[[name]] |>
      dplyr::inner_join(
        cohort |>
          PatientProfiles::addCohortName() |>
          dplyr::select("person_id" = "subject_id", "cohort_name", "codelist_name"[codelistAttribute], "concept_id"[codelistAttribute]) |>
          dplyr::distinct(),
        by = c("person_id", "codelist_name"[codelistAttribute], "concept_id"[codelistAttribute])
      ) |>
      dplyr::compute(name = name, temporary = FALSE)
  }

  measurement <- measurement |> measurementInDateRange(dateRange, name)

  return(measurement)
}

measurementInDateRange <- function(x, dateRange, name) {
  if (!is.na(dateRange[1])) {
    x <- x |>
      dplyr::filter(.data$record_date >= !!dateRange[1])
  }
  if (!is.na(dateRange[2])) {
    x <- x |>
      dplyr::filter(.data$record_date <= !!dateRange[2])
  }
  return(
    x |> dplyr::compute(name = name, temporary = FALSE)
  )
}

addIndex <- function(cohort, cols) {
  # From CohortConstructor
  cdm <- omopgenerics::cdmReference(cohort)
  name <- omopgenerics::tableName(cohort)

  tblSource <- attr(cohort, "tbl_source")
  if(is.null(tblSource)){
    return(invisible(NULL))
  }
  dbType <- attr(tblSource, "source_type")
  if(is.null(dbType)){
    return(invisible(NULL))
  }

  if (dbType == "postgresql") {
    con <- attr(cdm, "dbcon")
    schema <- attr(cdm, "write_schema")
    if(length(schema) > 1){
      prefix <- attr(cdm, "write_schema")["prefix"]
      schema <- attr(cdm, "write_schema")["schema"]
    } else {
      prefix <- NULL
    }

    existingIndex <- DBI::dbGetQuery(con,
                                     paste0("SELECT * FROM pg_indexes WHERE",
                                            " schemaname = '",
                                            schema,
                                            "' AND tablename = '",
                                            paste0(prefix, name),
                                            "';"))
    if(nrow(existingIndex) > 0){
      cli::cli_inform("Index already existing so no new index added.")
      return(invisible(NULL))
    } else {
      cli::cli_inform("Adding indexes to table")
    }

    cols <- paste0(cols, collapse = ",")

    query <- paste0(
      "CREATE INDEX ON ",
      paste0(schema, ".", prefix, name),
      " (",
      cols,
      ");"
    )
    suppressMessages(DBI::dbExecute(con, query))
  }

  return(invisible(NULL))
}

transformMeasurementRecords <- function(x, cdm, newSet, installedVersion, timingName, cohortName, dateRange) {
  x <- x |>
    dplyr::select(!dplyr::starts_with("additional"))

  # fill codelist 0 counts
  if (!is.null(cohortName)) {
    empty <- tidyr::expand_grid(
      cohort_name = omopgenerics::settings(cdm[[cohortName]])$cohort_name,
      codelist_name = as.character(newSet |> dplyr::pull("codelist_name"))
    ) |>
      omopgenerics::uniteGroup(cols = c("cohort_name", "codelist_name")) |>
      dplyr::anti_join(x, by = c("group_name", "group_level"))

  } else {
    codelists <- as.character(newSet |> dplyr::pull("codelist_name"))
    empty <- dplyr::tibble(
      group_name = "codelist_name",
      group_level = codelists[!codelists %in% unique(x$group_level)]
    )
  }
  if (nrow(empty) > 0) {
    x <- dplyr::bind_rows(
      x,
      empty |>
        dplyr::mutate(
          result_id = 1L,
          strata_name = "overall",
          strata_level = "overall",
          variable_name = "number_subjects",
          variable_level = NA_character_,
          estimate_type = "integer",
          estimate_value = "0",
        ) |>
        dplyr::cross_join(dplyr::tibble(estimate_name = c("count", "percentage")))
    )
  }
  # to summarise result
  x <- x |>
    dplyr::mutate(
      cdm_name = omopgenerics::cdmName(cdm)
    ) |>
    omopgenerics::uniteAdditional() |>
    dplyr::select(omopgenerics::resultColumns()) |>
    updateSummarisedResultSettings(resultType = "measurement_summary", installedVersion, timingName, dateRange)

  return(x)
}

transformMeasurementValue <- function(x, cdm, newSet, cohortName, installedVersion, timing, byConcept, dateRange) {
  x <- x |>
    omopgenerics::splitGroup() |>
    omopgenerics::splitAdditional() |>
    dplyr::mutate(
      cdm_name = omopgenerics::cdmName(cdm),
      unit_concept_name = dplyr::if_else(
        is.na(.data$unit_concept_name), "-", .data$unit_concept_name
      ),
      unit_concept_id = dplyr::if_else(
        .data$unit_concept_id == "NA" | is.na(.data$unit_concept_id), "-", .data$unit_concept_id
      )
    )

  if (byConcept) {
    x <- x  |>
      dplyr::mutate(
        cdm_name = omopgenerics::cdmName(cdm),
        source_concept_name = dplyr::if_else(
          is.na(.data$source_concept_name), "-", .data$source_concept_name
        ),
        source_concept_id = dplyr::if_else(
          .data$source_concept_id == "NA" | is.na(.data$source_concept_id), "-", .data$source_concept_id
        )
      ) |>
      groupIdToName(newSet = newSet, cols = c("cohort_name"[!is.null(cohortName)], "codelist_name", "concept_name", "source_concept_name", "unit_concept_name")) |>
      omopgenerics::uniteAdditional(cols = c("concept_id", "source_concept_id", "unit_concept_id", "domain_id"))
  } else {
    x <- x |>
      omopgenerics::uniteGroup(cols = c("cohort_name"[!is.null(cohortName)], "codelist_name", "unit_concept_name")) |>
      omopgenerics::uniteAdditional(cols = c("unit_concept_id"))
  }

  x <- x  |>
    dplyr::select(omopgenerics::resultColumns()) |>
    updateSummarisedResultSettings(resultType = "measurement_value_as_number", installedVersion, timing, dateRange)

  return(x)
}

transformMeasurementConcept <- function(x, cdm, newSet, cohortName,
                                        installedVersion, timing, byConcept, dateRange) {
  x <- x |>
    dplyr::select(!c("additional_name", "additional_level")) |>
    dplyr::rename("value_as_concept_id" = "variable_level") |>
    dplyr::mutate(
      variable_level = gsub(".* &&& ", "", .data$value_as_concept_id),
      value_as_concept_id = gsub(" &&& .*", "", .data$value_as_concept_id),
      variable_name = gsub("_id", "_name", "value_as_concept_id"),
      cohort_table = cohortName,
      value_as_concept_id = dplyr::if_else(nchar(.data$value_as_concept_id) == 0, "-", .data$value_as_concept_id),
      variable_level = dplyr::if_else(nchar(.data$variable_level) == 0, "-", .data$variable_level)
    )

  if (byConcept) {
    x <- x |>
      omopgenerics::splitGroup() |>
      groupIdToName(newSet = newSet, cols = c("cohort_name"[!is.null(cohortName)], "codelist_name", "concept_name", "source_concept_name")) |>
      omopgenerics::uniteAdditional(cols = c("concept_id", "source_concept_id", "value_as_concept_id", "domain_id")) |>
      dplyr::select(omopgenerics::resultColumns())
  } else {
    x <- x |>
      omopgenerics::uniteAdditional(cols = c("value_as_concept_id")) |>
      dplyr::select(omopgenerics::resultColumns())
  }

  x <- x|>
    updateSummarisedResultSettings(resultType = "measurement_value_as_concept", installedVersion, timing, dateRange)

  return(x)
}

addStrata <- function(x, bySex, byYear, ageGroup, name) {
  if (bySex | length(ageGroup)>0) {
    x <- x |>
      PatientProfiles::addDemographics(
        sex = bySex,
        ageGroup = ageGroup,
        priorObservation = FALSE,
        futureObservation = FALSE,
        name = name
      )
  }

  if (byYear) {
    x <- x |>
      dplyr::mutate(year = clock::get_year(.data$cohort_start_date)) |>
      dplyr::compute(name = name, temporary = FALSE)
  }

  return(x)
}

updateSummarisedResultSettings <- function(x, resultType, installedVersion, timingName, dateRange) {
  group <- omopgenerics::groupColumns(x)
  if (length(group) > 0) paste0(unique(unlist(group)), collapse = " &&& ")
  additional <- omopgenerics::additionalColumns(x)
  if (length(additional) > 0) paste0(unique(unlist(additional)), collapse = " &&& ")
  if (!all(is.na(dateRange)) & length(dateRange) > 1) {
    date_range <- paste0(dateRange[1], " to ", dateRange[2])
  } else {
    date_range <- NULL
  }
  x |>
    omopgenerics::newSummarisedResult(
      settings = omopgenerics::settings(x) |>
        dplyr::mutate(
          result_type = resultType,
          package_name = "MeasurementDiagnostics",
          package_version = installedVersion,
          group = group,
          additional = additional,
          timing = timingName,
          date_range = date_range
        )
    )
}

getCohortFromCodes <- function(cdm, codes, settingsTableName, name, personSample, prefix) {

  domains <- cdm[[settingsTableName]] |> dplyr::pull("domain_id") |> unique() |> tolower()
  tables <- list()

  for (tab in domains) {
    n <- cdm[[settingsTableName]] |>
      dplyr::filter(tolower(.data$domain_id) == tab) |>
      dplyr::tally() |>
      dplyr::pull()

    tempName <- paste0(prefix, tab)

    if (!is.null(personSample)) {
      cli::cli_inform(c(">" = "Sampling {tab} table to {personSample} subjects"))
      cdm[[tempName]] <- cdm[[tab]] |>
        dplyr::inner_join(
          cdm$person |>
            dplyr::slice_sample(n = personSample) |>
            dplyr::select(dplyr::all_of("person_id")),
          by = "person_id"
        ) |>
        dplyr::compute(name = tempName, temporary = FALSE)
    } else {
      cdm[[tempName]] <- cdm[[tab]] |>
        dplyr::compute(name = tempName, temporary = FALSE)
    }

    cli::cli_inform(c(">" = "Getting {tab} records based on {n} concept{?s}."))
    tables[[tab]] <- cdm[[tempName]] |>
      dplyr::rename("concept_id" = !!paste0(tab, "_concept_id")) |>
      dplyr::inner_join(
        cdm[[settingsTableName]] |>
          dplyr::select(dplyr::all_of(c("cohort_definition_id", "concept_id", "codelist_name"))),
        by = "concept_id"
      ) |>
      dplyr::select(dplyr::all_of(c(
        "cohort_definition_id",
        "person_id",
        "record_date" = paste0(tab, "_date"),
        "record_id" = paste0(tab, "_id"),
        "codelist_name",
        "concept_id",
        "unit_concept_id",
        "value_as_number",
        "value_as_concept_id",
        "source_concept_id" = paste0(tab, "_source_concept_id")
      ))) |>
      dplyr::mutate(
        unit_concept_id = as.integer(.data$unit_concept_id),
        value_as_concept_id = as.integer(.data$value_as_concept_id)
      ) |>
      dplyr::compute(name = tempName, temporary = FALSE)
  }

  measurementCohort <- Reduce(dplyr::union_all, tables) |>
    dplyr::compute(name = name, temporary = FALSE)

  return(measurementCohort)
}

validateEstimates <- function(estimates, checks) {

  if (is.null(estimates)) {
    return(list())
  }
  if (any(!names(estimates) %in% checks)) {
    cli::cli_abort(c(
      "x" = "All elements of `estimates` must be named with valid diagnostics checks in `checks`.",
      ">" = "Each check in `checks` must have corresponding estimates."
    ))
  }

  allowedNumeric <- PatientProfiles::availableEstimates() |>
    dplyr::filter(.data$variable_type == "numeric") |>
    dplyr::pull("estimate_name")
  allowedCategorical <- PatientProfiles::availableEstimates() |>
    dplyr::filter(.data$variable_type == "categorical") |>
    dplyr::pull("estimate_name")

  # check numeric
  for (nm in c("measurement_value_as_number", "measurement_summary")) {
    if (nm %in% names(estimates)) {
      estimatesNumeric <- estimates[[nm]][!grepl("q", estimates[[nm]])]
      notAllowed <- !estimatesNumeric %in% allowedNumeric
      if (sum(notAllowed) > 0) {
        cli::cli_warn("{estimatesNumeric[notAllowed]} in `estimates` not allowed for '{nm}', and will be ignored.")
        estimates[[nm]] <- estimates[[nm]][!estimates[[nm]] %in% estimatesNumeric[notAllowed]]
      }
    }
  }

  # check categorical
  if ("measurement_value_as_concept" %in% names(estimates)) {
    estimatesCategorical <- estimates[["measurement_value_as_concept"]]
    notAllowed <- !estimatesCategorical %in% allowedCategorical
    if (sum(notAllowed) > 0) {
      cli::cli_warn("{estimatesCategorical[notAllowed]} in `estimates` not allowed for 'measurement_value_as_concept', and will be ignored.")
      estimates[["measurement_value_as_concept"]] <- estimatesCategorical[!notAllowed]
    }
  }

  estimates <- estimates[!sapply(estimates, \(x){length(x)==0})]

  return(estimates)
}

validateHistogram <- function(histogram) {
  omopgenerics::assertList(histogram, null = TRUE, named = TRUE)
  newHistogram <- list()
  for (nm in names(histogram)) {
    # check name
    if (!nm %in% c("days_between_measurements", "measurements_per_subject", "value_as_number")) {
      cli::cli_warn(c(
        "{nm} is not a `check` for which to get estimates for a histogram.",
        "i" = "Options are: 'days_between_measurements', 'measurements_per_subject', and 'value_as_number'."
      ))
    }
    # check bandwidth & correct/add names
    newHistogram[[nm]] <- omopgenerics::validateWindowArgument(histogram[[nm]], snakeCase = FALSE)
  }
  return(newHistogram)
}

addConceptName <- function(table, prefix) {
  name <- omopgenerics::tableName(table)
  cdm <- omopgenerics::cdmReference(table)
  table |>
    dplyr::left_join(
      cdm$concept |>
        dplyr::select(dplyr::all_of(c("concept_id", "concept_name"))) |>
        dplyr::rename_with(~paste0(prefix, "_", .x)),
      by = paste0(prefix, "_concept_id")
    ) |>
    dplyr::compute(name = name, temporary = FALSE)
}

histogramBandExpr <- function(x, name, newName) {
  caseWhen <- glue::glue("is.na(.data${name}) ~ NA")
  for (jj in names(x)) {
    if (is.infinite(x[[jj]][2])) {
      caseWhen[jj] <- glue::glue(".data${name} >= {x[[jj]][1]} ~ '{jj}'")
    } else {
      caseWhen[jj] <- glue::glue(".data${name} >= {x[[jj]][1]} & .data${name} <= {x[[jj]][2]} ~ '{jj}'")
    }
  }
  glue::glue("dplyr::case_when({paste0(caseWhen, collapse = ', ')}, .default = 'None')") |>
    rlang::parse_exprs() |>
    rlang::set_names(newName)
}

addSubjectsWithMeasurement <- function(x, cdm, cohortName, baseGroup, strata, prefix, bySex, byYear, ageGroup) {

  # Subjects with measurement COUNTS
  measurementSummary <- omopgenerics::bind(x) |>
    dplyr::filter(!(.data$variable_name %in% c("days_between_measurements", "measurements_per_subject") & .data$estimate_name == "count")) |>
    dplyr::filter(.data$variable_name != "number records") |>
    dplyr::mutate(
      variable_name = gsub("_band", "", .data$variable_name),
      variable_name = dplyr::if_else(
        .data$variable_name == "number subjects", "number_subjects", .data$variable_name
      ),
      estimate_name = dplyr::if_else(
        .data$variable_name == "number_subjects", "count", .data$estimate_name
      )
    )
  subjectsMeasurementCounts <-  measurementSummary |>
    dplyr::filter(.data$variable_name == "number_subjects")

  # # Get overall cohort/database counts by strata
  # strataCols <- unlist(strata)
  # if (is.null(strataCols)) strataCols <- character()
  # tmpName <- omopgenerics::uniqueTableName(prefix = prefix)
  if (!is.null(cohortName)) {
    # Cohort counts
    cohortCounts <- cdm[[cohortName]] |>
      CohortCharacteristics::summariseCohortCount()

    # Subjects with measurement PERCENTAGE + overall counts
    subjectsMeasurementPercentage <- measurementSummary |>
      dplyr::filter(.data$variable_name == "number_subjects") |>
      omopgenerics::splitGroup() |>
      omopgenerics::pivotEstimates() |>
      dplyr::inner_join(
        cohortCounts |>
          dplyr::filter(.data$variable_name == "Number subjects") |>
          omopgenerics::tidy() |>
          dplyr::select(dplyr::any_of(c("cohort_name"[!is.null(cohortName)], "cohort_count" = "count"))),
        by = c("cohort_name"[!is.null(cohortName)])
      ) |>
      dplyr::mutate(
        result_id = 1L,
        estimate_name = "percentage",
        estimate_type = "numeric",
        estimate_value = as.character(.data$count/.data$cohort_count * 100)
      ) |>
      omopgenerics::uniteGroup(cols = baseGroup) |>
      dplyr::select(!dplyr::all_of(c("count", "cohort_count")))

    cohortCounts <- subjectsMeasurementPercentage |>
      dplyr::filter(.data$strata_name == "overall") |>
      omopgenerics::splitGroup() |>
      dplyr::select(!c(dplyr::starts_with("estimate"), dplyr::starts_with("variable"))) |>
      dplyr::inner_join(
        cohortCounts |>
          omopgenerics::splitAll() |>
          dplyr::mutate(variable_name = gsub("Number ", "cohort_", .data$variable_name)) |>
          dplyr::select(!c("cdm_name", "result_id")),
        by = "cohort_name"
      ) |>
      omopgenerics::uniteGroup(cols = baseGroup)
    set <- omopgenerics::settings(measurementSummary)
    measurementSummary <- cohortCounts |>
      dplyr::bind_rows(
        measurementSummary,
        subjectsMeasurementPercentage
      ) |>
      omopgenerics::newSummarisedResult(settings = set)

  } else {
    dbCounts <- cdm$person |> dplyr::tally() |> dplyr::pull()
    subjectsMeasurementPercentage <- subjectsMeasurementCounts |>
      dplyr::mutate(
        estimate_value = as.character(as.numeric(.data$estimate_value)/.env$dbCounts * 100),
        estimate_name = "percentage"
      )
    measurementSummary <- measurementSummary |>
      dplyr::bind_rows(subjectsMeasurementPercentage)
  }

  return(measurementSummary)
}
