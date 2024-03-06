#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @noRd
app_server <- function(input, output, session) {
  selected_data <- shiny::reactive({
    tryCatch(
      {
        server_get_results(session)
      },
      error = \(e) {
        session$allowReconnect(FALSE)

        shiny::showModal(
          shiny::modalDialog(
            title = "Error",
            footer = NULL,
            shiny::tagList(
              e$message,
              "Please return to",
              shiny::tags$a("result selection", href = "/nhp/outputs")
            )
          )
        )
        session$close()
      }
    )
  })

  # handle site selection ----

  selected_site <- shiny::reactive({
    # as the value is passed on to other modules, it's useful to encapsulate
    # this into a reactive
    input$site_selection
  })

  trust_sites <- shiny::reactive({
    selected_data() |>
      shiny::req() |>
      get_trust_sites()
  })

  shiny::observe({
    sites <- jsonlite::read_json(app_sys("app", "data", "sites.json"), simplify_vector = TRUE)

    trust_sites <- purrr::set_names(
      trust_sites(),
      \(.x) {
        purrr::map_chr(
          .x,
          \(.y) glue::glue("{sites[[.y]] %||% lookup_ods_org_code_name(.y)} ({.y})")
        )
      }
    )

    shiny::updateSelectInput(session, "site_selection", choices = trust_sites)
  })

  shiny::observe({
    s <- length(selected_site())

    if (s == length(trust_sites())) {
      shiny::updateSelectInput(session, "site_selection", selected = character())
    }

    js <- glue::glue(
      "$('#site_selection').attr('placeholder', '{ifelse(s == 0, 'All sites selected', '')}')"
    )

    shinyjs::runjs(js)
  })

  # set up modules ----

  mod_info_home_server("home", selected_data)

  mod_principal_summary_server("principal_summary", selected_data, selected_site)
  mod_principal_change_factor_effects_server("principal_change_factor_effects", selected_data, selected_site)
  mod_principal_high_level_server("principal_high_level", selected_data, selected_site)
  mod_principal_detailed_server("principal_detailed", selected_data, selected_site)

  mod_model_core_activity_server("model_core_activity", selected_data, selected_site)
  mod_model_results_distribution_server("model_results_distribution", selected_data, selected_site)

  mod_info_downloads_server("info_downloads", selected_data)
  mod_info_params_server("info_params", selected_data)

  # other stuff ----

  shiny::observe({
    shiny::req(user_requested_cache_reset(session))

    dc <- shiny::shinyOptions()$cache

    dc$reset()
  })

  if (!getOption("golem.app.prod", FALSE)) {
    session$allowReconnect("force")
  }

  return(NULL)
}
