#' principal_detailed UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_detailed_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: activity in detail"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "notes-beddays.md")
    ),
    bs4Dash::box(
      title = "Make selections",
      collapsible = FALSE,
      width = 12,
      shiny::fluidRow(
        mod_measure_selection_ui(ns("measure_selection"), width = 3),
        col_3(shiny::selectInput(ns("aggregation"), "Show Results By", NULL))
      )
    ),
    bs4Dash::box(
      title = "Activity by sex and age or treatment specialty",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("results"))
      )
    )
  )
}


#' principal_detailed Server Functions
#'
#' @noRd
mod_principal_detailed_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    available_aggregations <- shiny::reactive({
      selected_data() |>
        get_available_aggregations()
    })

    shiny::observe({
      c(activity_type, pod, measure) %<-% selected_measure()

      a <- available_aggregations()[[activity_type]] |>
        # for this page, just keep the aggregations of the form "a+b"
        stringr::str_subset("^\\w+\\+\\w+$") |>
        # then remove the first word
        stringr::str_remove_all("^\\w+\\+")

      an <- c(
        "Age Group" = "age_group",
        "Treatment Specialty" = "tretspef_grouped"
      )

      agg_choices <- an[an %in% a]

      shiny::updateSelectInput(session, "aggregation", choices = agg_choices)
    })

    output$results <- gt::render_gt({
      shiny::req(input$aggregation)

      end_year <- selected_data()[["params"]][["end_year"]]

      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_detailed_activity_data(
          measure = selected_measure()$measure,
          activity_type = selected_measure()$activity_type,
          aggregation = input$aggregation,
          pods = selected_measure()$pods,
          sites = selected_site()
        ) |>
        require_rows() |>
        reskit::make_detailed_activity_table(final_year = end_year)
    })
  })
}
