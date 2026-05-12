get_result_sets <- function(
  allowed_datasets = get_user_allowed_datasets(NULL)
) {
  token <- azkit::get_auth_token()
  if (!token$validate()) {
    token$refresh()
  }

  app_url <- config::get("app_url")
  build_app_url <- function(version, dataset, model_run_id, outputs_app_uri) {
    glue::glue(app_url)
  }

  azkit::read_azure_table(
    table_name = Sys.getenv("AZ_TABLE_NAME"),
    table_endpoint = Sys.getenv("AZ_TABLE_EP"),
    token = token,
    filter = "status eq 'complete'"
  ) |>
    dplyr::filter(.data[["dataset"]] %in% allowed_datasets) |>
    dplyr::mutate(
      dplyr::across(
        "app_version",
        \(.x) {
          ifelse(
            stringr::str_starts(.x, "v"),
            stringr::str_replace(.x, "\\.", "-"),
            "dev"
          )
        }
      ),
      dplyr::across(
        "outputs_app_uri",
        \(.x) {
          build_app_url(
            .data[["app_version"]],
            .data[["dataset"]],
            .data[["RowKey"]],
            .x
          )
        }
      )
    )
}

get_user_allowed_datasets <- function(groups) {
  p <- jsonlite::read_json("datasets.json", simplifyVector = TRUE) |>
    names()

  if (!(is.null(groups) || any(c("nhp_devs", "nhp_power_users") %in% groups))) {
    a <- groups |>
      stringr::str_subset("^nhp_(national|icb|provider)_") |>
      stringr::str_remove("^nhp_(national|icb|provider)_")
    intersect(p, a)
  } else {
    p
  }
}

require_rows <- function(x) {
  shiny::req(x)
  shiny::req(nrow(x) > 0)
  x
}

filter_result_sets <- function(result_sets, ds, sc, cd) {
  result_sets |>
    shiny::req() |>
    dplyr::filter(
      .data[["dataset"]] == ds,
      .data[["scenario"]] == sc,
      .data[["create_datetime"]] == cd
    ) |>
    require_rows()
}

ui_body <- bs4Dash::bs4DashBody(
  shiny::h1("NHP Model Results"),
  bs4Dash::box(
    title = "Make selections",
    collapsible = FALSE,
    width = 6,
    shiny::selectInput("dataset", "Dataset", NULL),
    shiny::selectInput("scenario", "Scenario", NULL),
    shiny::selectInput("create_datetime", "Model Run Time", NULL),
    shiny::uiOutput("view_results")
  ),
  bs4Dash::box(
    title = "Notes",
    collapsible = FALSE,
    width = 6,
    htmltools::p(
      "Further information about the model and these results can be found on the",
      htmltools::a(
        href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information",
        "model project information site."
      )
    )
  )
)

ui <- bs4Dash::bs4DashPage(
  bs4Dash::dashboardHeader(disable = TRUE),
  bs4Dash::dashboardSidebar(disable = TRUE),
  ui_body,
  help = NULL,
  dark = NULL
)


server <- function(input, output, session) {
  # static data files ----
  datasets_list <- jsonlite::read_json("datasets.json", simplifyVector = TRUE)
  datasets_list <- purrr::set_names(names(datasets_list), unname(datasets_list))

  # reactives ----
  allowed_datasets <- shiny::reactive({
    get_user_allowed_datasets(session$groups)
  })

  result_sets <- shiny::reactive({
    rs <- get_result_sets(
      allowed_datasets()
    )

    # if a user isn't in the nhp_dev group, then do not display un-viewable/dev results
    if (any(c("nhp_devs") %in% session$groups || is.null(session$user))) {
      return(rs)
    }

    dplyr::filter(
      rs,
      .data[["viewable"]],
      .data[["app_version"]] != "dev"
    )
  })

  datasets <- shiny::reactive({
    rs <- shiny::req(result_sets())
    ds <- unique(rs$dataset)

    datasets_list[datasets_list %in% ds]
  })

  scenarios <- shiny::reactive({
    ds <- shiny::req(input$dataset)

    result_sets() |>
      dplyr::filter(.data[["dataset"]] == ds) |>
      dplyr::arrange(dplyr::desc(.data[["create_datetime"]])) |>
      dplyr::pull("scenario") |>
      unique()
  }) |>
    shiny::bindEvent(input$dataset)

  create_datetimes <- shiny::reactive({
    ds <- shiny::req(input$dataset)
    sc <- shiny::req(input$scenario)

    result_sets() |>
      shiny::req() |>
      dplyr::filter(
        .data[["dataset"]] == ds,
        .data[["scenario"]] == sc
      ) |>
      dplyr::mutate(
        create_datetime_dt = .data[["create_datetime"]] |>
          lubridate::as_datetime(tz = "UTC") |>
          lubridate::with_tz() |>
          format("%d/%m/%Y %H:%M:%S"),
        create_datetime_label = glue::glue(
          "{.data[['create_datetime_dt']]} ({.data[['app_version']]})",
        )
      ) |>
      dplyr::select(create_datetime_label, create_datetime) |>
      dplyr::distinct() |>
      tibble::deframe() |> # a vector where names are user-facing labels
      sort() |>
      rev() # most recent first
  })

  selected_file <- shiny::reactive({
    ds <- shiny::req(input$dataset)
    sc <- shiny::req(input$scenario)
    cd <- shiny::req(input$create_datetime)

    filter_result_sets(result_sets(), ds, sc, cd)
  })

  # observers to update the dropdowns ----
  shiny::observe({
    ds <- shiny::req(datasets())

    shiny::updateSelectInput(
      session,
      "dataset",
      choices = ds
    )
  })

  shiny::observe({
    sc <- shiny::req(scenarios())

    shiny::updateSelectInput(
      session,
      "scenario",
      choices = sc
    )
  })

  shiny::observe({
    cd <- shiny::req(create_datetimes())

    shiny::updateSelectInput(
      session,
      "create_datetime",
      choices = cd
    )
  })

  output$view_results <- shiny::renderUI({
    f <- shiny::req(selected_file())

    shiny::tags$a(
      "View Results",
      href = f$outputs_app_uri,
      target = "_blank",
      class = "btn btn-primary",
      role = "button"
    )
  })
}

shiny::shinyApp(
  shiny::tagList(
    shiny::tags$head(
      shiny::tags$title("NHP: Outputs Selection")
    ),
    ui
  ),
  server
)
