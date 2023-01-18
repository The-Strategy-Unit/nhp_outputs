library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_token_fn
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_token_fn calls get_managed_token if env var isn't set", {
  m1 <- mock("get_managed_token")
  m2 <- mock("get_azure_token")

  stub(batch_token_fn, "AzureAuth::get_managed_token", m1)
  stub(batch_token_fn, "AzureAuth::get_azure_token", m2)

  withr::local_envvar(c(
    AAD_TENANT_ID = "",
    AAD_APP_ID = "",
    AAD_APP_SECRET = ""
  ))

  expect_equal(batch_token_fn("resource"), "get_managed_token")
  expect_called(m1, 1)
  expect_called(m2, 0)
  expect_args(m1, 1, "resource")
})

test_that("batch_token_fn calls get_azure_token if env var is set", {
  m1 <- mock("get_managed_token")
  m2 <- mock("get_azure_token")

  stub(batch_token_fn, "AzureAuth::get_managed_token", m1)
  stub(batch_token_fn, "AzureAuth::get_azure_token", m2)

  withr::local_envvar(c(
    AAD_TENANT_ID = "tenant",
    AAD_APP_ID = "app",
    AAD_APP_SECRET = "secret"
  ))

  expect_equal(batch_token_fn("resource"), "get_azure_token")
  expect_called(m1, 0)
  expect_called(m2, 1)
  expect_args(m2, 1, "resource", "tenant", "app", "secret")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_get_pools
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_get_pools gets a token", {
  m <- mock()

  stub(batch_get_pools, "batch_token_fn", m)

  stub(batch_get_pools, "AzureAuth::extract_jwt", "token")

  stub(batch_get_pools, "httr::GET", "get response")
  stub(batch_get_pools, "httr::add_headers", "headers")
  stub(batch_get_pools, "httr::content", list(value = NULL))

  batch_get_pools()

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_get_pools calls the correct API", {
  m <- mock()

  stub(batch_get_pools, "batch_token_fn", "token")
  stub(batch_get_pools, "AzureAuth::extract_jwt", identity)

  stub(batch_get_pools, "httr::GET", m)
  stub(batch_get_pools, "httr::add_headers", list)
  stub(batch_get_pools, "httr::content", list(value = NULL))

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_get_pools()

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = "pools",
    query = list("api-version" = "2022-01-01.15.0"),
    list(
      "Authorization" = "Bearer token"
    )
  )
})

test_that("batch_get_pools returns the expected data", {
  stub(batch_get_pools, "batch_token_fn", "token")
  stub(batch_get_pools, "AzureAuth::extract_jwt", identity)

  stub(batch_get_pools, "httr::GET", "get response")
  stub(batch_get_pools, "httr::add_headers", "headers")
  stub(batch_get_pools, "httr::content", list(
    value = list(
      list(
        id = 0,
        state = 1,
        thing = 2,
        vmSize = 3,
        ignore = 4,
        currentDedicatedNodes = 5,
        currentLowPriorityNodes = 6,
        targetDedicatedNodes = 7,
        targetLowPriorityNodes = 8
      ),
      list(
        id = 8,
        state = 7,
        thing = 6,
        vmSize = 5,
        ignore = 4,
        currentDedicatedNodes = 3,
        currentLowPriorityNodes = 2,
        targetDedicatedNodes = 1,
        targetLowPriorityNodes = 0
      )
    )
  ))

  withr::local_envvar(c("BATCH_URL" = "url"))
  actual <- batch_get_pools()
  expected <- tibble::tribble(
    ~id,
    ~state,
    ~thing,
    ~vmSize,
    ~currentDedicatedNodes,
    ~currentLowPriorityNodes,
    ~targetDedicatedNodes,
    ~targetLowPriorityNodes,
    0, 1, 2, 3, 5, 6, 7, 8,
    8, 7, 6, 5, 3, 2, 1, 0
  )

  expect_equal(actual, expected)
})

