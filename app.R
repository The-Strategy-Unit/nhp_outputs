encrypt_filename <- function(filename, key_b64 = Sys.getenv("NHP_ENCRYPT_KEY")) {
  key <- openssl::base64_decode(key_b64)

  f <- charToRaw(filename)

  ct <- openssl::aes_cbc_encrypt(f, key, NULL)
  hm <- as.raw(openssl::sha256(ct, key))

  openssl::base64_encode(c(hm, ct))
}

get_container <- function() {
  ep_uri <- Sys.getenv("AZ_STORAGE_EP")
  sa_key <- Sys.getenv("AZ_STORAGE_KEY")

  ep <- if (sa_key != "") {
    AzureStor::blob_endpoint(ep_uri, key = sa_key)
  } else {
    token <- AzureAuth::get_managed_token("https://storage.azure.com/") |>
      AzureAuth::extract_jwt()

    AzureStor::blob_endpoint(ep_uri, token = token)
  }
  AzureStor::storage_container(ep, Sys.getenv("AZ_STORAGE_CONTAINER"))
}

get_result_sets <- function(allowed_datasets = get_user_allowed_datasets(NULL), folder = "dev") {
  ds <- tibble::tibble(dataset = allowed_datasets)

  cont <- get_container()

  cont |>
    AzureStor::list_blobs(folder, info = "all", recursive = TRUE) |>
    dplyr::filter(!.data[["isdir"]]) |>
    purrr::pluck("name") |>
    purrr::set_names() |>
    purrr::map(\(name, ...) AzureStor::get_storage_metadata(cont, name)) |>
    dplyr::bind_rows(.id = "file") |>
    dplyr::semi_join(ds, by = dplyr::join_by("dataset"))
}

get_user_allowed_datasets <- function(groups) {
  p <- jsonlite::read_json("providers.json", simplifyVector = TRUE)

  if (!(is.null(groups) || any(c("nhp_devs", "nhp_power_users") %in% groups))) {
    a <- groups |>
      stringr::str_subset("^nhp_provider_") |>
      stringr::str_remove("^nhp_provider_")
    p <- intersect(p, a)
  }

  c("synthetic", p)
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
    ),
    htmltools::p(
      "Note that some data is presented at trust level even if you make a site selection.",
      "Check the notes in each tab for details."
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
  providers <- c("Synthetic" = "synthetic", readRDS("providers.Rds"))

  # reactives ----
  allowed_datasets <- shiny::reactive({
    get_user_allowed_datasets(session$groups)
  })

  result_sets <- shiny::reactive({
    rs <- get_result_sets(
      allowed_datasets(),
      config::get("folder")
    )

    if (!"nhp_devs" %in% session$groups) {
      rs <- dplyr::filter(rs, .data[["app_version"]] != "dev")
    }

    rs
  })

  datasets <- shiny::reactive({
    rs <- shiny::req(result_sets())
    ds <- unique(rs$dataset)

    providers[providers %in% ds]
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
      dplyr::pull(.data[["create_datetime"]]) |>
      unique() |>
      sort() |>
      rev()
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

    labels <- \(.x) .x |>
      lubridate::as_datetime("%Y%m%d_%H%M%S", tz = "UTC") |>
      lubridate::with_tz() |>
      format("%d/%m/%Y %H:%M:%S")

    shiny::updateSelectInput(
      session,
      "create_datetime",
      choices = purrr::set_names(cd, labels)
    )
  })

  output$view_results <- shiny::renderUI({
    f <- shiny::req(selected_file())
    version <- stringr::str_replace(f$app_version, "\\.", "-") # nolint

    file <- encrypt_filename(f$file) # nolint

    url <- glue::glue(config::get("app_url"), "?{file}")

    shiny::tags$a(
      "View Results",
      href = url,
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
