# Model run information ----

tabulate_model_run_info <- function(p) {

  p_model_run <- purrr::keep(p, rlang::is_atomic)

  p_model_run[["start_year"]] <- scales::number(
    p_model_run[["start_year"]] + ((p_model_run[["start_year"]] + 1) %% 100) / 100,
    0.01,
    big.mark = "", decimal.mark = "/"
  )

  p_model_run[["end_year"]] <- scales::number(
    p_model_run[["end_year"]] + ((p_model_run[["end_year"]] + 1) %% 100) / 100,
    0.01,
    big.mark = "",
    decimal.mark = "/"
  )

  p_model_run[["create_datetime"]] <- p_model_run[["create_datetime"]] |>
    lubridate::fast_strptime("%Y%m%d_%H%M%S") |>
    format("%d-%b-%Y %H:%M:%S")

  p_model_run |>
    unlist() |>
    tibble::enframe() |>
    gt::gt("name") |>
    gt_theme() |>
    gt::tab_options(table.align = "left")

}

# Impact of changes ----

prep_principal_change_factors <- function(
    data,
    sites,
    mitigators,
    at,
    pods
) {

  principal_change_factors_raw <- data |>
    get_principal_change_factors(at, sites)

  # if a site is selected then there are no rows for A&E
  if (nrow(principal_change_factors_raw) == 0) stop("No data")

  principal_change_factors_raw |>
    dplyr::mutate(
      dplyr::across("change_factor", forcats::fct_inorder),
      dplyr::across(
        "change_factor",
        \(.x) {
          forcats::fct_relevel(
            .x,
            "baseline",
            "demographic_adjustment",
            "health_status_adjustment"
          )
        }
      )
    ) |>
    dplyr::left_join(
      mitigators,
      by = dplyr::join_by("strategy")
    ) |>
    tidyr::replace_na(list("mitigator_name" = "-")) |>
    dplyr::filter(.data[["pod"]] %in% pods) |>
    dplyr::select(-"pod") |>
    dplyr::count(
      dplyr::across(-"value"),
      wt = .data[["value"]],
      name = "value"
    )

}

prep_individual_change_factors <- function(
    principal_change_factors,
    measure
) {

  principal_change_factors |>
    dplyr::filter(
      .data$measure == .env$measure,
      .data$strategy != "-",
      .data$value < 0
    ) |>
    dplyr::mutate(
      dplyr::across(
        "mitigator_name",
        \(.x) forcats::fct_reorder(.x, -.data$value)
      )
    )

}

plot_individual_change_factors <- function(
    principal_change_factors,
    measure,
    change_factor
) {

  individual_change_factors <-
    prep_individual_change_factors(principal_change_factors, measure) |>
    dplyr::filter(change_factor == .env$change_factor)

  mod_principal_change_factor_effects_ind_plot(
    individual_change_factors,
    change_factor,
    "#f9bf07",
    snakecase::to_title_case(change_factor),
    snakecase::to_title_case(measure)
  )

}

plot_impact_and_individual_change <- function(
    principal_change_factors,
    measure
) {

  possibly_mod_principal_change_factor_effects_cf_plot <-
    purrr::possibly(
      mod_principal_change_factor_effects_cf_plot,
      "Insufficient information to produce this chart"
    )

  possibly_plot_individual_change_factors <-
    purrr::possibly(
      plot_individual_change_factors,
      "Insufficient information to produce this chart"
    )

  waterfall_plot <- principal_change_factors |>
    mod_principal_change_factor_effects_summarised(measure, TRUE) |>
    possibly_mod_principal_change_factor_effects_cf_plot()

  activity_avoidance_plot <- principal_change_factors |>
    possibly_plot_individual_change_factors(measure, "activity_avoidance")

  efficiencies_plot <- principal_change_factors |>
    possibly_plot_individual_change_factors(measure, "efficiencies")

  dplyr::lst(waterfall_plot, activity_avoidance_plot, efficiencies_plot)

}

# Activity in detail ----

