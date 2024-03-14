# Function to detect consecutive identical outputs in the log
# 
# Args:
#   None
# 
# Returns:
#   None
# 
detect_consecutive <- function(log_file) {
  # Read the log file
  log_data <- jsonlite::fromJSON(log_file, simplifyVector = TRUE)
  
  # Extract the classes from the last 3 entries
  last_classes <- unlist(tail(log_data, 10)$output)
  
  # Check if the last 3 inferences are the same class (denials)
  if (length(unique(last_classes)) == 1) {
    warning("Last credit requests have been the same answer recently.")
  }
}

# Function to calculate statistics about the credit decisions
# 
# Args:
#   None
# 
# Returns:
#   A list containing the mean time, mean days, mean months, mean year, proportion of approved credits, and proportion of denied credits
# 
credit_statistics <- function(log_file) {
    log_data <- fromJSON(log_file, simplifyVector = TRUE)
    # Convert time strings to POSIXct objects
    times <- as.POSIXct(unlist(log_data$time), format = "%Y-%m-%d %H:%M:%S")
    
    # Extract date components
    days <- as.numeric(format(times, "%d"))
    months <- as.numeric(format(times, "%m"))
    year <- as.numeric(format(times, "%Y"))

    times <- as.POSIXct(unlist(log_data$time), format = "%Y-%m-%d %H:%M:%S")
    
    # Extract time components
    hours <- as.numeric(format(times, "%H"))
    minutes <- as.numeric(format(times, "%M"))
    seconds <- as.numeric(format(times, "%S"))

    # Calculate mean time of day
    mean_hours <- mean(hours, na.rm = TRUE)
    mean_minutes <- mean(minutes, na.rm = TRUE)
    mean_seconds <- mean(seconds, na.rm = TRUE)

    # Combine mean time components into a string
    mean_time <- sprintf("%02d:%02d:%02d", as.integer(mean_hours), as.integer(mean_minutes), as.integer(mean_seconds))

    mean_days <- mean(days, na.rm = TRUE)
    mean_months <- mean(months, na.rm = TRUE)
    mean_year <- mean(year, na.rm = TRUE)
    prop_approved <- sum(log_data$output == "2") / nrow(log_data)
    prop_denied <- sum(log_data$output == "1") / nrow(log_data)

    statistics <- list(mean_time = mean_time,
                        mean_days = mean_days,  
                        mean_months = mean_months,
                        mean_year = mean_year,
                        prop_approved = prop_approved,
                        prop_denied = prop_denied)
    statistics
}

# Function to plot the outputs of credit transactions
# 
# Args:
#   log_file: Path to the log file containing the credit transactions
#   output_file: Path to save the plot image file
# 
# Returns:
#   None
# 
plot_credit_outputs <- function(log_file) {
    # Leer el archivo JSON
    log_data <- fromJSON(log_file, simplifyVector = TRUE)
    
    # Extraer los tiempos y los outputs
    times <- unlist(log_data$time)
    outputs <- unlist(log_data$output)
    
    # Crear un dataframe con los datos
    data <- data.frame(time = as.POSIXct(times, format = "%Y-%m-%d %H:%M:%S"), output = as.integer(outputs))
    
    # Crear el gráfico de barras
    p <- ggplot(data, aes(x = 1:nrow(data), y = output, fill = factor(output))) +
         geom_bar(stat = "identity") +
         labs(x = "Transaction", y = "Class Level") +
         theme_minimal() 
    
    # Guardar el gráfico como una foto
    ggsave('statistics.png', plot = p, device = "png")
}