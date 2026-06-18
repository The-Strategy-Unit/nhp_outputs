#' info_downloads Server Functions
#'
#' @noRd
mod_info_downloads_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    # observers ----
    shiny::observe({
      shiny::req(selected_data())

      # Activate buttons only when data is available
      shinyjs::enable("download_results_xlsx")
      shinyjs::enable("download_results_json")
      shinyjs::enable("download_report_parameters_html")
      shinyjs::enable("download_report_outputs_html")
    }) |>
      shiny::bindEvent(selected_data())

    # prepare data ----

    # reshape parquet input to the form expected by download functions
    reshaped_data <- shiny::reactive({
      shiny::req(selected_data())
      mod_info_downloads_reformat_all_results(selected_data())
    })

    filename_stub <- shiny::reactive({
      p <- reshaped_data()$params
      create_datetime <- stringr::str_replace(p$create_datetime, "_", "-")
      paste(p$dataset, p$scenario, create_datetime, sep = "-") |> tolower()
    })

    # download buttons ----

    # results

    output$download_results_xlsx <- shiny::downloadHandler(
      filename = \() paste0(filename_stub(), "_results.xlsx"),
      content = mod_info_downloads_download_excel(reshaped_data)
    )

    output$download_results_json <- shiny::downloadHandler(
      filename = \() paste0(filename_stub(), "_results.json"),
      content = mod_info_downloads_download_json(reshaped_data)
    )

    # params report (extract A)

    output$download_report_parameters_html <- shiny::downloadHandler(
      filename = \() {
        paste0(filename_stub(), "_report-parameters_extract-a.html")
      },
      content = mod_info_downloads_download_report_html(
        selected_data,
        selected_site,
        report_type = "parameters"
      )
    )

    # outputs summary report (extract B)

    output$download_report_outputs_html <- shiny::downloadHandler(
      filename = \() paste0(filename_stub(), "_report-outputs_extract-b.html"),
      content = mod_info_downloads_download_report_html(
        selected_data,
        selected_site,
        report_type = "outputs"
      )
    )
  })
}
