#' principal_summary_los UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_summary_los_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: length of stay summary"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "notes-beddays.md")
    ),
    bs4Dash::box(
      title = "Bed days summary by length of stay and point of delivery",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("summary_los_table_beddays"))
      )
    ),
    bs4Dash::box(
      title = "Admissions summary by length of stay and point of delivery",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("summary_los_table_admissions"))
      )
    )
  )
}

mod_principal_los_pods <- function() {
  get_activity_type_pod_measure_options() |>
    dplyr::filter(.data$activity_type != "aae") |>
    dplyr::distinct(.data$activity_type, .data$pod, .data$pod_name) |>
    dplyr::bind_rows(data.frame(
      activity_type = "aae",
      pod = "aae",
      pod_name = "A&E Attendance"
    )) |>
    dplyr::mutate(dplyr::across("pod_name", forcats::fct_inorder))
}


#' principal_summary Server Functions
#'
#' @noRd
mod_principal_summary_los_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    output$summary_los_table_beddays <- gt::render_gt({
      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_principal_los_data(
          measure = "beddays",
          sites = selected_site()
        ) |>
        reskit::make_principal_los_table()
    })

    output$summary_los_table_admissions <- gt::render_gt({
      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_principal_los_data(
          measure = "admissions",
          sites = selected_site()
        ) |>
        reskit::make_principal_los_table()
    })
  })
}
