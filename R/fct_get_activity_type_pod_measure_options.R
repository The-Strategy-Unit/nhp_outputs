get_activity_type_pod_measure_options <- function() {
  get_golem_config("pod_measures") |>
    purrr::map(list_to_tbl) |>
    purrr::list_rbind(names_to = "activity_type") |>
    dplyr::mutate(
      dplyr::across("pod_label", forcats::fct_inorder),
      dplyr::across("activity_type_label", \(x) {
        x <- sub("s$", "", x)
        forcats::fct(x, levels = c("Inpatient", "Outpatient", "A&E"))
      })
    )
}

#' This reshapes the output of get_activity_type_pod_measure_options to
#' match the format required for reskit functions.
#' Ideally we shouldn't need this in future (issue #406)
get_pod_lookup <- function() {
  get_activity_type_pod_measure_options() |>
    dplyr::select(!c("activity_type", "measure")) |>
    dplyr::distinct()
}

get_condensed_pod_lookup <- function() {
  get_pod_lookup() |>
    dplyr::filter(dplyr::if_any("activity_type_label", \(x) x != "A&E")) |>
    dplyr::add_row(
      activity_type_label = "A&E",
      pod = "aae",
      pod_label = "A&E Arrivals"
    ) |>
    dplyr::mutate(
      dplyr::across("pod_label", forcats::fct_inorder),
      dplyr::across("activity_type_label", \(x) {
        forcats::fct(x, levels = c("Inpatient", "Outpatient", "A&E"))
      })
    )
}


#' Helper function to extract the required data fields from a list (from YAML)
#' @keywords internal
list_to_tbl <- function(lst) {
  tibble::tibble(
    activity_type_label = lst[["name"]],
    pod = names(lst[["pods"]]),
    pod_label = purrr::map_chr(unname(lst[["pods"]]), "name"),
    measure = purrr::map(unname(lst[["pods"]]), "measures")
  ) |>
    tidyr::unnest_longer("measure")
}
