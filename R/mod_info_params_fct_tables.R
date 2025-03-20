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

info_params_table_covid_adjustment <- function(p) {
  covid_adjustment <- p[["covid_adjustment"]]

  shiny::validate(
    shiny::need(covid_adjustment, "No parameters provided")
  )

  covid_adjustment |>
    purrr::map(tibble::enframe, "pod") |>
    dplyr::bind_rows(.id = "activity_type") |>
    tidyr::unnest_wider("value") |>
    info_params_fix_data() |>
    gt::gt("pod", "activity_type_name") |>
    gt_theme()
}

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
