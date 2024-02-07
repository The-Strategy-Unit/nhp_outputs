#' info_params UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_info_params_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::h1("Information: input parameters"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      htmltools::p(
        "This page contains a reminder of the parameter values you provided to the model inputs app.",
        "Further information about the model and these outputs can be found on the",
        htmltools::a(
          href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information",
          "model project information site."
        ),
      )
    ),
    bs4Dash::box(
      title = "Meta information",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_meta"))
    ),
    bs4Dash::box(
      title = "Demographic factors",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_demographic_factors"))
    ),
    bs4Dash::box(
      title = "Baseline adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_baseline_adjustment"))
    ),
    bs4Dash::box(
      title = "Covid adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_covid_adjustment"))
    ),
    bs4Dash::box(
      title = "Waiting list adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_waiting_list_adjustment"))
    ),
    bs4Dash::box(
      title = "Expatriation",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_expat"))
    ),
    bs4Dash::box(
      title = "Repatriation (local)",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_repat_local"))
    ),
    bs4Dash::box(
      title = "Repatriation (non-local)",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_repat_nonlocal"))
    ),
    bs4Dash::box(
      title = "Non-demographic adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_non_demographic_adjustment"))
    ),
    bs4Dash::box(
      title = "Activity avoidance",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_activity_avoidance"))
    ),
    bs4Dash::box(
      title = "Efficiences",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_efficiencies"))
    ),
    bs4Dash::box(
      title = "Bed occupancy",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_bed_occupancy"))
    ),
    bs4Dash::box(
      title = "Time profile mappings",
      collapsed = TRUE,
      width = 12,
      shiny::verbatimTextOutput(ns("params_time_profile_mappings"))
    )
  )

}

#' info_params Server Functions
#'
#' @noRd
mod_info_params_server <- function(id, selected_data) {

  shiny::moduleServer(id, function(input, output, session) {

    ns <- session$ns

    params_data <- shiny::reactive({
      selected_data() |> get_params()
    })

    output$params_meta <- shiny::renderPrint({
      p <- params_data()
      p[names(p) %in% c("scenario", "start_year", "end_year")]
    })

    output$params_demographic_factors <- shiny::renderPrint({
      params_data()[["demographic_factors"]]
    })

    output$params_baseline_adjustment <- shiny::renderPrint({
      params_data()[["baseline_adjustment"]]
    })

    output$params_covid_adjustment <- shiny::renderPrint({
      params_data()[["covid_adjustment"]]
    })

    output$params_waiting_list_adjustment <- shiny::renderPrint({
      params_data()[["waiting_list_adjustment"]]
    })

    output$params_expat <- shiny::renderPrint({
      params_data()[["expat"]]
    })

    output$params_repat_local <- shiny::renderPrint({
      params_data()[["repat_local"]]
    })

    output$params_repat_nonlocal <- shiny::renderPrint({
      params_data()[["repat_nonlocal"]]
    })

    output$params_non_demographic_adjustment <- shiny::renderPrint({
      params_data()[["non-demographic_adjustment"]]
    })

    output$params_activity_avoidance <- shiny::renderPrint({
      params_data()[["activity_avoidance"]]
    })

    output$params_efficiencies <- shiny::renderPrint({
      params_data()[["efficiencies"]]
    })

    output$params_bed_occupancy<- shiny::renderPrint({
      params_data()[["bed_occupancy"]]
    })

    output$params_time_profile_mappings <- shiny::renderPrint({
      params_data()[["time_profile_mappings"]]
    })

  })

}
