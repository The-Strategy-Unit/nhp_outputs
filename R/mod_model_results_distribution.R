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
      htmltools::p(
        "Bed days are defined as the difference in days between discharge and admission, plus one day.",
        "See the",
        htmltools::a(
          href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information",
          "model project information site"
        ),
        "for definitions of terms."
      )
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

mod_model_results_distribution_get_data <- function(r, selected_measure, sites) {
  activity_type <- pod <- measure <- NULL
  c(activity_type, pod, measure) %<-% selected_measure
  get_model_run_distribution(r, pod, measure, sites)
}

mod_model_results_distribution_beeswarm_plot <- function(data, show_origin) {
  b <- data$baseline[[1]]
  p <- data$principal[[1]]

  x_placeholder <- "100%" # dummy label to help line up beeswarm and ECDF plots

  data |>
    require_rows() |>
    ggplot2::ggplot() +
    suppressWarnings(
      ggbeeswarm::geom_quasirandom(
        ggplot2::aes(
          x = x_placeholder,
          y = .data$value,
          colour = .data$variant,
          text = glue::glue("Value: {scales::comma(value, accuracy = 1)}\nVariant: {variant}")
        ),
        alpha = 0.5
      )
    ) +
    ggplot2::geom_hline(yintercept = b, colour = "dimgrey") +
    ggplot2::geom_hline(yintercept = p, linetype = "dashed", colour = "red") +
    ggplot2::expand_limits(y = ifelse(show_origin, 0, b)) +
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(
      breaks = scales::pretty_breaks(10),
      labels = scales::comma,
      expand = c(0.002, 0)
    ) +
    ggplot2::theme(
      legend.position = "bottom",
      axis.title.x = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      # keep y-axis labels to help line up beeswarm/ECDF, but make 'invisible'
      axis.text.y = ggplot2::element_text(colour = "white"),
      axis.title.y = ggplot2::element_text(colour = "white")
    )
}

mod_model_results_distribution_ecdf_plot <- function(data, show_origin) {
  b <- data$baseline[[1]]
  p <- data$principal[[1]]

  ecdf_fn <- stats::ecdf(data[["value"]])

  # Calculate x values for y-axis quantiles
  probs_pcnts <- c(0.1, 0.9)
  x_quantiles <- stats::quantile(ecdf_fn, probs = probs_pcnts)

  # Calculate y value for principal x value (find nearest % for the principal)
  x_vals <- sort(data[["value"]])
  y_vals <- sort(ecdf_fn(data[["value"]]))
  principal_diffs <- abs(p - x_vals) # nearest x in ECDF to the principal
  min_principal_diff_i <- which(principal_diffs == min(principal_diffs))[1]
  p_pcnt <- y_vals[min_principal_diff_i]

  min_x <- min(b, min(data[["value"]]))
  min_x <- dplyr::if_else(show_origin, 0, min_x)

  line_guides <- tibble::tibble(
    x_start = c(rep(min_x, 3), x_quantiles, p),
    x_end   = rep(c(x_quantiles, p), 2),
    y_start = c(probs_pcnts, p_pcnt, rep(0, 3)),
    y_end   = rep(c(probs_pcnts, p_pcnt), 2),
    colour  = "cornflowerblue"
  )

  lines_n <- nrow(line_guides)
  line_guides[c(lines_n, lines_n / 2), "colour"] <- "red"

  data |>
    require_rows() |>
    ggplot2::ggplot() +
    suppressWarnings(
      ggplot2::geom_point(
        ggplot2::aes(
          x_vals,
          y_vals,
          text = glue::glue(
            "Percentage: {scales::percent(y_vals, accuracy = 1)}\n",
            "Value: {scales::comma(x_vals, accuracy = 1)}"
          )
        ),
        alpha = 0.01,
        size = 0.01
      )
    ) +
    ggplot2::geom_step(ggplot2::aes(x_vals, y_vals)) +
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data$x_start,
        y = .data$y_start,
        xend = .data$x_end,
        yend = .data$y_end
      ),
      data = line_guides,
      linetype = "dashed",
      colour = line_guides[["colour"]]
    ) +
    ggplot2::geom_vline(xintercept = b, colour = "dimgrey") +
    ggplot2::ylab("Percentage of model runs") +
    ggplot2::expand_limits(x = ifelse(show_origin, 0, b)) +
    ggplot2::scale_x_continuous(
      breaks = scales::pretty_breaks(10),
      labels = scales::comma,
      expand = c(0.002, 0),
      limits = c(min_x, NA)
    ) +
    ggplot2::scale_y_continuous(
      breaks = c(seq(0, 1, 0.1)),
      labels = scales::percent,
      expand = c(0, 0)
    ) +
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
        htmltools::span("grey vertical continuous line", style = "color:dimgrey"),
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
        htmltools::span("grey vertical continuous line", style = "color:dimgrey"),
        " is the baseline value (",
        b_val,
        ")."
      )
    })


    # Plots ----

    output$beeswarm <- plotly::renderPlotly({
      data <- shiny::req(aggregated_data())

      shiny::req(is.logical(input$show_origin))

      mod_model_results_distribution_beeswarm_plot(data, input$show_origin) |>
        plotly::ggplotly(tooltip = "text") |>
        plotly::layout(legend = list(orientation = "h"))
    })

    output$ecdf <- plotly::renderPlotly({
      data <- shiny::req(aggregated_data())

      mod_model_results_distribution_ecdf_plot(data, input$show_origin) |>
        plotly::ggplotly(tooltip = "text")
    })
  })
}
