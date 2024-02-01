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
      title = "Make selections",
      collapsible = FALSE,
      width = 12,
      shiny::fluidRow(
        mod_measure_selection_ui(ns("measure_selection"), 4),
      )
    ),
    bs4Dash::box(
      title = "Density",
      collapsible = FALSE,
      width = 12,
      shiny::checkboxInput(ns("show_origin"), "Show Origin (zero)?"),
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("distribution"), height = "800px")
      )
    ),
    bs4Dash::box(
      title = "Empirical Cumulative Distribution",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("ecdf"), height = "400px")
      )
    )
  )
}

mod_model_results_distribution_get_data <- function(r, selected_measure, sites) {
  activity_type <- pod <- measure <- NULL
  c(activity_type, pod, measure) %<-% selected_measure
  get_model_run_distribution(r, pod, measure, sites)
}

mod_model_results_distibution_density_plot <- function(data, show_origin) {
  b <- data$baseline[[1]]

  px <- data$principal[[1]]
  dn <- density(data$value)
  py <- approx(dn$x, dn$y, px)$y

  data |>
    require_rows() |>
    ggplot2::ggplot(ggplot2::aes(.data$value)) +
    ggplot2::geom_density(fill = "#f9bf07", colour = "#2c2825", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = b) +
    ggplot2::annotate(
      "segment",
      x = px, xend = px,
      y = 0, yend = py,
      linetype = "dashed"
    ) +
    ggplot2::annotate("point", x = px, y = py) +
    ggplot2::expand_limits(x = ifelse(show_origin, 0, b)) +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )
}

mod_model_results_distibution_beeswarm_plot <- function(data, show_origin) {
  b <- data$baseline[[1]]
  p <- data$principal[[1]]

  data |>
    require_rows() |>
    ggplot2::ggplot(ggplot2::aes("1", .data$value, colour = .data$variant)) +
    ggbeeswarm::geom_quasirandom(alpha = 0.5) +
    ggplot2::geom_hline(yintercept = b) +
    ggplot2::geom_hline(yintercept = p, linetype = "dashed") +
    ggplot2::expand_limits(y = ifelse(show_origin, 0, b)) +
    ggplot2::scale_fill_manual(values = c(
      "principal" = "#f9bf07",
      "high_migration" = "#5881c1"
    )) +
    # have to use coord flip with boxplots/violin plots and plotly...
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    )
}

mod_model_results_distibution_plot <- function(data, show_origin) {
  p1 <- plotly::ggplotly(mod_model_results_distibution_density_plot(data, show_origin))
  p2 <- plotly::ggplotly(mod_model_results_distibution_beeswarm_plot(data, show_origin))

  sp <- plotly::subplot(p1, p2, nrows = 2)

  plotly::layout(sp, legend = list(orientation = "h"))
}

mod_model_results_distribution_ecdf_plot <- function(data) {
  values_ecdf <- stats::ecdf(data[["value"]])
  pcnt <- c(0.25, 0.5, 0.75)
  quantiles_ecdf <- stats::quantile(values_ecdf, pcnt)
  min_value <- min(data[["value"]])

  quantile_guides <- tibble::tibble(
    x_start = c(rep(min_value, 3), quantiles_ecdf),
    y_start = c(pcnt, rep(0, 3)),
    x_end = rep(quantiles_ecdf, 2),
    y_end = rep(pcnt, 2)
  )

  data |>
    require_rows() |>
    ggplot2::ggplot(ggplot2::aes(.data$value)) +
    ggplot2::stat_ecdf(geom = "step", pad = FALSE) +
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data$x_start,
        y = .data$y_start,
        xend = .data$x_end,
        yend = .data$y_end
      ),
      data = quantile_guides,
      linetype = "dashed",
      colour = "red"
    ) +
    ggplot2::ylab("Fraction of model runs") +
    ggplot2::scale_x_continuous(
      labels = scales::comma,
      expand = c(0, 0),
      limits = c(min_value, NA)
    ) +
    ggplot2::scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
    ggplot2::theme(axis.title.x = ggplot2::element_blank())
}

#' model_results_distribution Server Functions
#'
#' @noRd
mod_model_results_distribution_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    aggregated_data <- shiny::reactive({
      selected_data() |>
        mod_model_results_distribution_get_data(selected_measure(), selected_site()) |>
        require_rows()
    })

    output$distribution <- plotly::renderPlotly({
      data <- shiny::req(aggregated_data())

      shiny::req(is.logical(input$show_origin))

      mod_model_results_distibution_plot(data, input$show_origin)
    })

    output$ecdf <- plotly::renderPlotly({
      data <- shiny::req(aggregated_data())

      mod_model_results_distribution_ecdf_plot(data)
    })
  })
}