test_that("batch_get_pools returns NULL if no data returned", {
  stub(batch_get_pools, "batch_token_fn", "token")
  stub(batch_get_pools, "AzureAuth::extract_jwt", identity)

  stub(batch_get_pools, "httr::GET", "get response")
  stub(batch_get_pools, "httr::add_headers", "headers")
  stub(batch_get_pools, "httr::content", list(value = NULL))

  expect_null(batch_get_pools())
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_get_jobs
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_get_jobs gets a token", {
  m <- mock()

  stub(batch_get_jobs, "batch_token_fn", m)

  stub(batch_get_jobs, "AzureAuth::extract_jwt", "token")

  stub(batch_get_jobs, "httr::GET", "get response")
  stub(batch_get_jobs, "httr::add_headers", "headers")
  stub(batch_get_jobs, "httr::content", list(value = NULL))

  batch_get_jobs()

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_get_jobs calls the correct API", {
  m <- mock()

  stub(batch_get_jobs, "batch_token_fn", "token")
  stub(batch_get_jobs, "AzureAuth::extract_jwt", identity)

  stub(batch_get_jobs, "httr::GET", m)
  stub(batch_get_jobs, "httr::add_headers", list)
  stub(batch_get_jobs, "httr::content", list(value = NULL))

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_get_jobs()

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = "jobs",
    query = list("api-version" = "2022-01-01.15.0"),
    list(
      "Authorization" = "Bearer token"
    )
  )
})

test_that("batch_get_jobs returns the expected data", {
  stub(batch_get_jobs, "batch_token_fn", "token")
  stub(batch_get_jobs, "AzureAuth::extract_jwt", identity)

  stub(batch_get_jobs, "httr::GET", "get response")
  stub(batch_get_jobs, "httr::add_headers", "headers")
  stub(batch_get_jobs, "httr::content", list(
    value = list(
      list(
        id = 0,
        creationTime = "2022-01-01 01:23:45",
        state = 2,
        executionInfo.startTime = "2022-01-01 11:22:33",
        executionInfo.endTime = "2022-02-02 22:33:11",
        executionInfo.x = 5
      ),
      list(
        id = 5,
        creationTime = "2022-01-01 10:32:54",
        state = 3,
        executionInfo.startTime = "2022-03-03 11:33:22",
        executionInfo.x = 0
      )
    )
  ))

  withr::local_envvar(c("BATCH_URL" = "url"))
  actual <- batch_get_jobs()
  d <- lubridate::as_datetime
  expected <- tibble::tribble(
    ~id,
    ~creationTime,
    ~state,
    ~startTime,
    ~endTime,
    0, d("2022-01-01 01:23:45"), 2, d("2022-01-01 11:22:33"), d("2022-02-02 22:33:11"),
    5, d("2022-01-01 10:32:54"), 3, d("2022-03-03 11:33:22"), NA
  )

  expect_equal(actual, expected)
})

test_that("batch_get_jobs returns NULL if no data returned", {
  stub(batch_get_jobs, "batch_token_fn", "token")
  stub(batch_get_jobs, "AzureAuth::extract_jwt", identity)

  stub(batch_get_jobs, "httr::GET", "get response")
  stub(batch_get_jobs, "httr::add_headers", "headers")
  stub(batch_get_jobs, "httr::content", list(value = NULL))

  expect_null(batch_get_jobs())
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_get_tasks
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_get_tasks gets a token", {
  m <- mock()

  stub(batch_get_tasks, "batch_token_fn", m)

  stub(batch_get_tasks, "AzureAuth::extract_jwt", "token")

  stub(batch_get_tasks, "httr::GET", "get response")
  stub(batch_get_tasks, "httr::add_headers", "headers")
  stub(batch_get_tasks, "httr::content", list(value = NULL))

  batch_get_tasks("id")

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_get_tasks calls the correct API", {
  m <- mock()

  stub(batch_get_tasks, "batch_token_fn", "token")
  stub(batch_get_tasks, "AzureAuth::extract_jwt", identity)

  stub(batch_get_tasks, "httr::GET", m)
  stub(batch_get_tasks, "httr::add_headers", list)
  stub(batch_get_tasks, "httr::content", list(value = NULL))

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_get_tasks("id")

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = c("jobs", "id", "tasks"),
    query = list("api-version" = "2022-01-01.15.0"),
    list(
      "Authorization" = "Bearer token"
    )
  )
})

