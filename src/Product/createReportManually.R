if (!interactive()) {
    suppressPackageStartupMessages(library(reticulate))
    use_condaenv(condaenv = "xai", required = TRUE)
    source_python("report.py")

    # create a date object with 2024-03-14
    date <- as.Date("2024-03-20")
    create_report(date)
    print("Report created successfully!")
}