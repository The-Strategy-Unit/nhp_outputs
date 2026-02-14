shim_default <- function(results) {
  results |>
    purrr::pluck("results", "default") |>
    dplyr::mutate(
      model_runs = purrr::map2(baseline, model_runs, \(x, y) c(x, y))
    ) |>
    dplyr::select(c(pod, sitetret, measure, value = model_runs)) |>
    dplyr::mutate(model_run = list(0:256)) |> # Won't work for different run sizes
    tidyr::unnest(cols = c(model_run, value))
}
