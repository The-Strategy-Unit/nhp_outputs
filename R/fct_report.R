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
