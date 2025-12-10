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
  in the cohort (or in observation if cohort = NULL), and 3)
  "cohort_start_date" for measurements occurring at cohort start date
  (or at "observation_period_start_date if cohort = NULL).

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

- checks:

  Diagnostics to run. Options are: "measurement_timing",
  "measurement_value_as_numeric", and "measurement_value_as_concept".
