shim_default <- function(results) {
  results |>
    purrr::pluck("results", "default") |>
    dplyr::mutate(
      model_runs = purrr::map2(.data$baseline, .data$model_runs, c)
    ) |>
    dplyr::select(c("pod", "sitetret", "measure", value = "model_runs")) |>
    dplyr::mutate(
      model_run = purrr::map(.data$value, \(x) seq_along(x) - 1)
    ) |>
    tidyr::unnest(cols = c("model_run", "value"))
}
