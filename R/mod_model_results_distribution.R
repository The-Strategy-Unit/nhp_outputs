#' model_results_distribution UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_model_results_distribution_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::h1("Distribution of projections: activity distribution"),
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
      shiny::fluidRow(mod_measure_selection_ui(ns("measure_selection"), 4)),
      shiny::checkboxInput(ns("show_origin"), "Show Origin (zero)?")
    ),
    bs4Dash::box(
      title = "Beeswarm (model-run distribution)",
      collapsible = FALSE,
      width = 12,
      shiny::htmlOutput(ns("beeswarm_text")),
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("beeswarm"), height = "400px")
      )
    ),
    bs4Dash::box(
      title = "S-curve (empirical cumulative distribution function)",
      collapsible = FALSE,
      width = 12,
      shiny::htmlOutput(ns("ecdf_text")),
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("ecdf"), height = "400px")
      )
    )
  )
}

#' model_results_distribution Server Functions
#'
#' @noRd
mod_model_results_distribution_server <- function(
  id,
  selected_data,
  selected_site
) {
  shiny::moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    aggregated_data <- shiny::reactive({
      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_distribution_plot_data(
          measure = selected_measure()$measure,
          activity_type = selected_measure()$activity_type,
          pods = selected_measure()$pod,
          sites = selected_site()
        ) |>
        require_rows()
    })

    # Dynamic text to go above plots ----

    output$beeswarm_text <- shiny::renderText({
      data <- shiny::req(aggregated_data())

      b <- data$baseline[[1]] |> scales::comma()
      p <- data$principal[[1]] |> scales::comma()

      paste0(
        "The ",
        htmltools::span("red vertical dashed line", style = "color:red"),
        " is the principal value (",
        p,
        ") and the ",
        htmltools::span(
          "grey vertical continuous line",
          style = "color:dimgrey"
        ),
        " is the baseline value (",
        b,
        ")."
      )
    })

    output$ecdf_text <- shiny::renderText({
      data <- shiny::req(aggregated_data())

      b_val <- data$baseline[[1]] |> scales::comma()
      p <- data$principal[[1]]
      p_val <- scales::comma(p)

      ecdf_fn <- stats::ecdf(data[["value"]])

      # Calculate y value for principal x value (find nearest % for the principal)
      x_vals <- sort(data[["value"]])
      y_vals <- sort(ecdf_fn(data[["value"]]))
      principal_diffs <- abs(p - x_vals) # nearest x in ECDF to the principal
      min_principal_diff_i <- which(principal_diffs == min(principal_diffs))[1]
      p_pcnt <- y_vals[min_principal_diff_i] |> scales::percent(accuracy = 1)

      p10_val <- stats::quantile(ecdf_fn, probs = 0.1) |> scales::comma()
      p90_val <- stats::quantile(ecdf_fn, probs = 0.9) |> scales::comma()

      paste0(
        "The ",
        htmltools::span("red dashed line", style = "color:red"),
        " is the principal value (",
        p_val,
        ", which covers ",
        p_pcnt,
        " of model runs), the ",
        htmltools::span("blue dashed lines", style = "color:cornflowerblue"),
        " are the 10th and 90th percentiles (",
        p10_val,
        " and ",
        p90_val,
        ") and the ",
        htmltools::span(
          "grey vertical continuous line",
          style = "color:dimgrey"
        ),
        " is the baseline value (",
        b_val,
        ")."
      )
    })

    # Plots ----

    output$beeswarm <- plotly::renderPlotly({
      data <- shiny::req(aggregated_data())

      shiny::req(is.logical(input$show_origin))

      reskit::make_beeswarm_distrib_plot(data, input$show_origin) |>
        plotly::ggplotly(tooltip = "text")
    })

    output$ecdf <- plotly::renderPlotly({
      data <- shiny::req(aggregated_data())

      reskit::make_cumulative_distrib_plot(data, input$show_origin) |>
        plotly::ggplotly(tooltip = "text")
    })
  })
}
