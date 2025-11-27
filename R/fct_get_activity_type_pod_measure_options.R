#' Get activity type, POD, and measure options
#'
#' @description Reads the pod_measures configuration and transforms it into
#'   a tibble with activity types, points of delivery (PODs), and their
#'   associated measures.
#'
#' @return Tibble with columns: activity_type, activity_type_name, pod,
#'   pod_name, and measures.
#'
#' @noRd
get_activity_type_pod_measure_options <- function() {
  get_golem_config("pod_measures") |>
    purrr::map_dfr(
      \(.x) {
        .x$pods |>
          purrr::map_dfr(tibble::as_tibble, .id = "pod") |>
          dplyr::transmute(
            activity_type_name = .x$name,
            .data$pod,
            pod_name = .data$name,
            .data$measures
          )
      },
      .id = "activity_type"
    )
}
