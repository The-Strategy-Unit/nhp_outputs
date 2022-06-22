#' running_models UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_running_models_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h2("Running Models"),
    shiny::tableOutput(ns("running_models"))
  )
}

#' running_models Server Functions
#'
#' @noRd
mod_running_models_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    refresh_timer <- shiny::reactiveTimer(2500)

    output$running_models <- shiny::renderTable({
      job_status <- function(job_id) {
        batch_get_tasks(job_id) |>
          dplyr::summarise(
            complete = sum(.data$state == "completed"),
            running = sum(.data$state == "running"),
            n = dplyr::n()
          )
      }

      shiny::req(batch_get_jobs()) |>
        dplyr::mutate(status = purrr::map_dfr(.data$id, job_status)) |>
        tidyr::unnest(.data$status)
    }) |>
      shiny::bindEvent(refresh_timer())
  })
}