generate_activity_in_detail_table <- function(
    data,
    sites,
    tretspefs,
    activity_type,
    pod,
    measure,
    agg_col
) {

  aggregated_data <- data |>
    get_aggregation(pod, measure, agg_col, sites)

  # if a site is selected then there are no rows for A&E
  if (nrow(aggregated_data) == 0) stop("No data")

  aggregated_data <- aggregated_data |>
    dplyr::transmute(
      .data$sex,
      agg = .data[[agg_col]],
      .data$baseline,
      final = .data$principal,
      change = .data$final - .data$baseline,
      change_pcnt = .data$change / .data$baseline
    )

  if (agg_col == "tretspef") {
    aggregated_data <- aggregated_data |>
      dplyr::left_join(
        tretspefs,
        by = dplyr::join_by("agg" == "Code")
      ) |>
      dplyr::mutate(
        dplyr::across(
          "Description",
          \(x) dplyr::if_else(is.na(x), .data$agg, .data$Description)
        ),
      ) |>
      dplyr::select("sex", "Description", dplyr::everything(), -"agg") |>
      dplyr::rename("agg" = "Description")
  }

  end_year <- data[["params"]][["end_year"]]
  end_fyear <- paste0(
    end_year, "/",
    as.numeric(stringr::str_extract(end_year, "\\d{2}$")) + 1
  )

  aggregated_data |>
    mod_principal_detailed_table(
      aggregation = agg_col,
      final_year = end_fyear
    ) |>
    gt::tab_options(table.align = "left")

}

# Activity distribution----

plot_activity_distributions <- function(
    data,
    sites,
    activity_type,
    pod,
    measure
) {

  selected_measure <- c(activity_type, pod, measure)

  aggregated_data <- data |>
    mod_model_results_distribution_get_data(selected_measure, sites) |>
    require_rows()

  beeswarm_plot <- mod_model_results_distribution_beeswarm_plot(
    aggregated_data,
    show_origin = FALSE
  )

  ecdf_plot <- mod_model_results_distribution_ecdf_plot(
    aggregated_data,
    show_origin = FALSE
  )

  dplyr::lst(beeswarm_plot, ecdf_plot)

}

# Params ----

#' Convert a List of Parameter Data to a List of 'gt' Objects
#' @param p A list. Parameter selections for a given model scenario, likely
#'     read in with [get_params].
#' @noRd
param_tables_to_list <- function(p) {

  t_profiles <- p$time_profile_mappings

  # Use functions developed for the app. For ther report, we need to catch
  # shiny::need() errors as NULLs.

  possibly_table_baseline_adjustment <- purrr::possibly(
    info_params_table_baseline_adjustment
  )
  possibly_table_covid_adjustment <- purrr::possibly(
    info_params_table_covid_adjustment
  )

  possibly_table_waiting_list_adjustment <- purrr::possibly(
    info_params_table_waiting_list_adjustment
  )
  possibly_table_expat_repat_adjustment <- purrr::possibly(
    info_params_table_expat_repat_adjustment
  )

  possibly_table_non_demographic_adjustment <- purrr::possibly(
    info_params_table_non_demographic_adjustment
  )
  possibly_table_demographic_adjustment <- purrr::possibly(
    info_params_table_demographic_adjustment
  )

  possibly_table_activity_avoidance <- purrr::possibly(
    info_params_table_activity_avoidance
  )
  possibly_table_efficiencies <- purrr::possibly(
    info_params_table_efficiencies
  )

  possibly_table_bed_occupancy_day_night <-purrr::possibly(
    info_params_table_bed_occupancy_day_night
  )
  possibly_table_bed_occupancy_specialty_mapping <-purrr::possibly(
    info_params_table_bed_occupancy_specialty_mapping
  )

  params_list <- list(

    "Baseline adjustment" = possibly_table_baseline_adjustment(p),
    "Covid adjustment" = possibly_table_covid_adjustment(p),

    "Waiting list adjustment" = list(
      "Time profile" = t_profiles$waiting_list_adjustment,
      "Table" = possibly_table_waiting_list_adjustment(p)
    ),
    "Expatriation" = list(
      "Time profile" = t_profiles$expat,
      "Table" = possibly_table_expat_repat_adjustment(p, "expat")
    ),
    "Repatriation (local)" = list(
      "Time profile" = t_profiles$repat_local,
      "Table" = possibly_table_expat_repat_adjustment(p, "repat_local")
    ),
    "Repatriation (non-local)" = list(
      "Time profile" = t_profiles$repat_nonlocal,
      "Table" = possibly_table_expat_repat_adjustment(p, "repat_nonlocal")
    ),

    "Non-demographic adjustment" = possibly_table_non_demographic_adjustment(p),
    "Demographic adjustment" = possibly_table_demographic_adjustment(p),

    "Activity avoidance" = possibly_table_activity_avoidance(p),
    "Efficiencies" = possibly_table_efficiencies(p),

    "Bed occupancy (day/night)" = possibly_table_bed_occupancy_day_night(p),
    "Bed occupancy (specialty mapping)" = possibly_table_bed_occupancy_specialty_mapping(p)

  ) |>
    purrr::compact()

  invisible(params_list)

}

