#' process_param_file
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
process_param_file <- function(path,
                               input_data = "synthetic",
                               demographics_file = "demographic_factors.csv",
                               scenario_name = "test") {
  all_sheets <- readxl::excel_sheets(path)

  data <- all_sheets[-(1:which(all_sheets == "Control Sheets>>"))] |>
    purrr::set_names() |>
    purrr::map(readxl::read_excel, path = path)

  base_year <- lubridate::year(data$run_settings$baseline_year)
  model_year <- lubridate::year(data$run_settings$model_year)
  seed <- data$run_settings$seed
  if (is.null(seed) || seed == 0) {
    seed <- sample(1:1e5, 1)
  }

  life_expectancy <- readRDS(app_sys("life_expectancy.rds")) |>
    dplyr::filter(.data$base == "2018b", .data$year %in% c(base_year, model_year), .data$age >= 55) |>
    dplyr::arrange(.data$age, .data$sex, .data$year) |>
    dplyr::group_by(.data$age, .data$sex) |>
    dplyr::summarise(dplyr::across(.data$ex, diff), .groups = "drop") |>
    dplyr::group_by(dplyr::across(.data$age, pmin, 90), .data$sex) |>
    dplyr::summarise(dplyr::across(.data$ex, mean), .groups = "drop") |>
    dplyr::group_nest(.data$sex) |>
    dplyr::mutate(dplyr::across(.data$data, purrr::map, tibble::deframe)) |>
    tibble::deframe()
  life_expectancy$min_age <- 55
  life_expectancy$max_age <- 90

  wla_ip <- data$dsi_wl_ip |>
    tibble::deframe() |>
    as.list()

  wla_op <- data$dsi_wl_op |>
    tibble::deframe() |>
    as.list()

  nda <- data$nd_t1h |>
    dplyr::mutate(
      dplyr::across(.data$age_group, ~ ifelse(.x == "85+", .x, stringr::str_pad(.x, width = 5)))
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(interval = list(c(.data$lo, .data$hi))) |>
    dplyr::select(-.data$lo, -.data$hi) |>
    dplyr::group_nest(.data$admigrp) |>
    dplyr::mutate(dplyr::across(.data$data, purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params <- list(
    name = scenario_name,
    input_data = input_data,
    seed = seed,
    model_runs = data$run_settings$n_iterations,
    start_year = base_year,
    end_year = model_year,
    demographic_factors = list(
      file = demographics_file,
      start_year = base_year,
      end_year = model_year,
      variant_probabilities = data$pc_pg |>
        dplyr::filter(.data$probability > 0) |>
        tibble::deframe() |>
        as.list()
    ),
    health_status_adjustment = unlist(data$pc_hsa),
    life_expectancy = life_expectancy,
    waiting_list_adjustment = list(
      "ip" = wla_ip,
      "op" = wla_op
    ),
    "non-demographic_adjustment" = nda
  )

  params$strategy_params <- list(
    "admission_avoidance" = data$am_a_ip |>
      dplyr::filter(.data$include != 0) |>
      dplyr::rowwise() |>
      dplyr::transmute(.data$strategy, interval = list(c(.data$lo, .data$hi))) |>
      tibble::deframe() |>
      purrr::map(~ list(interval = .x))
  )

  params$strategy_params$los_reduction <- c(
    data$am_e_ip |>
      dplyr::filter(.data$include != 0) |>
      dplyr::mutate(type = dplyr::case_when(
        .data$strategy |> stringr::str_starts("ambulatory_emergency_care") ~ "aec",
        .data$strategy |> stringr::str_starts("pre-op") ~ "pre-op",
        TRUE ~ "all"
      )) |>
      dplyr::rowwise() |>
      dplyr::transmute(.data$strategy, value = list(list(type = .data$type, interval = list(.data$lo, .data$hi)))) |>
      tibble::deframe(),
    data$am_tc_ip |>
      dplyr::filter(.data$include != 0) |>
      dplyr::mutate(target_type = ifelse(
        .data$strategy |> stringr::str_detect("outpatients"),
        "outpatients",
        "daycase"
      )) |>
      dplyr::rowwise() |>
      dplyr::transmute(.data$strategy, value = list(
        list(
          type = "bads",
          target_type = .data$target_type,
          interval = list(.data$lo, .data$hi),
          baseline_target_rate = .data$baseline_target_rate,
          op_dc_split = .data$op_dc_split
        )
      )) |>
      tibble::deframe()
  )

  params$outpatient_factors <- dplyr::bind_rows(data[c("am_a_op", "am_tc_op")]) |>
    dplyr::filter(.data$include != 0) |>
    dplyr::rowwise() |>
    dplyr::transmute(.data$strategy, value = list(list(interval = list(.data$lo, .data$hi)))) |>
    tidyr::separate(.data$strategy, c("strategy", "sub_group"), "\\|") |>
    dplyr::group_nest(.data$strategy) |>
    dplyr::mutate(dplyr::across(.data$data, purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params$aae_factors <- data$am_a_aae |>
    dplyr::filter(.data$include != 0) |>
    dplyr::rowwise() |>
    dplyr::transmute(.data$strategy, value = list(list(interval = list(.data$lo, .data$hi)))) |>
    tidyr::separate(.data$strategy, c("strategy", "sub_group"), "\\|") |>
    dplyr::group_nest(.data$strategy) |>
    dplyr::mutate(dplyr::across(.data$data, purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params$bed_occupancy <- data$ru_bo |>
    tidyr::pivot_longer(-.data$ward_group) |>
    tidyr::separate(.data$name, c("type", "interval")) |>
    dplyr::mutate(
      dplyr::across(
        .data$type,
        ~ dplyr::case_when(
          .x == "dn" ~ "day+night",
          .x == "do" ~ "day only"
        )
      )
    ) |>
    dplyr::group_by(.data$ward_group, .data$type) |>
    dplyr::summarise(interval = list(.data$value), .groups = "drop") |>
    dplyr::group_nest(.data$type) |>
    dplyr::mutate(dplyr::across(.data$data, purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params$bed_occupancy$specialty_mapping <- data$ru_bo_sm |>
    dplyr::select(.data$specialty_group, .data$specialty_code, .data$ward_group) |>
    dplyr::group_nest(.data$specialty_group) |>
    dplyr::mutate(dplyr::across(.data$data, purrr::map, purrr::compose(as.list, tibble::deframe))) |>
    tibble::deframe()

  params$theatres <- list(
    change_availability = unname(unlist(data$ru_th_a)),
    change_utilisation = data$ru_th_u |>
      dplyr::rowwise() |>
      dplyr::transmute(.data$tretspef, interval = list(c(.data$lo, .data$hi))) |>
      tibble::deframe()
  )

  params
}
