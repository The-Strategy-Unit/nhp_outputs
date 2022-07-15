
cosmos_get_container <- function(container) {
  endp <- AzureCosmosR::cosmos_endpoint(
    Sys.getenv("COSMOS_ENDPOINT"),
    Sys.getenv("COSMOS_KEY")
  )

  db <- AzureCosmosR::get_cosmos_database(endp, Sys.getenv("COSMOS_DB"))

  AzureCosmosR::get_cosmos_container(db, container)
}

cosmos_get_user_allowed_datasets <- function(user) {
  # TODO: this should be grabbed from cosmos
  if (is.null(user)) {
    "synthetic"
  } else {
    c(
      "synthetic",
      "RL4", "RXC", "RN5", "RYJ", "RGP", "RNQ", "RD8", "RBZ", "RX1", "RHW", "RA9", "RGR", "RXN_RTX", "RH5_RBA"
    )
  }
}

cosmos_get_result_sets <- function() {
  container <- cosmos_get_container("results")

  qry <- "SELECT c.dataset, c.scenario, c.create_datetime, c.id FROM c"
  AzureCosmosR::query_documents(container, qry) |>
    dplyr::arrange(dplyr::across(tidyselect::everything()))
}

cosmos_get_available_aggregations <- function(id) {
  container <- cosmos_get_container("results")

  qry <- "SELECT c.available_aggregations FROM c"
  AzureCosmosR::query_documents(container, qry, partition_key = id, as_data_frame = FALSE) |>
    purrr::pluck(1, "data", "available_aggregations")
}

cosmos_get_model_run_years <- function(id) {
  container <- cosmos_get_container("results")

  qry <- "SELECT c.start_year, c.end_year FROM c"
  AzureCosmosR::query_documents(
    container, qry,
    partition_key = id,
    as_data_frame = FALSE,
    metadata = FALSE
  )[[1]]$data
}

cosmos_get_principal_high_level <- function(id) {
  container <- cosmos_get_container("results")

  qry <- paste(
    "SELECT r.pod, r.baseline, r.principal",
    "FROM c JOIN r in c.results['default']",
    "WHERE r.measure NOT IN ('beddays', 'tele_attendances')"
  )

  AzureCosmosR::query_documents(container, qry, partition_key = id) |>
    dplyr::mutate(
      dplyr::across(.data$pod, ~ ifelse(stringr::str_starts(.x, "aae"), "aae", .x))
    ) |>
    dplyr::group_by(.data$pod) |>
    dplyr::summarise(dplyr::across(where(is.numeric), sum))
}

cosmos_get_model_core_activity <- function(id) {
  container <- cosmos_get_container("results")

  qry <- "
    SELECT
      r.pod,
      r.measure,
      r.baseline,
      r.median,
      r.lwr_ci,
      r.upr_ci
    FROM c
    JOIN r IN c.results[\"default\"]
  "

  AzureCosmosR::query_documents(container, qry, partition_key = id)
}

cosmos_get_model_run_distribution <- function(id, pod, measure) {
  stopifnot(
    "invalid characters in pod" = stringr::str_remove_all(pod, "[\\w-]") == "",
    "invalid characters in measure" = stringr::str_remove_all(measure, "[\\w-]") == ""
  )

  container <- cosmos_get_container("results")

  variants <- AzureCosmosR::query_documents(
    container,
    "SELECT c.selected_variants FROM c",
    partition_key = id,
    as_data_frame = FALSE,
    metadata = FALSE
  ) |>
    purrr::pluck(1, "data", "selected_variants") |>
    utils::tail(-1) |>
    tibble::enframe("model_run", "variant")

  qry <- glue::glue("
    SELECT
        r.baseline,
        r.model_runs
    FROM c
    JOIN r IN c.results[\"default\"]
    WHERE
        r.pod = '{pod}'
    AND
        r.measure = '{measure}'
  ")

  AzureCosmosR::query_documents(container, qry, partition_key = id) |>
    dplyr::as_tibble() |>
    dplyr::mutate(
      dplyr::across(
        .data$model_runs,
        purrr::map,
        tibble::enframe,
        name = "model_run"
      )
    ) |>
    tidyr::unnest(.data$model_runs) |>
    dplyr::inner_join(variants, by = "model_run")
}

cosmos_get_aggregation <- function(id, pod, measure, agg_col) {
  stopifnot(
    "invalid characters in pod" = stringr::str_remove_all(pod, "[\\w-]") == "",
    "invalid characters in measure" = stringr::str_remove_all(measure, "[\\w-]") == "",
    "invalid characters in agg_col" = stringr::str_remove_all(agg_col, "[\\w-]") == ""
  )

  container <- cosmos_get_container("results")

  agg_type <- glue::glue("sex+{agg_col}") # nolint
  qry <- glue::glue("
    SELECT
      r.sex,
      r.{agg_col},
      r.baseline,
      r.principal,
      r.median,
      r.lwr_ci,
      r.upr_ci
    FROM c
    JOIN r in c.results[\"{agg_type}\"]
    WHERE
      r.pod = '{pod}'
    AND
      r.measure = '{measure}'
  ")
  AzureCosmosR::query_documents(container, qry, partition_key = id)
}

cosmos_get_principal_change_factors <- function(id, activity_type) {
  stopifnot(
    "Invalid activity_type" = activity_type %in% c("aae", "ip", "op")
  )

  container <- cosmos_get_container("change_factors")

  qry <- glue::glue("
    SELECT
      r.measure,
      s.change_factor,
      s.strategy,
      s.baseline ?? s[\"value\"][0] \"value\"
    FROM c
    JOIN r IN c.{activity_type}
    JOIN s IN r.change_factors
  ")

  d <- AzureCosmosR::query_documents(container, qry, partition_key = id) |>
    dplyr::as_tibble()

  if (!"strategy" %in% colnames(d)) {
    d$strategy <- "-"
  }

  dplyr::mutate(d, dplyr::across(.data$strategy, tidyr::replace_na, "-"))
}

cosmos_get_bed_occupancy <- function(id) {
  container <- cosmos_get_container("results")

  qry <- "
    SELECT
        r.measure,
        r.ward_group,
        r.baseline,
        r.principal,
        r.median,
        r.lwr_ci,
        r.upr_ci
    FROM c
    JOIN r IN c.results[\"bed_occupancy\"]
  "

  AzureCosmosR::query_documents(container, qry, partition_key = id)
}

cosmos_get_full_model_run_data <- function(id) {
  purrr::set_names(c("results", "change_factors")) |>
    purrr::map(cosmos_get_container) |>
    purrr::map(AzureCosmosR::get_document, partition_key = id, id = id, metadata = FALSE) |>
    purrr::map("data")
}
