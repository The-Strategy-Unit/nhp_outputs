shim_tretspef_los <- function(results) {
  results |>
    purrr::pluck("results", "tretspef+los_group") |>
    dplyr::mutate(
      model_runs = purrr::map2(.data$baseline, .data$model_runs, c)
    ) |>
    dplyr::select(c(
      "pod",
      "sitetret",
      "tretspef",
      "los_group",
      "measure",
      value = "model_runs"
    )) |>
    dplyr::mutate(
      model_run = purrr::map(.data$value, \(x) seq_along(x) - 1)
    ) |>
    dplyr::mutate(los_group = as.character(.data$los_group)) |>
    tidyr::unnest(cols = c("model_run", "value"))
}
