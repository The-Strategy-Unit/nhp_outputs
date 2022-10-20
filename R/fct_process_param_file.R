#' process_param_file
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd
process_param_file <- function(path,
                               dataset = "synthetic",
                               demographics_file = "demographic_factors.csv",
                               scenario = "test") {
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
    dplyr::summarise(dplyr::across("ex", diff), .groups = "drop") |>
    dplyr::group_by(dplyr::across("age", pmin, 90), .data$sex) |>
    dplyr::summarise(dplyr::across("ex", mean), .groups = "drop") |>
    dplyr::group_nest(.data$sex) |>
    dplyr::mutate(dplyr::across("data", purrr::map, tibble::deframe)) |>
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
      dplyr::across("age_group", ~ ifelse(.x == "85+", .x, stringr::str_pad(.x, width = 5)))
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(interval = list(c(.data$lo, .data$hi))) |>
    dplyr::select(-"lo", -"hi") |>
    dplyr::group_nest(.data$admigrp) |>
    dplyr::mutate(dplyr::across("data", purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params <- list(
    scenario = scenario,
    dataset = dataset,
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

  params$inpatient_factors <- list(
    "admission_avoidance" = data$am_a_ip |>
      dplyr::filter(.data$include != 0) |>
      dplyr::rowwise() |>
      dplyr::transmute(.data$strategy, interval = list(c(.data$lo, .data$hi))) |>
      tibble::deframe() |>
      purrr::map(~ list(interval = .x))
  )

  params$inpatient_factors$los_reduction <- c(
    data$am_e_ip |>
      dplyr::filter(.data$include != 0) |>
      dplyr::mutate(type = dplyr::case_when(
        .data$strategy |> stringr::str_starts("ambulatory_emergency_care") ~ "aec",
        .data$strategy |> stringr::str_starts("pre-op") ~ "pre-op",
        TRUE ~ "all"
      )) |>
      dplyr::rowwise() |>
      dplyr::transmute(.data$strategy, value = list(list(type = .data$type, interval = c(.data$lo, .data$hi)))) |>
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
          interval = c(.data$lo, .data$hi),
          baseline_target_rate = .data$baseline_target_rate,
          op_dc_split = .data$op_dc_split
        )
      )) |>
      tibble::deframe()
  )

  params$outpatient_factors <- dplyr::bind_rows(data[c("am_a_op", "am_tc_op")]) |>
    dplyr::filter(.data$include != 0) |>
    dplyr::rowwise() |>
    dplyr::transmute(.data$strategy, value = list(list(interval = c(.data$lo, .data$hi)))) |>
    tidyr::separate(.data$strategy, c("strategy", "sub_group"), "\\|") |>
    dplyr::group_nest(.data$strategy) |>
    dplyr::mutate(dplyr::across("data", purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params$aae_factors <- data$am_a_aae |>
    dplyr::filter(.data$include != 0) |>
    dplyr::rowwise() |>
    dplyr::transmute(.data$strategy, value = list(list(interval = c(.data$lo, .data$hi)))) |>
    tidyr::separate(.data$strategy, c("strategy", "sub_group"), "\\|") |>
    dplyr::group_nest(.data$strategy) |>
    dplyr::mutate(dplyr::across("data", purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params$bed_occupancy <- data$ru_bo |>
    dplyr::rowwise() |>
    dplyr::mutate(
      dplyr::across(tidyselect::starts_with("dn"), `*`, .data$ha_f / .data$ha_b),
      type = "day+night",
      interval = list(c(.data$dn_lo, .data$dn_hi))
    ) |>
    dplyr::select("ward_group", "type", "interval") |>
    dplyr::group_nest(.data$type) |>
    dplyr::mutate(dplyr::across("data", purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params$bed_occupancy$specialty_mapping <- data$ru_bo_sm |>
    dplyr::select("specialty_group", "specialty_code", .data$ward_group) |>
    dplyr::group_nest(.data$specialty_group) |>
    dplyr::mutate(dplyr::across("data", purrr::map, purrr::compose(as.list, tibble::deframe))) |>
    tibble::deframe()

  params$theatres <- list(
    change_availability = unname(unlist(data$ru_th_a)),
    change_utilisation = data$ru_th_u |>
      dplyr::rowwise() |>
      dplyr::transmute(.data$tretspef, interval = list(c(.data$lo, .data$hi))) |>
      tibble::deframe()
  )

  expat_repat <- purrr::map_dfr(
    .id = "type",
    list(
      ip = data$er_ip |>
        tidyr::pivot_longer(-c("admigroup", "tretspef")) |>
        dplyr::mutate(dplyr::across("name", stringr::str_remove, "\\_(lo|hi)$")) |>
        dplyr::group_by(.data$name, .data$admigroup, .data$tretspef) |>
        dplyr::summarise(dplyr::across("value", list), .groups = "drop_last") |>
        dplyr::group_nest() |>
        dplyr::mutate(dplyr::across("data", purrr::map, tibble::deframe)) |>
        dplyr::group_nest(.data$name),
      op = data$er_op |>
        tidyr::pivot_longer(-c("tretspef")) |>
        dplyr::mutate(dplyr::across("name", stringr::str_remove, "\\_(lo|hi)$")) |>
        dplyr::group_by(.data$name, .data$tretspef) |>
        dplyr::summarise(dplyr::across("value", list), .groups = "drop_last") |>
        dplyr::group_nest(),
      aae = data$er_aae |>
        tidyr::pivot_longer(-c("attendtype")) |>
        dplyr::mutate(dplyr::across("name", stringr::str_remove, "\\_(lo|hi)$")) |>
        dplyr::group_by(.data$name, .data$attendtype) |>
        dplyr::summarise(dplyr::across("value", list), .groups = "drop_last") |>
        dplyr::group_nest()
    ),
    dplyr::mutate,
    dplyr::across("data", purrr::map, tibble::deframe)
  ) |>
    dplyr::group_nest(.data$name) |>
    dplyr::mutate(dplyr::across("data", purrr::map, tibble::deframe)) |>
    tibble::deframe()

  params <- c(params, expat_repat)

  validate_params(params)

  params
}

validate_params <- function(params) {
  c(
    "model_runs must be a power of 2" = params$model_runs %in% 2^(0:10),
    "start_year must be 2018" = params$start_year == 2018,
    "end_year must be after start_year" = params$start_year < params$end_year,
    purrr::map(validation_functions, ~ .x(params)) |>
      purrr::flatten_lgl()
  )
}

validate_interval <- function(i, lo, hi) {
  length(i) == 2 && min(i) >= lo && max(i) <= hi && diff(i) >= 0
}

validation_functions <- list(
  demographic_factors = function(params) {
    vp <- params$demographic_factors$variant_probabilities
    c(
      "demographic variant probabilities must sum to 1" = sum(unlist(vp)) == 1,
      "demographic variant probabilites names must be valid" = all(
        names(vp) %in% c(
          "principal_proj",
          "var_proj_10_year_migration",
          "var_proj_alt_internal_migration",
          "var_proj_high_intl_migration",
          "var_proj_low_intl_migration"
        )
      )
    )
  },
  health_status_adjustment = function(params) {
    hsa <- params$health_status_adjustment

    c(
      "health status adjustment must have a valid interval" = validate_interval(hsa, 0, 5)
    )
  },
  life_expectancy = function(params) {
    le <- params$life_expectancy
    age_range <- le$max_age - le$min_age + 1
    c(
      "life expectancy max age must be greater than or equal to low value" = le$min_age <= le$max_age,
      "life expectancy female must have correct number of values" = length(le$f) == age_range,
      "life expectancy male must have correct number of values" = length(le$m) == age_range,
      "life expectancy female values must be between 0 and 5" = all(le$f >= 0 & le$f <= 5),
      "life expectancy male values must be between 0 and 5" = all(le$m >= 0 & le$m <= 5)
    )
  },
  waiting_list_adjustment = function(params) {
    wle <- params$waiting_list_adjustment
    c(
      "waiting list adjustment ip must be greater than 0" = all(unlist(wle$ip) >= 0),
      "waiting list adjustment op must be greater than 0" = all(unlist(wle$op) >= 0)
    )
  },
  "non-demographic_adjustment" = function(params) {
    nda <- params[["non-demographic_adjustment"]]

    purrr::imap(nda, \(.x1, .i1) {
      purrr::imap(.x1, \(.x2, .i2) {
        purrr::set_names(
          validate_interval(.x2, 0, 5),
          glue::glue("non-demographic_adjustment {.i1} {.i2} must be a valid interval")
        )
      })
    }) |>
      purrr::flatten() |>
      purrr::flatten_lgl()
  },
  inpatient_factors = function(params) {
    params$inpatient_factors |>
      purrr::imap(\(.x1, .i1) {
        purrr::imap(.x1, \(.x2, .i2) {
          purrr::set_names(
            validate_interval(.x2$interval, 0, 1),
            glue::glue("inpatient_factors {.i1} {.i2} must be a valid interval")
          )
        })
      }) |>
      purrr::flatten() |>
      purrr::flatten_lgl()
  },
  outpatient_factors = function(params) {
    params$outpatient_factors |>
      purrr::imap(\(.x1, .i1) {
        purrr::imap(.x1, \(.x2, .i2) {
          purrr::set_names(
            validate_interval(.x2$interval, 0, 1),
            glue::glue("outpatient_factors {.i1} {.i2} must be a valid interval")
          )
        })
      }) |>
      purrr::flatten() |>
      purrr::flatten_lgl()
  },
  aae_factors = function(params) {
    params$aae_factors |>
      purrr::imap(\(.x1, .i1) {
        purrr::imap(.x1, \(.x2, .i2) {
          purrr::set_names(
            validate_interval(.x2$interval, 0, 1),
            glue::glue("aae_factors {.i1} {.i2} must be a valid interval")
          )
        })
      }) |>
      purrr::flatten() |>
      purrr::flatten_lgl()
  },
  bed_occupancy = function(params) {
    params$bed_occupancy[["day+night"]] |>
      purrr::map_lgl(validate_interval, 0, 1) |>
      purrr::set_names(~ glue::glue("bed_occupancy day+night {.x} must be a valid interval"))
  },
  theatres = function(params) {
    c(
      params$theatres$change_utilisation |>
        purrr::map_lgl(validate_interval, 0, 5) |>
        purrr::set_names(~ glue::glue("theatres change_utilisation {.x} must be a valid interval")),
      "theatres change_availability must be a valid interval" =
        validate_interval(params$theatres$change_availability, 0, 5)
    )
  },
  expat = function(params) {
    ip <- params$expat$ip |>
      purrr::imap(\(.x1, .i1) {
        purrr::imap(.x1, \(.x2, .i2) {
          purrr::set_names(
            validate_interval(.x2, 0, 1),
            glue::glue("expat ip {.i1} {.i2} must be a valid interval")
          )
        })
      }) |>
      purrr::flatten() |>
      purrr::flatten_lgl()

    op <- params$expat$op |>
      purrr::map_lgl(validate_interval, 0, 1) |>
      purrr::set_names(\(.i) glue::glue("expat op {.i} must be a valid interval"))

    aae <- params$expat$aae |>
      purrr::map_lgl(validate_interval, 0, 1) |>
      purrr::set_names(\(.i) glue::glue("expat aae {.i} must be a valid interval"))

    c(ip, op, aae)
  },
  repat_local = function(params) {
    ip <- params$repat_local$ip |>
      purrr::imap(\(.x1, .i1) {
        purrr::imap(.x1, \(.x2, .i2) {
          purrr::set_names(
            validate_interval(.x2, 1, 5),
            glue::glue("repat local ip {.i1} {.i2} must be a valid interval")
          )
        })
      }) |>
      purrr::flatten() |>
      purrr::flatten_lgl()

    op <- params$repat_local$op |>
      purrr::map_lgl(validate_interval, 0, 1) |>
      purrr::set_names(\(.i) glue::glue("repat local op {.i} must be a valid interval"))

    aae <- params$repat_local$aae |>
      purrr::map_lgl(validate_interval, 0, 1) |>
      purrr::set_names(\(.i) glue::glue("repat local aae {.i} must be a valid interval"))

    c(ip, op, aae)
  },
  repat_nonlocal = function(params) {
    ip <- params$repat_nonlocal$ip |>
      purrr::imap(\(.x1, .i1) {
        purrr::imap(.x1, \(.x2, .i2) {
          purrr::set_names(
            validate_interval(.x2, 1, 5),
            glue::glue("repat non local ip {.i1} {.i2} must be a valid interval")
          )
        })
      }) |>
      purrr::flatten() |>
      purrr::flatten_lgl()

    op <- params$repat_nonlocal$op |>
      purrr::map_lgl(validate_interval, 0, 1) |>
      purrr::set_names(\(.i) glue::glue("repat non local op {.i} must be a valid interval"))

    aae <- params$repat_nonlocal$aae |>
      purrr::map_lgl(validate_interval, 0, 1) |>
      purrr::set_names(\(.i) glue::glue("repat non local aae {.i} must be a valid interval"))

    c(ip, op, aae)
  }
)
