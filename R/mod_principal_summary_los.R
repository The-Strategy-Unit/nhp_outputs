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
      htmltools::p(
        "See the",
        htmltools::a(
          href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information/user_guide/glossary.html",
          "model project information site"
        ),
        "for definitions of terms."
      )
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

mod_principal_summary_los_data <- function(r, sites, measure) {
  pods <- mod_principal_high_level_pods()

  summary_los <- r$results$los_group |>
    dplyr::filter(.data$measure == .env$measure) |>
    trust_site_aggregation(sites) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::mutate(
      los_group = factor(
        .data$los_group,
        levels = c("0-day", "1-7 days", "8-14 days", "15-21 days", "22+ days")
      ),
      change = .data$principal - .data$baseline,
      change_pcnt = .data$change / .data$baseline
    ) |>
    dplyr::select("pod_name", "los_group", "baseline", "principal", "change", "change_pcnt") |>
    dplyr::arrange("pod_name", "los_group")

  summary_los[order(summary_los$pod_name, summary_los$los_group), ]
}

mod_principal_summary_los_table <- function(data) {
  data |>
    dplyr::mutate(
      dplyr::across(
        "principal",
        \(.x) gt_bar(.x, scales::comma_format(1), "#686f73", "#686f73")
      ),
      dplyr::across("change", \(.x) gt_bar(.x, scales::comma_format(1))),
      dplyr::across("change_pcnt", \(.x) gt_bar(.x, scales::percent_format(1)))
    ) |>
    gt::gt(groupname_col = "pod_name") |>
    gt::cols_align(align = "left", columns = "los_group") |>
    gt::cols_label(
      "los_group" = "Length of Stay",
      "baseline" = "Baseline",
      "principal" = "Principal",
      "change" = "Change",
      "change_pcnt" = "Percent Change"
    ) |>
    gt::fmt_integer("baseline") |>
    gt::cols_width(
      .data$principal ~ px(150),
      .data$change ~ px(150),
      .data$change_pcnt ~ px(150)
    ) |>
    gt::cols_align(
      align = "left",
      columns = c("baseline", "principal", "change", "change_pcnt")
    ) |>
    gt_theme()
}

#' principal_summary Server Functions
#'
#' @noRd
mod_principal_summary_los_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    summary_los_data_beddays <- shiny::reactive({
      selected_data() |>
        mod_principal_summary_los_data(selected_site(), measure = "beddays")
    })

    summary_los_data_admissions <- shiny::reactive({
      selected_data() |>
        mod_principal_summary_los_data(selected_site(), measure = "admissions")
    })

    output$summary_los_table_beddays <- gt::render_gt({
      summary_los_data_beddays() |>
        mod_principal_summary_los_table()
    })

    output$summary_los_table_admissions <- gt::render_gt({
      summary_los_data_admissions() |>
        mod_principal_summary_los_table()
    })
  })
}
