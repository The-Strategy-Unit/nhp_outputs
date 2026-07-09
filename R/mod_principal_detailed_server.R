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

      selected_data()[["results"]] |>
        reskit::compile_detailed_activity_data(
          measure = selected_measure()$measure,
          activity_type = selected_measure()$activity_type,
          aggregation = input$aggregation,
          pods = selected_measure()$pod,
          sites = selected_site(),
          tretspef_lookup = get_tretspef_lookup(),
          pod_lookup = get_pod_lookup()
        ) |>
        require_rows() |>
        reskit::make_detailed_activity_table(final_year = end_year)
    })
  })
}
