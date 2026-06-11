#' info_home Server Functions
#'
#' @noRd
mod_info_home_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    params_model_run <- shiny::reactive({
      p <- get_params(selected_data())

      p_model_run <- purrr::keep(p, rlang::is_atomic)

      p_model_run[["start_year"]] <- scales::number(
        p_model_run[["start_year"]] +
          ((p_model_run[["start_year"]] + 1) %% 100) / 100,
        0.01,
        big.mark = "",
        decimal.mark = "/"
      )
      p_model_run[["end_year"]] <- scales::number(
        p_model_run[["end_year"]] +
          ((p_model_run[["end_year"]] + 1) %% 100) / 100,
        0.01,
        big.mark = "",
        decimal.mark = "/"
      )

      p_model_run[["create_datetime"]] <- p_model_run[["create_datetime"]] |>
        lubridate::fast_strptime("%Y%m%d_%H%M%S") |>
        format("%d-%b-%Y %H:%M:%S")

      p_model_run |>
        unlist() |>
        tibble::enframe()
    })

    # renders ----

    output$params_model_run <- gt::render_gt({
      params_model_run() |>
        gt::gt("name") |>
        gt_theme()
    })
  })
}
