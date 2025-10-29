#' Fix parameter table data with readable names
#'
#' @description Enriches parameter data frames by replacing codes with
#'   human-readable names for activity types, specialties, and strategies.
#'
#' @param df Data frame. Parameter data that may contain activity_type,
#'   specialty, and/or strategy columns.
#'
#' @return Data frame. Input data with codes replaced by descriptive names.
#'
#' @noRd
info_params_fix_data <- function(df) {
  at <- get_activity_type_pod_measure_options() |>
    dplyr::distinct(
      dplyr::across(
        tidyselect::starts_with("activity_type")
      )
    )

  specs <- app_sys("app", "data", "tx-lookup.json") |>
    jsonlite::read_json(simplifyVector = TRUE) |>
    dplyr::select(
      "specialty" = "Code",
      "specialty_name" = "Description"
    )

  strategies <- app_sys("app", "data", "mitigators.json") |>
    jsonlite::read_json(simplifyVector = TRUE) |>
    unlist() |>
    tibble::enframe("strategy", "mitigator_name")

  fix_activity_type <- function(df) {
    if (!"activity_type" %in% colnames(df)) {
      return(df)
    }

    df |>
      dplyr::inner_join(at, by = dplyr::join_by("activity_type")) |>
      dplyr::select(-"activity_type")
  }

  fix_specialty <- function(df) {
    if (!"specialty" %in% colnames(df)) {
      return(df)
    }

    df |>
      dplyr::left_join(specs, by = dplyr::join_by("specialty")) |>
      dplyr::mutate(
        dplyr::across(
          "specialty_name",
          \(.x) ifelse(is.na(.x), .data[["specialty"]], .x)
        )
      ) |>
      dplyr::select(-"specialty")
  }

  fix_strategy <- function(df) {
    if (!"strategy" %in% colnames(df)) {
      return(df)
    }

    df |>
      dplyr::left_join(strategies, by = dplyr::join_by("strategy")) |>
      dplyr::select(-"strategy")
  }

  df |>
    fix_activity_type() |>
    fix_specialty() |>
    fix_strategy()
}

#' Create demographic adjustment parameters table
#'
#' @description Generates a formatted gt table showing demographic variant
#'   probabilities.
#'
#' @param p List. Model parameters containing demographic_factors element.
#'
#' @return gt table object displaying variant probabilities as percentages.
#'
#' @noRd
info_params_table_demographic_adjustment <- function(p) {
  demographic_adjustment <- p[["demographic_factors"]]

  shiny::validate(
    shiny::need(demographic_adjustment, "No parameters provided")
  )

  demographic_adjustment |>
    purrr::pluck("variant_probabilities") |>
    unlist() |>
    tibble::enframe("variant", "value") |>
    gt::gt("variant") |>
    gt::fmt_percent("value") |>
    gt_theme()
}

#' Create baseline adjustment parameters table
#'
#' @description Generates a formatted gt table showing baseline adjustment
#'   parameters by activity type, POD, and specialty. Handles special case
#'   for A&E data which lacks specialty breakdown.
#'
#' @param p List. Model parameters containing baseline_adjustment element.
#'
#' @return gt table object displaying baseline adjustments grouped by
#'   activity type and POD.
#'
#' @noRd
info_params_table_baseline_adjustment <- function(p) {
  baseline_adjustment <- local({
    x <- p[["baseline_adjustment"]]
    if (!is.null(x[["aae"]])) {
      x[["aae"]] <- purrr::map(x[["aae"]], \(.x) list(Other = .x))
    }
    return(x)
  })

  shiny::validate(
    shiny::need(baseline_adjustment, "No parameters provided")
  )

  baseline_adjustment |>
    purrr::map_depth(2, tibble::enframe, "specialty") |>
    purrr::map(dplyr::bind_rows, .id = "pod") |>
    dplyr::bind_rows(.id = "activity_type") |>
    info_params_fix_data() |>
    dplyr::relocate("value", .after = tidyselect::everything()) |>
    tidyr::unnest("value") |>
    gt::gt("specialty_name", c("activity_type_name", "pod")) |>
    gt_theme()
}

#' Create waiting list adjustment parameters table
#'
#' @description Generates a formatted gt table showing waiting list adjustment
#'   parameters by specialty and activity type.
#'
#' @param p List. Model parameters containing waiting_list_adjustment element.
#'
#' @return gt table object displaying waiting list adjustments with activity
#'   types as columns.
#'
#' @noRd
info_params_table_waiting_list_adjustment <- function(p) {
  waiting_list_adjustment <- p[["waiting_list_adjustment"]]

  shiny::validate(
    shiny::need(waiting_list_adjustment, "No parameters provided")
  )

  waiting_list_adjustment |>
    purrr::map(tibble::enframe, "specialty", "value") |>
    dplyr::bind_rows(.id = "activity_type") |>
    tidyr::unnest("value") |>
    info_params_fix_data() |>
    tidyr::pivot_wider(names_from = "activity_type_name") |>
    gt::gt("specialty_name") |>
    gt::sub_missing(missing_text = "") |>
    gt_theme()
}

