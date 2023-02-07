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
    shiny::h2("Pool State"),
    shiny::tableOutput(ns("pool_state")),
    shiny::h2("Running Models"),
    shiny::tableOutput(ns("running_models"))
  )
}

#' running_models Server Functions
#'
#' @noRd
mod_running_models_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    refresh_timer <- shiny::reactiveTimer(5000)

    pool_state_data <- shiny::reactive({
      batch_get_pools() |>
        dplyr::select("id", tidyselect::ends_with("Nodes"))
    }) |>
      shiny::bindEvent(refresh_timer())

    running_models_data <- shiny::reactive({
      job_status <- function(job) {
        job_id <- job$id

        t <- batch_get_tasks(job_id)

        if (is.null(t)) {
          # not sure we should delete the job just yet... just hide it
          # batch_delete_job(job_id)
          return(NULL)
        }

        if (!"exitCode" %in% t) {
          t$exitCode <- 0
        }

        s <- dplyr::summarise(
          t,
          complete = sum(.data$state == "completed"),
          running = sum(.data$state == "running"),
          errors = sum(.data$exitCode != 0),
          n = dplyr::n()
        )

        if (s$complete == s$n) {
          batch_delete_job(job_id)
          return(NULL)
        }

        dplyr::bind_cols(job, s)
      }

      jobs <- batch_get_jobs()
      shiny::req(jobs)

      jobs |>
        purrr::array_tree() |>
        purrr::map_dfr(job_status)
    }) |>
      shiny::bindEvent(refresh_timer())

    output$pool_state <- shiny::renderTable({
      pool_state_data()
    })

    output$running_models <- shiny::renderTable({
      running_models_data()
    })
  })
}
