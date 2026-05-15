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

#' This reshapes the output of get_activity_type_pod_measure_options to
#' match the format required for reskit functions.
#' Ideally we shouldn't need this in future (issue #406)
get_pod_lookup <- function() {
  get_activity_type_pod_measure_options() |>
    dplyr::select(
      activity_type_label = .data$activity_type_name,
      .data$pod,
      pod_label = .data$pod_name
    ) |>
    dplyr::distinct() |>
    dplyr::mutate(
      activity_type_label = dplyr::replace_values(
        .data$activity_type_label,
        "Inpatients" ~ "Inpatient",
        "Outpatients" ~ "Outpatient"
      )
    ) |>
    dplyr::mutate(dplyr::across(
      c(.data$activity_type_label, .data$pod_label),
      factor
    ))
}