#' Create expatriation/repatriation adjustment parameters table
#'
#' @description Generates a formatted gt table showing expatriation or
#'   repatriation adjustment parameters by activity type, POD, and specialty.
#'   Handles special cases for outpatient and A&E data structures.
#'
#' @param p List. Model parameters containing the specified type element.
#' @param type Character. The parameter type to display (e.g., "expatriation",
#'   "repatriation").
#'
#' @return gt table object displaying adjustment interval parameters grouped
#'   by activity type and POD.
#'
#' @noRd
info_params_table_expat_repat_adjustment <- function(p, type) {
  df <- local({
    x <- p[[type]]
    if (!is.null(x[["op"]])) {
      x[["op"]] <- list("-" = x[["op"]])
    }
    if (!is.null(x[["aae"]])) {
      x[["aae"]] <- purrr::map(x[["aae"]], \(.x) list(Other = .x))
    }
    return(x)
  })

  shiny::validate(
    shiny::need(df, "No parameters provided")
  )

  df |>
    purrr::map_depth(2, tibble::enframe, "specialty") |>
    purrr::map(dplyr::bind_rows, .id = "pod") |>
    dplyr::bind_rows(.id = "activity_type") |>
    tidyr::unnest_wider("value") |>
    info_params_fix_data() |>
    dplyr::relocate("lo", "hi", .after = tidyselect::everything()) |>
    gt::gt("specialty_name", c("activity_type_name", "pod")) |>
    gt_theme()
}

#' Create non-demographic adjustment parameters table
#'
#' @description Generates a formatted gt table showing non-demographic
#'   adjustment parameters by activity type and POD.
#'
#' @param p List. Model parameters containing non-demographic_adjustment element.
#'
#' @return gt table object displaying non-demographic adjustment intervals
#'   grouped by activity type.
#'
#' @noRd
info_params_table_non_demographic_adjustment <- function(p) {
  non_demographic_adjustment <- p[["non-demographic_adjustment"]][["values"]]

  shiny::validate(
    shiny::need(non_demographic_adjustment, "No parameters provided")
  )

  non_demographic_adjustment |>
    purrr::map(tibble::enframe, "pod") |>
    dplyr::bind_rows(.id = "activity_type") |>
    info_params_fix_data() |>
    tidyr::unnest_wider("value") |>
    gt::gt("pod", "activity_type_name") |>
    gt_theme()
}

#' Create activity avoidance parameters table
#'
#' @description Generates a formatted gt table showing activity avoidance
#'   parameters by activity type and mitigator strategy, including interval
#'   values and time profile mappings.
#'
#' @param p List. Model parameters containing activity_avoidance and
#'   time_profile_mappings elements.
#'
#' @return gt table object displaying activity avoidance parameters grouped
#'   by activity type with mitigator rows.
#'
#' @noRd
info_params_table_activity_avoidance <- function(p) {
  actitvity_avoidance <- p[["activity_avoidance"]]

  shiny::validate(
    shiny::need(actitvity_avoidance, "No parameters provided")
  )

  time_profiles <- p[["time_profile_mappings"]][["activity_avoidance"]] |>
    purrr::map(unlist) |>
    purrr::map(tibble::enframe, "strategy", "time_profile") |>
    dplyr::bind_rows(.id = "activity_type")

  actitvity_avoidance |>
    purrr::map_depth(2, "interval") |>
    purrr::map(tibble::enframe, "strategy") |>
    dplyr::bind_rows(.id = "activity_type") |>
    tidyr::unnest_wider("value") |>
    dplyr::left_join(
      time_profiles,
      by = dplyr::join_by("activity_type", "strategy")
    ) |>
    info_params_fix_data() |>
    dplyr::arrange("activity_type_name", "mitigator_name") |>
    gt::gt("mitigator_name", "activity_type_name") |>
    gt_theme()
}

#' Create efficiencies parameters table
#'
#' @description Generates a formatted gt table showing efficiency
#'   parameters by activity type and mitigator strategy, including interval
#'   values and time profile mappings.
#'
#' @param p List. Model parameters containing efficiencies and
#'   time_profile_mappings elements.
#'
#' @return gt table object displaying efficiency parameters grouped by
#'   activity type with mitigator rows.
#'
#' @noRd
info_params_table_efficiencies <- function(p) {
  efficiencies <- p[["efficiencies"]]

  shiny::validate(
    shiny::need(efficiencies, "No parameters provided")
  )

  time_profiles <- p[["time_profile_mappings"]][["efficiencies"]] |>
    purrr::map(unlist) |>
    purrr::map(tibble::enframe, "strategy", "time_profile") |>
    dplyr::bind_rows(.id = "activity_type")

  efficiencies |>
    purrr::map_depth(2, "interval") |>
    purrr::map(tibble::enframe, "strategy") |>
    dplyr::bind_rows(.id = "activity_type") |>
    tidyr::unnest_wider("value") |>
    dplyr::left_join(
      time_profiles,
      by = dplyr::join_by("activity_type", "strategy")
    ) |>
    info_params_fix_data() |>
    dplyr::arrange("activity_type_name", "mitigator_name") |>
    gt::gt("mitigator_name", "activity_type_name") |>
    gt_theme()
}
