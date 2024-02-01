tidy_params <- function(p) {

  c(
    tidy_params_years(p),
    tidy_params_demographic_factors(p),
    tidy_params_covid_adjustment(p),
    tidy_params_waiting_list_adjustment(p),
    tidy_params_efficiences(p),
    tidy_params_bed_occupancy(p),
    tidy_params_time_profile_mappings(p),
    tidy_params_multi(p)
  )

}

tidy_params_years <- function(p) {

  years <- tibble::tibble(
    "Model time point" = c("Start", "End"),
    Year = c(p[["start_year"]], p[["end_year"]])
  )

  dplyr::lst(years)

}

tidy_params_demographic_factors <- function(p) {

  demographic_factors <-
    p[["demographic_factors"]][["variant_probabilities"]] |>
    tibble::enframe() |>
    tidyr::unnest("value")

  dplyr::lst(demographic_factors)

}

tidy_params_covid_adjustment <- function(p) {

  covid_adjustment <- p[["covid_adjustment"]] |>
    purrr::map(tibble::enframe) |>
    purrr::map(\(x) tidyr::unnest_wider(x, "value", names_sep = "ci")) |>
    purrr::map(\(x) dplyr::rename(x, "lower" = "valueci1", "upper" = "valueci2"))

  dplyr::lst(covid_adjustment)

}

tidy_params_waiting_list_adjustment <- function(p) {

  waiting_list_adjustment <- p[["waiting_list_adjustment"]] |>
    purrr::map(tibble::enframe) |>
    purrr::map(\(x) tidyr::unnest_longer(x, "value"))

  dplyr::lst(waiting_list_adjustment)

}

tidy_params_efficiences <- function(p) {

  prep <- p[["efficiencies"]] |>
    purrr::map(tibble::enframe) |>
    purrr::map(\(x) tidyr::unnest_longer(x, "value"))

  ip_type <- prep[["ip"]] |>
    dplyr::filter(.data$value_id == "type") |>
    tidyr::unnest_longer("value")

  ip_interval <- prep[["ip"]] |>
    dplyr::filter(.data$value_id == "interval") |>
    tidyr::unnest_longer("value") |>
    dplyr::mutate(ci = rep(c("lower", "upper"), dplyr::n() / 2)) |>
    tidyr::pivot_wider(values_from = "value", names_from = "ci")

  ip <- dplyr::left_join(ip_type, ip_interval, by = "name")

  op <- prep[["op"]] |>
    tidyr::unnest_longer("value") |>
    dplyr::mutate(ci = rep(c("lower", "upper"), dplyr::n() / 2)) |>
    tidyr::pivot_wider(values_from = "value", names_from = "ci")

  efficiencies <- dplyr::lst(ip, op) |>
    purrr::map(\(x) dplyr::select(x, -dplyr::matches("value_id")))

  dplyr::lst(efficiencies)

}

tidy_params_bed_occupancy <- function(p) {

  bed_occupancy <- p[["bed_occupancy"]] |>
    purrr::map(tibble::enframe) |>
    purrr::map(\(x) tidyr::unnest_longer(x, "value"))

  bed_occupancy[["day+night"]] <- bed_occupancy[["day+night"]] |>
    dplyr::mutate(ci = rep(c("lower", "upper"), dplyr::n() / 2)) |>
    tidyr::pivot_wider(values_from = "value", names_from = "ci")

  dplyr::lst(bed_occupancy)

}

tidy_params_time_profile_mappings <- function(p) {

  tpm_list <- p[["time_profile_mappings"]] |>
    purrr::keep(is.list) |>
    purrr::map(tibble::enframe) |>
    purrr::map(\(x) {
      x |>
        tidyr::unnest_longer("value") |>
        dplyr::relocate("value", .after = "value_id")
    })

  others <- p[["time_profile_mappings"]] |>
    purrr::keep(is.character) |>
    tibble::enframe() |>
    tidyr::unnest("value")

  list(time_profile_mappings = c(dplyr::lst(others), tpm_list))

}

tidy_params_multi <- function(p) {

  params_to_unpack <- c(
    "expat",
    "repat_local",
    "repat_nonlocal",
    "baseline_adjustment",
    "non-demographic_adjustment",
    "activity_avoidance"
  )

  p[names(p) %in% params_to_unpack] |>
    purrr::map(unpack_params) |>
    purrr::map(widen_intervals)

}

unpack_params <- function(data) {

  data |>
    purrr::map(tibble::enframe) |>
    purrr::map(\(x) {
      x |>
        tidyr::unnest_longer("value") |>
        tidyr::unnest_longer("value")
    })

}

widen_intervals <- function(data) {

  data |>
    purrr::map(\(x) {
      x |>
        dplyr::mutate(ci = rep(c("lower", "upper"), dplyr::n() / 2)) |>
        tidyr::pivot_wider(values_from = "value", names_from = "ci")
    })

}
