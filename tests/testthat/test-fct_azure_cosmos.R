library(shiny)
library(mockery)

test_that("cosmos_get_container creates a reference to a container", {
  withr::local_envvar(c("COSMOS_ENDPOINT" = "ep", "COSMOS_KEY" = "key", "COSMOS_DB" = "db"))

  m <- mock("endpoint", "database", "container")

  stub(cosmos_get_container, "AzureCosmosR::cosmos_endpoint", m)
  stub(cosmos_get_container, "AzureCosmosR::get_cosmos_database", m)
  stub(cosmos_get_container, "AzureCosmosR::get_cosmos_container", m)

  expect_equal(cosmos_get_container("my_container"), "container")
  expect_called(m, 3)
  expect_args(m, 1, "ep", "key")
  expect_args(m, 2, "endpoint", "db")
  expect_args(m, 3, "database", "my_container")
})

test_that("cosmos_get_result_sets gets the list of model runs", {
  m_cont <- mock("container")
  m <- mock(tibble::tribble(
    ~dataset, ~scenario, ~create_datetime, ~id,
    "a", "2", "1", "a__2__1",
    "b", "2", "2", "b__2__2",
    "a", "1", "2", "a__1__2"
  ))
  stub(cosmos_get_result_sets, "cosmos_get_container", m_cont)
  stub(cosmos_get_result_sets, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_result_sets("dev"), tibble::tribble(
    ~dataset, ~scenario, ~create_datetime, ~id,
    "a", "1", "2", "a__1__2",
    "a", "2", "1", "a__2__1",
    "b", "2", "2", "b__2__2"
  ))

  qry <- "SELECT c.dataset, c.scenario, c.create_datetime, c.id FROM c WHERE c.app_version = 'dev'"
  expect_called(m, 1)
  expect_args(m, 1, "container", qry)

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_available_aggregations gets the list of available aggregations", {
  m_cont <- mock("container")
  m <- mock(list(list(data = list(available_aggregations = c("a", "b")))))
  stub(cosmos_get_available_aggregations, "cosmos_get_container", m_cont)
  stub(cosmos_get_available_aggregations, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_available_aggregations("id"), c("a", "b"))
  qry <- "SELECT c.available_aggregations FROM c"
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id", as_data_frame = FALSE)

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_model_run_years gets the model run years", {
  m_cont <- mock("container")
  m <- mock(list(list(data = list(start_year = 1, end_year = 2))))
  stub(cosmos_get_model_run_years, "cosmos_get_container", m_cont)
  stub(cosmos_get_model_run_years, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_model_run_years("id"), list(start_year = 1, end_year = 2))
  qry <- "SELECT c.start_year, c.end_year FROM c"
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id", as_data_frame = FALSE, metadata = FALSE)

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_principal_high_level gets the results", {
  m_cont <- mock("container")
  m <- mock(tibble::tribble(
    ~pod, ~baseline, ~principal,
    "aae_1", 1, 2,
    "aae_2", 2, 4,
    "ip_1", 5, 6,
    "ip_2", 7, 8
  ))
  stub(cosmos_get_principal_high_level, "cosmos_get_container", m_cont)
  stub(cosmos_get_principal_high_level, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_principal_high_level("id"), tibble::tribble(
    ~pod, ~baseline, ~principal,
    "aae", 3, 6,
    "ip_1", 5, 6,
    "ip_2", 7, 8
  ))
  qry <- paste(
    "SELECT r.pod, r.baseline, r.principal",
    "FROM c JOIN r in c.results['default']",
    "WHERE r.measure NOT IN ('beddays', 'procedures', 'tele_attendances')"
  )
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_model_core_activity gets the results", {
  m_cont <- mock("container")
  m <- mock("data")
  stub(cosmos_get_model_core_activity, "cosmos_get_container", m_cont)
  stub(cosmos_get_model_core_activity, "AzureCosmosR::query_documents", m)

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

  expect_equal(cosmos_get_model_core_activity("id"), "data")
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_variants gets the results", {
  m_cont <- mock("container")
  m <- mock(
    list(list(data = list(selected_variants = c("x", "a", "a", "b"))))
  )

  stub(cosmos_get_variants, "cosmos_get_container", m_cont)
  stub(cosmos_get_variants, "AzureCosmosR::query_documents", m)

  expect_equal(
    cosmos_get_variants("id"),
    tibble::tibble(model_run = 1:3, variant = c("a", "a", "b"))
  )

  expect_called(m_cont, 1)
  expect_called(m, 1)
  expect_args(
    m,
    1,
    "container",
    "SELECT c.selected_variants FROM c",
    partition_key = "id",
    as_data_frame = FALSE,
    metadata = FALSE
  )
})