test_that("batch_get_tasks returns the expected data", {
  stub(batch_get_tasks, "batch_token_fn", "token")
  stub(batch_get_tasks, "AzureAuth::extract_jwt", identity)

  stub(batch_get_tasks, "httr::GET", "get response")
  stub(batch_get_tasks, "httr::add_headers", "headers")
  stub(batch_get_tasks, "httr::content", list(
    value = list(
      list(
        id = 0,
        displayName = 1,
        state = 2,
        creationTime = "2022-01-01 01:23:45",
        executionInfo.startTime = "2022-01-01 11:22:33",
        executionInfo.endTime = "2022-02-02 22:33:11",
        executionInfo.result = "success",
        executionInfo.exitCode = 3,
        executionInfo.x = 4
      ),
      list(
        id = 4,
        displayName = 3,
        state = 2,
        creationTime = "2022-01-01 10:32:54",
        executionInfo.startTime = "2022-03-03 11:33:22",
        executionInfo.result = "failure",
        executionInfo.exitCode = 1,
        executionInfo.x = 0
      )
    )
  ))

  withr::local_envvar(c("BATCH_URL" = "url"))
  actual <- batch_get_tasks("id")
  d <- lubridate::as_datetime
  expected <- tibble::tribble(
    ~id,
    ~displayName,
    ~state,
    ~creationTime,
    ~startTime,
    ~endTime,
    ~result,
    ~exitCode,
    0, 1, 2, d("2022-01-01 01:23:45"), d("2022-01-01 11:22:33"), d("2022-02-02 22:33:11"), "success", 3,
    4, 3, 2, d("2022-01-01 10:32:54"), d("2022-03-03 11:33:22"), NA, "failure", 1
  )

  expect_equal(actual, expected)
})

