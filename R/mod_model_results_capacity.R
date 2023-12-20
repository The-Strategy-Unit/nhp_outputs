#' capacity_beds UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_model_results_capacity_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Distribution of projections: capacity requirements distribution"),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Beds",
        width = 12,
        shiny::fluidRow(
          col_3(
            shiny::selectInput(
              ns("beds_quarter"),
              "Quarter",
              purrr::set_names(c("q1", "q2", "q3", "q4"), stringr::str_to_upper)
            )
          ),
          col_3(
            shiny::selectInput(
              ns("beds_ward_type"),
              "Ward Type",
              NULL
            )
          )
        ),
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("beds"), height = "800px"),
        )
      )
    )
  )
}

mod_model_results_capacity_beds_density_plot <- function(data, baseline, px, py) {
  data |>
    ggplot2::ggplot(ggplot2::aes(.data$value)) +
    ggplot2::geom_density(fill = "#f9bf07", colour = "#2c2825", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = baseline) +
    ggplot2::annotate(
      "segment",
      x = px, xend = px,
      y = 0, yend = py,
      linetype = "dashed"
    ) +
    ggplot2::annotate("point", x = px, y = py) +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )
}

mod_model_results_capacity_beds_beeswarm_plot <- function(data, baseline, median) {
  data |>
    ggplot2::ggplot(ggplot2::aes("1", .data$value, colour = .data$variant)) +
    ggbeeswarm::geom_quasirandom(alpha = 0.5) +
    ggplot2::geom_hline(yintercept = baseline) +
    ggplot2::geom_hline(yintercept = median, linetype = "dashed") +
    # have to use coord flip with boxplots/violin plots and plotly...
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(x = "", y = "Number of beds available") +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    )
}

mod_model_results_capacity_beds_available_plot <- function(data) {
  ds <- data |>
    dplyr::filter(.data$model_run == 1) |>
    dplyr::summarise(
      dplyr::across(c("baseline", "principal"), sum)
    )

  b <- ds$baseline[[1]]
  px <- median(data$value)
  dn <- density(data$value)
  py <- approx(dn$x, dn$y, px)$y

  p1 <- mod_model_results_capacity_beds_density_plot(data, b, px, py)
  p2 <- mod_model_results_capacity_beds_beeswarm_plot(data, b, px)

  p1p <- plotly::ggplotly(p1)
  p2p <- plotly::ggplotly(p2)

  sp <- plotly::subplot(p1p, p2p, nrows = 2)

  plotly::layout(sp, legend = list(orientation = "h"))
}

#' capacity_beds Server Functions
#'
#' @noRd
mod_model_results_capacity_server <- function(id, selected_data) {
  shiny::moduleServer(id, function(input, output, session) {
    all_beds_data <- shiny::reactive({
      selected_data() |>
        get_bed_occupancy()
    })

    beds_data <- shiny::reactive({
      wt <- shiny::req(input$beds_ward_type)
      qt <- shiny::req(input$beds_quarter)

      all_beds_data() |>
        dplyr::filter(
          .data[["ward_type"]] == wt,
          .data[["quarter"]] == qt
        ) |>
        dplyr::summarise(
          dplyr::across(c("baseline", "principal", "value"), sum),
          .by = c("model_run", "variant")
        )
    })

    ward_types <- shiny::reactive({
      all_beds_data() |>
        dplyr::filter(
          .data$quarter == input$beds_quarter
        ) |>
        dplyr::pull("ward_type") |>
        unique()
    })

    shiny::observe({
      current_selection <- input$beds_ward_type

      if (!current_selection %in% ward_types()) {
        current_selection <- ward_types()[[1]]
      }

      shiny::updateSelectInput(
        session,
        "beds_ward_type",
        choices = ward_types(),
        selected = current_selection
      )
    }) |>
      shiny::bindEvent(ward_types())

    variants <- shiny::reactive({
      selected_data() |>
        get_variants()
    })

    output$beds <- plotly::renderPlotly({
      beds_data() |>
        mod_model_results_capacity_beds_available_plot()
    })

  })
}
