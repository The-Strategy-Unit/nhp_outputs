run_model <- function(params) {
  api_uri <- Sys.getenv("NHP_RUN_MODEL_API_URI")

  req <- httr::POST(api_uri, body = params, encode="json")

  httr::status_code(req)
}