test_that("batch_get_tasks returns NULL if no data returned", {
  stub(batch_get_tasks, "batch_token_fn", "token")
  stub(batch_get_tasks, "AzureAuth::extract_jwt", identity)

  stub(batch_get_tasks, "httr::GET", "get response")
  stub(batch_get_tasks, "httr::add_headers", "headers")
  stub(batch_get_tasks, "httr::content", list(value = NULL))

  expect_null(batch_get_tasks("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_delete_job
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_delete_job gets a token", {
  m <- mock()

  stub(batch_delete_job, "batch_token_fn", m)

  stub(batch_delete_job, "AzureAuth::extract_jwt", "token")

  stub(batch_delete_job, "httr::DELETE", "delete")
  stub(batch_delete_job, "httr::add_headers", "headers")

  batch_delete_job("id")

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_delete_job calls the correct API", {
  m <- mock()

  stub(batch_delete_job, "batch_token_fn", "token")
  stub(batch_delete_job, "AzureAuth::extract_jwt", identity)

  stub(batch_delete_job, "httr::DELETE", m)
  stub(batch_delete_job, "httr::add_headers", list)

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_delete_job("id")

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = c("jobs", "id"),
    query = list("api-version" = "2022-01-01.15.0"),
    list(
      "Authorization" = "Bearer token"
    )
  )
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_job_status
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_job_status calls batch_get_tasks", {
  m <- mock(tibble::tibble())

  stub(batch_job_status, "batch_get_tasks", m)

  batch_job_status("id")

  expect_called(m, 1)
  expect_args(m, 1, "id")
})

test_that("batch_job_status returns running when the job is still running", {
  m <- mock(tibble::tibble(), tibble::tibble(result = c("running", "success")))

  stub(batch_job_status, "batch_get_tasks", m)

  expect_equal(batch_job_status("id"), "running")
  expect_equal(batch_job_status("id"), "running")
})

test_that("batch_job_status returns failure when a task has failed", {
  m <- mock(tibble::tibble(result = c("running", "success", "failure")))

  stub(batch_job_status, "batch_get_tasks", m)

  expect_equal(batch_job_status("id"), "failure")
})

test_that("batch_job_status returns success when all tasks have successfully completed", {
  m <- mock(tibble::tibble(result = c("success", "success")))

  stub(batch_job_status, "batch_get_tasks", m)

  expect_equal(batch_job_status("id"), "success")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_create_job
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_create_job gets a token", {
  m <- mock()

  stub(batch_create_job, "batch_token_fn", m)

  stub(batch_create_job, "AzureAuth::extract_jwt", "token")

  stub(batch_create_job, "httr::POST", "post")
  stub(batch_create_job, "httr::add_headers", "headers")

  batch_create_job("job name")

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_create_job calls the correct API", {
  m <- mock()

  stub(batch_create_job, "batch_token_fn", "token")
  stub(batch_create_job, "AzureAuth::extract_jwt", identity)

  stub(batch_create_job, "httr::POST", m)
  stub(batch_create_job, "httr::add_headers", list)

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_create_job("job name")

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = c("jobs"),
    body = list(
      id = "job name",
      poolInfo = list(poolId = "nhp-model"),
      onAllTasksComplete = "terminatejob",
      usesTaskDependencies = TRUE
    ),
    query = list("api-version" = "2022-01-01.15.0"),
    encode = "json",
    list(
      "Authorization" = "Bearer token",
      "Content-Type" = "application/json;odata=minimalmetadata"
    )
  )
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_add_tasks_to_job
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_add_tasks_to_job gets a token", {
  m <- mock()

  stub(batch_add_tasks_to_job, "batch_token_fn", m)

  stub(batch_add_tasks_to_job, "AzureAuth::extract_jwt", "token")

  stub(batch_add_tasks_to_job, "httr::POST", "post")
  stub(batch_add_tasks_to_job, "httr::add_headers", "headers")

  batch_add_tasks_to_job("job name")

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_add_tasks_to_job calls the correct API", {
  m <- mock()

  stub(batch_add_tasks_to_job, "batch_token_fn", "token")
  stub(batch_add_tasks_to_job, "AzureAuth::extract_jwt", identity)

  stub(batch_add_tasks_to_job, "httr::POST", m)
  stub(batch_add_tasks_to_job, "httr::add_headers", list)

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_add_tasks_to_job("job name", "tasks")

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = c("jobs", "job name", "addtaskcollection"),
    body = "tasks",
    query = list("api-version" = "2022-01-01.15.0"),
    encode = "json",
    list(
      "Authorization" = "Bearer token",
      "Content-Type" = "application/json;odata=minimalmetadata"
    )
  )
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_upload_params_to_queue
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_upload_params_to_queue gets a token", {
  m <- mock()

  stub(batch_upload_params_to_queue, "batch_token_fn", m)
  stub(batch_upload_params_to_queue, "AzureStor::storage_container", "container")
  stub(batch_upload_params_to_queue, "AzureAuth::extract_jwt", "token")
  stub(batch_upload_params_to_queue, "jsonlite::write_json", "write json")
  stub(batch_upload_params_to_queue, "AzureStor::upload_blob", "upload blob")

  batch_upload_params_to_queue("filename.json", "params")

  expect_called(m, 1)
  expect_args(m, 1, "https://storage.azure.com/")
})

test_that("batch_upload_params_to_queue connects to the right container", {
  m <- mock()

  stub(batch_upload_params_to_queue, "batch_token_fn", "token")
  stub(batch_upload_params_to_queue, "AzureStor::storage_container", m)
  stub(batch_upload_params_to_queue, "AzureAuth::extract_jwt", "token")
  stub(batch_upload_params_to_queue, "jsonlite::write_json", "write json")
  stub(batch_upload_params_to_queue, "AzureStor::upload_blob", "upload blob")

  withr::local_envvar(c("STORAGE_URL" = "url"))
  batch_upload_params_to_queue("filename.json", "params")

  expect_called(m, 1)
  expect_args(m, 1, "url/queue", token = "token")
})

test_that("batch_upload_params_to_queue writes the params to disk", {
  m <- mock()

  stub(batch_upload_params_to_queue, "batch_token_fn", "token")
  stub(batch_upload_params_to_queue, "AzureStor::storage_container", "container")
  stub(batch_upload_params_to_queue, "AzureAuth::extract_jwt", "token")
  stub(batch_upload_params_to_queue, "jsonlite::write_json", m)
  stub(batch_upload_params_to_queue, "AzureStor::upload_blob", "upload blob")

  withr::local_envvar(c("STORAGE_URL" = "url"))
  batch_upload_params_to_queue("filename.json", "params")

  expect_called(m, 1)
  expect_args(m, 1, "params", "filename.json", auto_unbox = TRUE, pretty = TRUE)
})