#' Expand a List of Parameter Data to R Markdown
#' @param param_tables_list A list. The outcome of passing a model parameter
#'     object `p` to [param_tables_to_list]. Each element is a parameter group
#'     ('baseline adjustment', etc) and contains a 'gt' table object
#'     describing the parameter selections, or a further list with elements for
#'     a 'gt' object and a character value (the time profile mapping).
#' @noRd
expand_param_tables_to_rmd <- function(param_tables_list) {

  l1_names <- names(param_tables_list)

  for (l1 in l1_names) {

    cat("##", l1, "\n\n")

    l1_object <- param_tables_list[[l1]]
    l1_is_gt <- inherits(l1_object, "gt_tbl")
    l1_is_list <- is.list(l1_object)

    if (l1_is_gt) {
      l1_object |>
        gt::tab_options(table.align = "left") |>
        htmltools::tagList() |>
        print()
    }

    if (!l1_is_gt & l1_is_list) {

      l2_names <- names(l1_object)

      for (l2 in l2_names) {

        l2_object <- l1_object[[l2]]
        l2_is_char <- is.character(l2_object)
        l2_is_gt <- inherits(l2_object, "gt_tbl")

        if (l2_is_char) cat("Time profile mapping:", l2_object, "\n\n")

        if (l2_is_gt) {
          l2_object |>
            gt::tab_options(table.align = "left") |>
            htmltools::tagList() |>
            print()
        }
      }
    }
  }

}

#' Expand a List of Parameter-Selection Rationale to R Markdown
#' @param reasons_list A list. The 'reasons' element of a list `p` (i.e.
#'     the parameter selections for a given model scenario). Each element is a
#'     string describing the reason for a given parameter selection.
#' @noRd
expand_reasons_to_rmd <- function(reasons_list) {

  reasons_list <- reasons_list |>
    remove_blanks_recursively() |>
    rename_list_recursively()

  l1_names <- names(reasons_list)

  for (l1 in l1_names) {

    cat("##", l1, "\n\n")

    l1_object <- reasons_list[[l1]]
    l1_is_list <- is.list(l1_object)

    if (!l1_is_list) cat(l1_object, "\n\n")

    if (l1_is_list) {

      l2_names <- names(l1_object)

      for (l2 in l2_names) {

        cat("###", l2, "\n\n")

        l2_object <- l1_object[[l2]]
        l2_is_list <- is.list(l2_object)

        if (!l2_is_list) cat(l2_object, "\n\n")

        if (l2_is_list) {

          l3_names <- names(l2_object)

          for (l3 in l3_names) {

            cat("####", l3, "\n\n")

            l3_object <- l2_object[[l3]]
            l3_is_list <- is.list(l3_object)

            if (!l3_is_list) cat(l3_object, "\n\n")

            if (l3_is_list) warning("Unexpected depth in reasons list object.")

          }
        }
      }
    }
  }
}

#' Rename Elements of a Nested List Regardless of Depth
#' @param reasons_list A list. The 'reasons' element of a list `p` (i.e.
#'     the parameter selections for a given model scenario). Each element is a
#'     string describing the reason for a given parameter selection.
#' @param lookup_json_path Character. Path to a JSON file that maps mitigator
#'     codes to human-readable mitigator names. Defaults to the file hosted in
#'     this package.
#' @noRd
rename_list_recursively <- function(
    reasons_list,
    lookup_json_path = app_sys("app", "data", "mitigators.json")
) {

  lookup <- c(
    jsonlite::read_json(lookup_json_path) |> unlist(),
    "baseline_adjustment" = "Baseline adjustment",
    "demographic_factors" = "Demographic factors",
    "waiting_list_adjustment" = "Waiting list adjustment",
    "expat_repat" = "Expatriation and repatriation",
    "non-demographic_adjustment" = "Non-demographic adjustment",
    "activity_avoidance" = "Activity avoidance",
    "efficiencies" = "Efficiencies",
    "bed_occupancy" = "Bed occupancy",
    "ip" = "Inpatient",
    "op" = "Outpatient",
    "aae" = "Accident & Emergency"
  )

  name_exists <- names(reasons_list) %in% names(lookup)

  names(reasons_list)[name_exists] <- lookup[names(reasons_list)[name_exists]]

  purrr::map(
    reasons_list,
    \(x) {
      if (is.list(x)) {
        rename_list_recursively(x)
      } else {
        x
      }
    }
  )

}

#' Remove Empty Strings from a Nested List
#' @param reasons_list A list. The 'reasons' element of a list `p` (i.e.
#'     the parameter selections for a given model scenario). Each element is a
#'     string describing the reason for a given parameter selection.
#' @noRd
remove_blanks_recursively <- function(reasons_list) {

  if (!is.list(reasons_list)) return(reasons_list)

  reasons_list |>
    purrr::discard(\(x) isTRUE(nchar(x) == 0)) |>  # i.e. remove blanks like ""
    purrr::map(remove_blanks_recursively)

}
