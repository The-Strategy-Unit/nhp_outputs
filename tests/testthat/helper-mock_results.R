# Small synthetic stand-in for the output of `get_results_from_azure()` /
# `get_results_from_local()`, so tests don't depend on inst/sample_results
# (which isn't available on CI).
#
# The shape mirrors the real parquet outputs: one long table per aggregation,
# with `model_run` (0 = baseline) and `value` columns.

mock_results <- function(sites = c("AAA01", "AAA02"), n_runs = 3) {
  # fmt: skip
  pod_measures <- tibble::tribble(
    ~activity_type, ~pod, ~measure,
    "aae", "aae_type-01", "ambulance",
    "aae", "aae_type-01", "walk-in",
    "ip", "ip_elective_admission", "admissions",
    "ip", "ip_elective_admission", "beddays",
    "ip", "ip_non-elective_admission", "admissions",
    "ip", "ip_non-elective_admission", "beddays",
    "op", "op_first", "attendances",
    "op", "op_first", "tele_attendances"
  )
  base <- tidyr::expand_grid(
    pod_measures,
    sitetret = sites,
    model_run = seq(0, n_runs)
  )

  add_dim <- \(df, ...) tidyr::expand_grid(df, ...)
  add_value <- \(df) dplyr::mutate(df, value = round(stats::runif(dplyr::n(), 10, 100), 2))
  tidy_cols <- \(df, ...) dplyr::select(df, ..., "model_run", "value")

  withr::with_seed(5127, {
    default <- base |>
      add_value() |>
      tidy_cols("pod", "sitetret", "measure")

    sex_age_group <- base |>
      add_dim(sex = 1:2, age_group = c("0", "1-4", "85+")) |>
      add_value() |>
      tidy_cols("pod", "sitetret", "sex", "age_group", "measure")

    tretspef <- base |>
      add_dim(tretspef = c("100", "101", "110")) |>
      add_value() |>
      tidy_cols("pod", "sitetret", "tretspef", "measure")

    sex_tretspef_grouped <- base |>
      add_dim(sex = 1:2, tretspef_grouped = c("100", "110")) |>
      add_value() |>
      tidy_cols("pod", "sitetret", "sex", "tretspef_grouped", "measure")

    tretspef_los_group <- base |>
      dplyr::filter(
        .data[["activity_type"]] == "ip",
        .data[["measure"]] %in% c("admissions", "beddays")
      ) |>
      add_dim(
        tretspef = c("100", "101"),
        los_group = c("0 days", "1 day", "22+ days")
      ) |>
      add_value() |>
      tidy_cols("pod", "sitetret", "tretspef", "los_group", "measure")

    step_counts <- base |>
      dplyr::mutate(
        measure = dplyr::if_else(
          .data[["activity_type"]] == "aae",
          "arrivals",
          .data[["measure"]]
        )
      ) |>
      dplyr::distinct() |>
      add_dim(
        change_factor = c("baseline", "demographic_adjustment", "efficiencies")
      ) |>
      dplyr::mutate(
        strategy = dplyr::if_else(
          .data[["change_factor"]] == "efficiencies",
          "same_day_emergency_care_high",
          "-"
        )
      ) |>
      add_value() |>
      tidy_cols(
        "activity_type",
        "sitetret",
        "pod",
        "change_factor",
        "strategy",
        "measure"
      )
  })

  results <- list(
    default = default,
    `sex+age_group` = sex_age_group,
    `sex+tretspef_grouped` = sex_tretspef_grouped,
    step_counts = step_counts,
    tretspef = tretspef,
    `tretspef+los_group` = tretspef_los_group
  )

  params <- list(
    params = yyjsonr::read_json_file(app_sys("sample_params.json")) |>
      patch_params()
  )$params

  list(params = params, population_variants = list(), results = results)
}

# Strip every A&E row (identified by pod prefix) from all results tables, to
# mimic a model run that returned no A&E activity.
remove_aae_results <- function(r) {
  r$results <- purrr::map(
    r$results,
    \(x) dplyr::filter_out(x, grepl("^aae", .data[["pod"]]))
  )
  r
}