test_that("batch_upload_params_to_queue uploads the params to storage", {
  m <- mock()

  stub(batch_upload_params_to_queue, "batch_token_fn", "token")
  stub(batch_upload_params_to_queue, "AzureStor::storage_container", "container")
  stub(batch_upload_params_to_queue, "AzureAuth::extract_jwt", "token")
  stub(batch_upload_params_to_queue, "jsonlite::write_json", "write json")
  stub(batch_upload_params_to_queue, "AzureStor::upload_blob", m)

  withr::local_envvar(c("STORAGE_URL" = "url"))
  batch_upload_params_to_queue("filename.json", "params")

  expect_called(m, 1)
  expect_args(m, 1, "container", "filename.json")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_submit_model_run
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_submit_model_run calls the other functions (prod)", {
  withr::local_envvar("GOLEM_CONFIG_ACTIVE" = "prod")
  m <- mock()

  expected_cdt <- as.POSIXct("2022-01-01 01:23:45", tz = "UTC")

  stub(batch_submit_model_run, "Sys.time", expected_cdt)
  stub(batch_submit_model_run, "uuid::UUIDgenerate", "uuid")

  stub(batch_submit_model_run, "batch_upload_params_to_queue", m)
  stub(batch_submit_model_run, "batch_create_job", m)
  stub(batch_submit_model_run, "batch_add_tasks_to_job", m)

  withr::local_envvar(c(
    "MODEL_RUNS_PER_TASK" = 16,
    "COSMOS_ENDPOINT" = "cosmos endpoint",
    "COSMOS_KEY" = "cosmos key",
    "COSMOS_DB" = "cosmos db",
    "STORAGE_URL" = "storage",
    "BATCH_LOGS_CONTAINER_SAS" = "sas_token",
    "NHP_APP_VERSION" = "1.0",
    "NHP_DATA_VERSION" = "0.1"
  ))

  params <- list(
    dataset = "synthetic",
    scenario = "test",
    model_runs = 64
  )

  expected_job_name <- "synthetic__test__20220101_012345"
  expected_filename <- paste0(expected_job_name, ".json")

  expect_equal(batch_submit_model_run(params), expected_job_name)

  params$create_datetime <- "20220101_012345"
  expect_called(m, 3)
  expect_args(m, 1, expected_filename, params)
  expect_args(m, 2, expected_job_name)

  # Begin Exclude Linting
  expected_all_tasks <- list(
    list(
      id = "run_01-16",
      displayName = "Model Run [1 to 16]",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/1.0/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/results/1.0 --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=1 --model-runs=16",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/run_01-16"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      )
    ),
    list(
      id = "run_17-32",
      displayName = "Model Run [17 to 32]",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/1.0/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/results/1.0 --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=17 --model-runs=16",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/run_17-32"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      )
    ),
    list(
      id = "run_33-48",
      displayName = "Model Run [33 to 48]",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/1.0/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/results/1.0 --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=33 --model-runs=16",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/run_33-48"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      )
    ),
    list(
      id = "run_49-64",
      displayName = "Model Run [49 to 64]",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/1.0/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/results/1.0 --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=49 --model-runs=16",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/run_49-64"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      )
    ),
    list(
      id = "upload_to_cosmos",
      displayName = "Run Principal + Upload to Cosmos",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/1.0/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/results/1.0 --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=-1 --model-runs=2 --run-postruns",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/upload_to_cosmos"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      ),
      environmentSettings = list(
        list(name = "COSMOS_ENDPOINT", value = "cosmos endpoint"),
        list(name = "COSMOS_KEY", value = "cosmos key"),
        list(name = "COSMOS_DB", value = "cosmos db")
      ),
      dependsOn = list(
        taskIds = c("run_01-16", "run_17-32", "run_33-48", "run_49-64")
      )
    ),
    list(
      id = "clean_queue",
      displayName = "Clean up queue",
      commandLine = "rm -rf /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/clean_queue"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      ),
      dependsOn = list(
        taskIds = c("run_01-16", "run_17-32", "run_33-48", "run_49-64", "upload_to_cosmos")
      )
    )
  )
  # End Exclude Linting

  expect_args(m, 3, expected_job_name, list(value = expected_all_tasks))
})


