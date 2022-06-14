#' get_data_cache
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd

get_data_cache <- function() {
  env <- rlang::global_env()

  dci <- "__data_cache_instance__"
  # if the data cache instance doesn't exist, create it
  if (!exists(dci, envir = env)) {
    if (Sys.getenv("GOLEM_CONFIG_ACTIVE") == "dev") {
      dc <- cachem::cache_mem()
    } else {
      if (!dir.exists(".cache")) {
        dir.create(".cache")
      }
      # create a 200 MiB cache on disk
      dc <- cachem::cache_disk(dir = ".cache/data_cache", max_size = 200 * 1024^2)

      # in case we need to invalidate the cache on rsconnect quickly, we can increment the "CACHE_VERSION" env var
      cache_version <- ifelse(
        file.exists(".cache/cache_version.txt"),
        as.numeric(readLines(".cache/cache_version.txt")),
        -1
      )

      if (Sys.getenv("CACHE_VERSION", 0) > cache_version) {
        cat("Invalidating cache\n")
        dc$reset()
        cache_version <- Sys.getenv("CACHE_VERSION", 0)
        writeLines(as.character(cache_version), ".cache/cache_version.txt")
      }
    }

    assign(dci, dc, envir = env)
  }

  # retrieve the data cache
  get(dci, envir = env)
}
