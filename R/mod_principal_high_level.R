#' principal_high_level UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_high_level_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: activity summary by year"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      htmltools::p(
        "Data is shown at trust level unless sites are selected from the 'Home' tab.",
        "A&E results are not available at site level.",
        "See the",
        htmltools::a(
          href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information/user_guide/glossary.html",
          "model project information site"
        ),
        "for definitions of terms."
      )
    ),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Activity by type and year",
        collapsible = FALSE,
        bs4Dash::tabsetPanel(
          shiny::tabPanel(
            "Value",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("activity_value"))
            )
          ),
          shiny::tabPanel(
            "Change",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("activity_change"))
            )
          ),
          shiny::tabPanel(
            "Percent change",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("activity_change_pcnt"))
            )
          )
        ),
        width = 12
      )
    ),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Inpatient admissions",
        collapsible = FALSE,
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("ip"))
        ),
        width = 4
      ),
      bs4Dash::box(
        title = "Outpatient attendances",
        collapsible = FALSE,
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("op"))
        ),
        width = 4
      ),
      bs4Dash::box(
        title = "A&E attendances (trust-level only)",
        collapsible = FALSE,
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("aae"))
        ),
        width = 4
      )
    )
  )
}

mod_principal_high_level_pods <- function() {
  get_activity_type_pod_measure_options() |>
    dplyr::filter(.data$activity_type != "aae") |>
    dplyr::distinct(.data$activity_type, .data$pod, .data$pod_name) |>
    dplyr::bind_rows(data.frame(activity_type = "aae", pod = "aae", pod_name = "A&E Attendance")) |>
    dplyr::mutate(dplyr::across("pod_name", forcats::fct_inorder))
}

mod_principal_high_level_summary_data <- function(r, pods = mod_principal_high_level_pods(), sites) {
  get_time_profiles(r, "default") |>
    dplyr::filter(
      !.data[["measure"]] %in% c("beddays", "procedures", "tele_attendances")
    ) |>
    dplyr::select(-"measure") |>
    dplyr::mutate(
      dplyr::across("pod", ~ ifelse(stringr::str_starts(.x, "aae"), "aae", .x)),
      fyear = fyear_str(.data[["year"]])
    ) |>
    dplyr::summarise(
      dplyr::across("value", sum),
      .by = -"value"
    ) |>
    trust_site_aggregation(sites) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::select(-"pod") |>
    dplyr::mutate(
      .by = c("pod_name"),
      change = .data$value - dplyr::lag(.data$value),
      change_pcnt = .data$change / dplyr::lag(.data$value)
    )
}

mod_principal_high_level_table <- function(data, summary_type = c("value", "change", "change_pcnt")) {
  fyear_rx <- "\\d{4}/\\d{2}"

  suppressWarnings( # TODO: warning in test, all_of should work
    summary_table <- data |>
      dplyr::select(
        "fyear", "pod_name",
        tidyselect::matches(fyear_rx),
        tidyselect::all_of(summary_type),
        "activity_type"
      ) |>
      dplyr::mutate(
        activity_type = dplyr::case_when(
          activity_type == "ip" ~ "Inpatient",
          activity_type == "op" ~ "Outpatient",
          activity_type == "aae" ~ "A&E"
        )
      ) |>
      tidyr::pivot_wider(names_from = "fyear", values_from = summary_type) |>
      gt::gt(groupname_col = "activity_type") |>
      gt::sub_missing() |>
      gt::cols_align(
        align = "left",
        columns = "pod_name"
      ) |>
      gt::cols_label("pod_name" = "Point of Delivery")
  )

  if (summary_type %in% c("value", "change")) {
    summary_table <- summary_table |>
      gt::fmt_integer(tidyselect::matches(fyear_rx))
  }

  if (summary_type == "change_pcnt") {
    summary_table <- summary_table |>
      gt::fmt_percent(tidyselect::matches(fyear_rx), decimals = 1)
  }

  summary_table |> gt_theme()
}

mod_principal_high_level_plot <- function(data, activity_type) {
  start_year <- end_year <- NULL
  c(start_year, end_year) %<-% range(data$year)

  data |>
    dplyr::filter(
      .data$activity_type == .env$activity_type
    ) |>
    require_rows() |>
    ggplot2::ggplot(ggplot2::aes(.data$year, .data$value, colour = .data$pod_name)) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::scale_x_continuous(
      labels = fyear_str,
      breaks = c(start_year, end_year)
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::comma
    ) +
    ggplot2::expand_limits(y = 0) +
    ggplot2::labs(x = NULL, y = NULL, colour = NULL)
}

#' principal_high_level Server Functions
#'
#' @noRd
mod_principal_high_level_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    pods <- mod_principal_high_level_pods()

    summary_data <- shiny::reactive({
      selected_data() |>
        mod_principal_high_level_summary_data(pods, selected_site())
    })

    output$activity_value <- gt::render_gt({
      summary_data() |>
        mod_principal_high_level_table(summary_type = "value")
    })

    output$activity_change <- gt::render_gt({
      summary_data() |>
        mod_principal_high_level_table(summary_type = "change")
    })

    output$activity_change_pcnt <- gt::render_gt({
      summary_data() |>
        mod_principal_high_level_table(summary_type = "change_pcnt")
    })

    output$aae <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("aae") |>
        plotly::ggplotly() |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })

    output$ip <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("ip") |>
        plotly::ggplotly() |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })

    output$op <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("op") |>
        plotly::ggplotly() |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })
  })
}