test_that("batch_submit_model_run calls the other functions (dev)", {
  withr::local_envvar("GOLEM_CONFIG_ACTIVE" = "dev")
  m <- mock()

  expected_cdt <- as.POSIXct("2022-01-01 01:23:45", tz = "UTC")

  stub(batch_submit_model_run, "Sys.time", expected_cdt)
  stub(batch_submit_model_run, "uuid::UUIDgenerate", "uuid")

  stub(batch_submit_model_run, "batch_upload_params_to_queue", m)
  stub(batch_submit_model_run, "batch_create_job", m)
  stub(batch_submit_model_run, "batch_add_tasks_to_job", m)

  withr::local_envvar(c(
    "MODEL_RUNS_PER_TASK" = 16,
    "COSMOS_ENDPOINT" = "cosmos endpoint",
    "COSMOS_KEY" = "cosmos key",
    "COSMOS_DB" = "cosmos db",
    "STORAGE_URL" = "storage",
    "BATCH_LOGS_CONTAINER_SAS" = "sas_token",
    "NHP_DATA_VERSION" = "0.1"
  ))

  params <- list(
    dataset = "synthetic",
    scenario = "test",
    model_runs = 64
  )

  expected_job_name <- "synthetic__test__20220101_012345"
  expected_filename <- paste0(expected_job_name, ".json")

  expect_equal(batch_submit_model_run(params), expected_job_name)

  params$create_datetime <- "20220101_012345"
  expect_called(m, 3)
  expect_args(m, 1, expected_filename, params)
  expect_args(m, 2, expected_job_name)

  # Begin Exclude Linting
  expected_all_tasks <- list(
    list(
      id = "run_01-16",
      displayName = "Model Run [1 to 16]",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/dev/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/batch/uuid --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=1 --model-runs=16",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/run_01-16"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      )
    ),
    list(
      id = "run_17-32",
      displayName = "Model Run [17 to 32]",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/dev/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/batch/uuid --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=17 --model-runs=16",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/run_17-32"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      )
    ),
    list(
      id = "run_33-48",
      displayName = "Model Run [33 to 48]",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/dev/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/batch/uuid --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=33 --model-runs=16",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/run_33-48"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      )
    ),
    list(
      id = "run_49-64",
      displayName = "Model Run [49 to 64]",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/dev/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/batch/uuid --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=49 --model-runs=16",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/run_49-64"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      )
    ),
    list(
      id = "upload_to_cosmos",
      displayName = "Run Principal + Upload to Cosmos",
      commandLine = "/opt/nhp/bin/python /mnt/batch/tasks/fsmounts/app/dev/run_model.py /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json --data-path=/mnt/batch/tasks/fsmounts/data/0.1 --results-path=/mnt/batch/tasks/fsmounts/batch/uuid --temp-results-path=/mnt/batch/tasks/fsmounts/batch/uuid --save-type=cosmos --run-start=-1 --model-runs=2 --run-postruns",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/upload_to_cosmos"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      ),
      environmentSettings = list(
        list(name = "COSMOS_ENDPOINT", value = "cosmos endpoint"),
        list(name = "COSMOS_KEY", value = "cosmos key"),
        list(name = "COSMOS_DB", value = "cosmos db")
      ),
      dependsOn = list(
        taskIds = c("run_01-16", "run_17-32", "run_33-48", "run_49-64")
      )
    ),
    list(
      id = "clean_queue",
      displayName = "Clean up queue",
      commandLine = "rm -rf /mnt/batch/tasks/fsmounts/queue/synthetic__test__20220101_012345.json",
      userIdentity = list(
        autoUser = list(scope = "pool", elevationLevel = "admin")
      ),
      outputFiles = list(
        list(
          destination = list(
            container = list(
              containerUrl = "storage/batch-logs?sas_token",
              path = "synthetic__test__20220101_012345/clean_queue"
            )
          ),
          filePattern = "../std*.txt",
          uploadOptions = list(
            uploadCondition = "taskfailure"
          )
        )
      ),
      dependsOn = list(
        taskIds = c("run_01-16", "run_17-32", "run_33-48", "run_49-64", "upload_to_cosmos")
      )
    )
  )
  # End Exclude Linting

  expect_args(m, 3, expected_job_name, list(value = expected_all_tasks))
})
