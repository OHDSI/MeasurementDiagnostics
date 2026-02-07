# Helper for consistent documentation of \`summariseMeasurement\` functions.

Helper for consistent documentation of \`summariseMeasurement\`
functions.

## Arguments

- cdm:

  A reference to the cdm object.

- codes:

  A codelist of measurement/observation codes for which to perform
  diagnostics.

- cohort:

  A cohort in which to perform the diagnostics of the measurement codes
  provided.

- timing:

  Three options: 1) "any" if the interest is on measurement recorded any
  time, 2) "during", if interested in measurements while the subject is
  in the cohort, and 3) "cohort_start_date" for measurements occurring
  at cohort start date.

- byConcept:

  TRUE or FALSE. If TRUE code use will be summarised by concept.

- byYear:

  TRUE or FALSE. If TRUE code use will be summarised by year.

- bySex:

  TRUE or FALSE. If TRUE code use will be summarised by sex.

- ageGroup:

  If not NULL, a list of ageGroup vectors of length two.

- dateRange:

  Two dates. The first indicating the earliest measurement date and the
  second indicating the latest possible measurement date.

- personSample:

  Integerish or \`NULL\`. Number of persons to sample the measurement
  and observation tables. If \`NULL\`, no sampling is performed.

- estimates:

  A named list indicating, for each measurement diagnostics check, which
  estimates to retrieve. The names of the list should correspond to the
  diagnostics checks, and each list element should be a character vector
  specifying the estimates to compute.

  Allowed estimates are those supported by the \`summariseResult()\`
  function in the \*\*PatientProfiles\*\* package. If omitted, all
  available estimates for each check will be returned.

- histogram:

  Named list where names point to checks for which to get estimates for
  a histogram, and elements are numeric vectors indicating the
  bind-width. See function examples. Histogram only available for
  "measurement_summary" and "measurement_value_as_number".

- checks:

  Diagnostics to run. Options are: "measurement_summary",
  "measurement_value_as_number", and "measurement_value_as_concept".
