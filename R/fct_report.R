# Impact of changes ----

prep_principal_change_factors <- function(
    data = params$r,
    sites = params$sites,
    mitigators = mitigator_lookup,
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
      mitigator_lookup,
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
    activity_type,
    pod,
    measure,
    agg_col
) {

  aggregated_data <- params$r |>
    get_aggregation(pod, measure, agg_col, NULL) |>
    shiny::req() |>
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
        tretspef_lookup,
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

  end_year <- params$r[["params"]][["end_year"]]
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
    activity_type,
    pod,
    measure
) {

  selected_measure <- c(activity_type, pod, measure)

  aggregated_data <- params$r |>
    mod_model_results_distribution_get_data(selected_measure, params$sites) |>
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
