# nolint start: nolint: object_name_linter

#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  onStart = NULL,
  options = list(
    port = as.numeric(Sys.getenv("GOLEM_PORT", 8081)),
    host = Sys.getenv("GOLEM_HOST", "127.0.0.1")
  ),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {
  if (getOption("golem.app.prod", FALSE)) {
    create_data_cache()
  }

  golem::with_golem_options(
    app = shiny::shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}

# nolint end