test_that("cosmos_get_model_run_distribution gets the results", {
  m_cont <- mock("container")
  m <- mock(
    tibble::tribble(
      ~baseline, ~model_runs,
      100, c(100, 200, 300)
    )
  )
  stub(cosmos_get_model_run_distribution, "cosmos_get_container", m_cont)
  stub(cosmos_get_model_run_distribution, "AzureCosmosR::query_documents", m)
  stub(
    cosmos_get_model_run_distribution,
    "cosmos_get_variants",
    tibble::tibble(model_run = 1:3, variant = c("a", "a", "b"))
  )

  expect_equal(cosmos_get_model_run_distribution("id", "pod", "measure"), tibble::tribble(
    ~baseline, ~model_run, ~value, ~variant,
    100, 1, 100, "a",
    100, 2, 200, "a",
    100, 3, 300, "b"
  ))

  qry <- glue::glue("
    SELECT
        r.baseline,
        r.model_runs
    FROM c
    JOIN r IN c.results[\"default\"]
    WHERE
        r.pod = 'pod'
    AND
        r.measure = 'measure'
  ")
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_model_run_distribution validates the pod argument", {
  expect_error(
    cosmos_get_model_run_distribution("id", "invalid+pod", "measure"),
    "invalid characters in pod"
  )
})

test_that("cosmos_get_model_run_distribution validates the measure argument", {
  expect_error(
    cosmos_get_model_run_distribution("id", "pod", "invalid+measure"),
    "invalid characters in measure"
  )
})

test_that("cosmos_get_aggregation gets the results", {
  m_cont <- mock("container")
  m <- mock("data")
  stub(cosmos_get_aggregation, "cosmos_get_container", m_cont)
  stub(cosmos_get_aggregation, "AzureCosmosR::query_documents", m)

  expect_equal(cosmos_get_aggregation("id", "pod", "measure", "agg_col"), "data")
  qry <- glue::glue("
    SELECT
      r.sex,
      r.agg_col,
      r.baseline,
      r.principal,
      r.median,
      r.lwr_ci,
      r.upr_ci
    FROM c
    JOIN r in c.results[\"sex+agg_col\"]
    WHERE
      r.pod = 'pod'
    AND
      r.measure = 'measure'
  ")
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_aggregation validates the pod argument", {
  expect_error(
    cosmos_get_aggregation("id", "invalid+pod", "measure", "agg_col"),
    "invalid characters in pod"
  )
})

test_that("cosmos_get_aggregation validates the measure argument", {
  expect_error(
    cosmos_get_aggregation("id", "pod", "invalid+measure", "agg_col"),
    "invalid characters in measure"
  )
})

test_that("cosmos_get_aggregation validates the agg_col argument", {
  expect_error(
    cosmos_get_aggregation("id", "pod", "measure", "invalid+agg_col"),
    "invalid characters in agg_col"
  )
})

test_that("cosmos_get_principal_change_factors gets the results", {
  m_cont <- mock("container")
  m <- mock(tibble::tibble(strategy = c("a", "b", NA)))
  stub(cosmos_get_principal_change_factors, "cosmos_get_container", m_cont)
  stub(cosmos_get_principal_change_factors, "AzureCosmosR::query_documents", m)

  expect_equal(
    cosmos_get_principal_change_factors("id", "aae"),
    tibble::tibble(strategy = c("a", "b", "-"))
  )
  qry <- glue::glue("
    SELECT
      r.measure,
      s.change_factor,
      s.strategy,
      s.baseline ?? s[\"value\"][0] \"value\"
    FROM c
    JOIN r IN c.aae
    JOIN s IN r.change_factors
  ")
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "change_factors")
})

test_that("cosmos_get_principal_change_factors validates the arguments", {
  m <- mock(tibble::tibble(strategy = c("a", "b", NA)), cycle = TRUE)
  stub(cosmos_get_principal_change_factors, "cosmos_get_container", NULL)
  stub(cosmos_get_principal_change_factors, "AzureCosmosR::query_documents", m)

  cosmos_get_principal_change_factors("id", "aae")
  cosmos_get_principal_change_factors("id", "ip")
  cosmos_get_principal_change_factors("id", "op")

  expect_error(cosmos_get_principal_change_factors("id", "x"), "Invalid activity_type")
  expect_called(m, 3)
})

test_that("cosmos_get_principal_change_factors adds the strategy column if it doesn't exist", {
  m <- mock(tibble::tibble(x = 1), cycle = TRUE)
  stub(cosmos_get_principal_change_factors, "cosmos_get_container", NULL)
  stub(cosmos_get_principal_change_factors, "AzureCosmosR::query_documents", m)

  actual <- cosmos_get_principal_change_factors("id", "aae")

  expect_equal(actual$strategy, "-")
})

test_that("cosmos_get_bed_occupancy gets the results", {
  m_cont <- mock("container")
  m <- mock(
    tibble::tribble(
      ~baseline, ~principal, ~model_runs,
      10, 20, c(30, 40, 50)
    )
  )
  stub(cosmos_get_bed_occupancy, "cosmos_get_container", m_cont)
  stub(cosmos_get_bed_occupancy, "AzureCosmosR::query_documents", m)
  stub(
    cosmos_get_bed_occupancy,
    "cosmos_get_variants",
    tibble::tibble(model_run = 1:3, variant = c("a", "a", "b"))
  )

  expect_equal(
    cosmos_get_bed_occupancy("id"),
    tibble::tribble(
      ~baseline, ~principal, ~model_run, ~value, ~variant,
      10, 20, 1, 30, "a",
      10, 20, 2, 40, "a",
      10, 20, 3, 50, "b"
    )
  )
  qry <- "
    SELECT
        r.measure,
        r.ward_group,
        r.baseline,
        r.principal,
        r.median,
        r.lwr_ci,
        r.upr_ci,
        r.model_runs
    FROM c
    JOIN r IN c.results[\"bed_occupancy\"]
  "
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})

test_that("cosmos_get_full_model_run_data returns the correct data", {
  m <- mock("results", "change_factors", list(data = "a"), list(data = "b"))
  stub(cosmos_get_full_model_run_data, "cosmos_get_container", m)
  stub(cosmos_get_full_model_run_data, "AzureCosmosR::get_document", m)

  expect_equal(cosmos_get_full_model_run_data("id"), list(results = "a", change_factors = "b"))
  expect_called(m, 4)
  expect_args(m, 1, "results")
  expect_args(m, 2, "change_factors")
  expect_args(m, 3, "results", partition_key = "id", id = "id", metadata = FALSE)
  expect_args(m, 4, "change_factors", partition_key = "id", id = "id", metadata = FALSE)
})

test_that("cosmos_get_theatres_available gets the results", {
  m_cont <- mock("container")
  m <- mock(
    tibble::tribble(
      ~measure, ~value,
      "a", 1,
      "b", 2
    )
  )
  stub(cosmos_get_theatres_available, "cosmos_get_container", m_cont)
  stub(cosmos_get_theatres_available, "AzureCosmosR::query_documents", m)

  actual <- cosmos_get_theatres_available("id")

  expect_equal(actual$a, tibble::tibble(value = 1))
  expect_equal(actual$b, tibble::tibble(value = 2))

  qry <- "
    SELECT
        r.measure,
        r.tretspef,
        r.baseline,
        r.principal,
        r.median,
        r.lwr_ci,
        r.upr_ci,
        r.model_runs
    FROM c
    JOIN r in c.results.theatres_available
  "
  expect_called(m, 1)
  expect_args(m, 1, "container", qry, partition_key = "id")

  expect_called(m_cont, 1)
  expect_args(m_cont, 1, "results")
})
