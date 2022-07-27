#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @noRd
app_ui <- function(request) {
  header <- bs4Dash::dashboardHeader(title = "NHP Model Results")

  sidebar <- bs4Dash::dashboardSidebar(
    fixed = TRUE,
    skin = "light",
    status = "primary",
    bs4Dash::sidebarMenu(
      id = "sidebarMenu",
      bs4Dash::menuItem(
        "Home",
        tabName = "tab_home",
        icon = shiny::icon("home")
      ),
      bs4Dash::menuItem(
        "Principal Projection",
        startExpanded = FALSE,
        bs4Dash::menuSubItem(
          text = "High Level",
          tabName = "tab_phl"
        ),
        bs4Dash::menuSubItem(
          text = "Detailed",
          tabName = "tab_pd"
        ),
        bs4Dash::menuSubItem(
          text = "Change Factors",
          tabName = "tab_pcf"
        )
      ),
      bs4Dash::menuItem(
        "Model Results",
        startExpanded = FALSE,
        bs4Dash::menuSubItem(
          text = "Core Activity",
          tabName = "tab_mc"
        ),
        bs4Dash::menuSubItem(
          text = "Results Distribution",
          tabName = "tab_md"
        )
      ),
      bs4Dash::menuItem(
        "Capacity Conversion",
        startExpanded = FALSE,
        bs4Dash::menuSubItem(
          text = "Beds",
          tabName = "tab_cb"
        ),
        bs4Dash::menuSubItem(
          text = "Theatres",
          tabName = "tab_ct"
        )
      ),
      htmltools::tags$hr(),
      bs4Dash::menuItem(
        "Run Model",
        startExpanded = FALSE,
        bs4Dash::menuSubItem(
          text = "Upload Params",
          tabName = "tab_up",
          icon = shiny::icon("sliders-h")
        ),
        bs4Dash::menuSubItem(
          text = "Running Models",
          tabName = "tab_rm",
          icon = shiny::icon("running")
        )
      )
    )
  )

  body <- bs4Dash::dashboardBody(
    bs4Dash::tabItems(
      bs4Dash::tabItem(
        tabName = "tab_home",
        shiny::fluidRow(
          col_6(
            htmltools::h1("NHP Model")
            # "About Text should go here"
          ),
          bs4Dash::box(
            title = "Results Selection",
            mod_result_selection_ui("result_selection")
          )
        )
      ),
      bs4Dash::tabItem(
        tabName = "tab_up",
        mod_params_upload_ui("params_upload")
      ),
      bs4Dash::tabItem(
        tabName = "tab_rm",
        mod_running_models_ui("running_models")
      ),
      bs4Dash::tabItem(
        tabName = "tab_phl",
        mod_principal_high_level_ui("principal_high_level")
      ),
      bs4Dash::tabItem(
        tabName = "tab_pd",
        mod_principal_detailed_ui("principal_detailed")
      ),
      bs4Dash::tabItem(
        tabName = "tab_pcf",
        mod_principal_change_factor_effects_ui("principal_change_factor_effects")
      ),
      bs4Dash::tabItem(
        tabName = "tab_mc",
        mod_model_core_activity_ui("model_core_activity")
      ),
      bs4Dash::tabItem(
        tabName = "tab_md",
        mod_model_results_distribution_ui("model_results_distribution")
      ),
      bs4Dash::tabItem(
        tabName = "tab_cb",
        mod_capacity_beds_ui("capacity_beds")
      ),
      bs4Dash::tabItem(
        tabName = "tab_ct",
        mod_capacity_theatres_ui("capacity_theatres")
      )
    )
  )

  shiny::tagList(
    golem_add_external_resources(),
    shinyjs::useShinyjs(),
    bs4Dash::dashboardPage(
      header,
      sidebar,
      body
    )
  )
}
#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  golem::add_resource_path(
    "www", app_sys("app/www")
  )

  htmltools::tags$head(
    golem::favicon(),
    golem::bundle_resources(
      path = app_sys("app/www"),
      app_title = "outputs"
    )
  )
}
