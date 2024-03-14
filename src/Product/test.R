if (!interactive()) {
    suppressPackageStartupMessages(library(reticulate))
    use_condaenv(condaenv = "xai", required = TRUE)
    source_python("report.py")
    # get sisytem date without time
    date <- format(Sys.time(), "%Y-%m-%d")
    create(date)
    write(date)
}