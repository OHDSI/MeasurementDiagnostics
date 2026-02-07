hasRecords <- function(tbl){
  tbl |>
    utils::head(1) |>
    dplyr::tally() |>
    dplyr::pull("n") > 0
}

validateWindowArgumentMD <- function(window,
                                   snakeCase = TRUE,
                                   call = parent.frame()) {
  omopgenerics::assertLogical(snakeCase, length = 1, call = call)

  if (!is.list(window)) {
    window <- list(window)
  }

  # Find if any NA, throw warning that it will be changed to Inf, change it later
  if (any(unlist(lapply(window, is.na)))) {
    cli::cli_abort("NA found in window, please use Inf or -Inf instead", call = call)
  }

  omopgenerics::assertList(window, call = call)
  elements <- window |>
    unlist() |>
    purrr::keep(\(x) !is.infinite(x)) |>
    unique()
  omopgenerics::assertNumeric(elements, integerish = FALSE, call = call, msg = "Elements of window must be integerish.")

  # if any element of window list has length over 2, throw error
  if (any(lengths(window) > 2)) {
    "window can only contain two values: windowStart and windowEnd" |>
      cli::cli_abort(call = call)
  }

  # eg if list(1,2,3), change to list(c(1,1), c(2,2), c(3,3))
  if (length(window) > 1 && any(lengths(window) == 1)) {
    window[lengths(window) == 1] <- lapply(
      window[lengths(window) == 1],
      function(x) {
        c(
          unlist(x[lengths(x) == 1]),
          unlist(x[lengths(x) == 1])
        )
      }
    )
    cli::cli_warn(
      "Window list contains element with only 1 value provided,
          use it as both window start and window end"
    )
  }

  assertWindowName(window, snakeCase, call = call)
}

getWindowNames <- function(window, snakeCase) {
  # snakecase
  getname <- function(element) {
    element <- tolower(as.character(element))
    element <- stringr::str_replace_all(
      string = element,
      pattern = "-",
      replacement = "m"
    )
    paste0(element[1], "_to_", element[2])
  }
  # snakecase False
  getname2 <- function(element) {
    element <- tolower(as.character(element))
    paste0(element[1], " to ", element[2])
  }

  windowNames <- names(window)

  if (isTRUE(snakeCase)) {
    if (is.null(windowNames)) {
      windowNames <- purrr::map_chr(window, getname)
    } else {
      id <- windowNames == ""
      windowNames[id] <- purrr::map_chr(window[id], getname)
      newNames <- toSnakeCase(windowNames)
      differentNames <- which(windowNames != newNames)
      if (length(differentNames) > 0) {
        newName <- newNames[differentNames]
        oldName <- windowNames[differentNames]
        changes <- paste0("`", oldName, "` -> `", newName, "`") |>
          rlang::set_names(rep("*", length(newName)))
        cli::cli_inform(c("window names casted to snake_case: ", changes))
      }
      windowNames <- newNames
    }
  } else {
    if (is.null(windowNames)) {
      windowNames <- purrr::map_chr(window, getname2)
    } else {
      id <- windowNames == ""
      windowNames[id] <- purrr::map_chr(window[id], getname2)
    }
  }
  windowNames
}

assertWindowName <- function(window, snakeCase, call = parent.frame()) {
  names(window) <- getWindowNames(window, snakeCase = snakeCase)
  lower <- purrr::map_dbl(window, \(x) x[1])
  upper <- purrr::map_dbl(window, \(x) x[2])

  if (any(lower > upper)) {
    "First element in window must be smaller or equal to the second one" |>
      cli::cli_abort(call = call)
  }
  if (any(is.infinite(lower) & lower == upper & sign(upper) == 1)) {
    cli::cli_abort("Not both elements in the window can be +Inf", call = call)
  }
  if (any(is.infinite(lower) &
          lower == upper & sign(upper) == -1)) {
    cli::cli_abort("Not both elements in the window can be -Inf", call = call)
  }

  window
}
