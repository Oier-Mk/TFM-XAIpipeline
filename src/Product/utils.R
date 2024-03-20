# Function to perform a grid search on a CBA classifier
# 
# Args:
#   support_values: Vector of values for the support of association rules
#   confidence_values: Vector of values for the confidence of association rules
#   train: Training dataset
#   test: Test dataset
#   y_test: Vector of class labels for the test dataset
# 
# Returns:
#   Vector of 3 elements containing the best support, confidence, and accuracy found during the grid search.
#   The first element is the best support value, the second element is the best confidence value, and the third element is the accuracy associated with these values.
# 
grid_search <- function(train, test, y_test, support_values, confidence_values, train_weights = NULL, test_weights = NULL) {
  # Inicializar variables para almacenar los mejores parámetros y precisión
  best_params <- list()
  all_results <- data.frame() # Crear un dataframe vacío para almacenar todos los resultados
  
  # Búsqueda en cuadrícula para cada valor de soporte
  for (support in support_values) {
    # Búsqueda en cuadrícula para cada valor de confianza
    for (confidence in confidence_values) {

      print(paste("Support:", support, "Confidence:", confidence))

      # Convertir el conjunto de datos de entrenamiento en transacciones
      trans_train <- as(train, "transactions")
      trans_test <- as(test, "transactions")
      
      # Crear la base de reglas con CARs (Classification Association Rules)
      cars <- mineCARs(Class ~ ., trans_train, parameter = list(support = support, confidence = confidence))
      
      # Eliminar reglas redundantes
      cars <- cars[!is.redundant(cars)]
      
      # Ordenar las reglas por confianza
      cars <- sort(cars, by = "conf")
      
      # Ajustar el modelo con las reglas
      classifier <- CBA_ruleset(Class ~ .,
                                 rules = cars,
                                 default = uncoveredMajorityClass(Class ~ ., trans_train, cars),
                                 method = "majority")
      
      # Calcular la precisión del modelo en el conjunto de test
      predictions_test <- predict(classifier, trans_test)
      accuracy_test <- sum(predictions_test == y_test) / length(predictions_test)
      
      # Calcular la precisión del modelo en el conjunto de entrenamiento
      predictions_train <- predict(classifier, trans_train)
      accuracy_train <- sum(predictions_train == train$Class) / length(predictions_train)

      # Verificar si hay reglas antes de crear el dataframe result
      if (length(cars) > 0){
        result <- data.frame(Support = support,
                            Confidence = confidence,
                            Accuracy_train = accuracy_train,
                            Accuracy_test = accuracy_test,
                            NumberOfRules = length(cars))
        all_results <- rbind(all_results, result)
      }
      
      # Almacenar los mejores parámetros y precisión
      if (is.null(best_params$accuracy) || accuracy_test > best_params$accuracy) {
        best_params$support <- support
        best_params$confidence <- confidence
        best_params$accuracy <- accuracy_test
      }
    }
  }
  
  # Guardar todos los resultados en un archivo CSV
  write.csv(all_results, file = "grid_search_results.csv", row.names = FALSE)
  
  # Devolver los mejores parámetros y precisión encontrados
  best_params
}
# # Example values for the grid search
# support_values <- seq(0.01, 0.1, by = 0.01)
# confidence_values <- seq(0.01, 0.1, by = 0.01)

# Function to extract and preprocess rules from a classifier object and test dataset
# 
# Args:
#   classifier: The classifier object containing association rules
#   test: The test dataset used for extracting column values
# 
# Returns:
#   A dataframe containing preprocessed association rules
# 
extract_rules <- function(classifier) {

  colnames <- c("Status.of.existing.checking.account",
          "Duration.in.month",
          "Credit.history",
          "Purpose",
          "Credit.amount",
          "Savings.account.bonds",
          "Present.employment.since",
          "Installment.rate.in.percentage.of.disposable.income",
          "Other.debtors...guarantors",
          "Present.residence.since",
          "Property",
          "Age.in.years",
          "Other.installment.plans",
          "Housing",
          "Number.of.existing.credits.at.this.bank",
          "Job",
          "Number.of.people.being.liable.to.provide.maintenance.for",
          "Telephone",
          "Foreign.worker",
          "Gender",
          "Marital.Status")

  # Convert classifier rules to a dataframe
  rules <- DATAFRAME(classifier$rules)
  
  # Create new columns in rules dataframe with NA values
  for (colname in colnames) {
    rules[[colname]] <- NA
  }
  
  # Extract values for each column from the LHS of rules
  for (colname in colnames) {
    rules[[colname]] <- ifelse(grepl(colname, rules$LHS), gsub(paste(".*",colname,"=([^,}]*).*",sep = ""), "\\1", rules$LHS), rules[[colname]])
  }
  
  # Extract the target variable values from the RHS of rules
  rules$Class <- ifelse(grepl("Class", rules$RHS), gsub(".*Class=([^,}]*).*", "\\1", rules$RHS), rules$Class)
  
  # Remove LHS and RHS columns
  rules$LHS <- NULL
  rules$RHS <- NULL
  
  rules
}
# Function to filter rules based on a given statement
# 
# Args:
#   classifier: The model
#   statement: Statement to filter rules by
# 
# Returns:
#   Subset of rules dataframe that satisfies the given statement
# 
get_used_rules <- function(classifier, statement) {
  rules <- extract_rules(classifier)
  # Create conditions for filtering rules based on the statement
  conditions <- lapply(colnames(statement), function(colname) {
    rules[[colname]] == statement[[colname]] | is.na(rules[[colname]])
  })
  
  # Combine conditions using logical AND
  conditions_combined <- Reduce(`&`, conditions)
  
  # Filter rules dataframe based on combined conditions
  rules %>% filter(!!conditions_combined)
}

# Function to compute confusion matrix
# 
# Args:
#   predictions: Predicted class labels
#   actual_labels: Actual class labels
# 
# Returns:
#   Confusion matrix
# 
confusion_matrix <- function(predictions, actual_labels) {
  # Create confusion matrix
  confusion_matrix <- table(predictions, actual_labels)
    # Print confusion matrix
  print("Confusion Matrix:")
  print(confusion_matrix)
  confusion_matrix
}


# Function to split data into training and testing sets while separating class labels and weights
# 
# Args:
#   data: The complete dataset
#   train_size: Proportion of the dataset to assign to the training set
# 
# Returns:
#   A list containing the training set, testing set, class labels of the testing set, and weights of the training set
# 
train_test_weights_split <- function(data, train_size) {
  # Convert all columns to factors
  data <- mutate_all(data, as.factor)
  
  # Create partition indices
  index <- createDataPartition(data$Class, p = train_size, list = FALSE)

  # Split the data
  train <- data[index, ]
  test <- data[-index, ]

  # Extract class labels from the test set
  y_test <- test$Class
  test$Class <- NULL

  # Extract weights from the training set
  train_weights <- train$Weights
  train$Weights <- NULL
  test$Weights <- NULL

  # Return a list containing the training set, testing set, class labels of the testing set, and weights of the training set
  list(train = train, test = test, y_test = y_test, weights = train_weights)
}


# Function to create a classification model using Classification Association Rules (CARs)
# 
# Args:
#   train: Training dataset
#   support_value: Minimum support threshold for CARs
#   confidence_value: Minimum confidence threshold for CARs
#   train_weights: Optional weights for transactions in the training dataset (default is NULL)
# 
# Returns:
#   A list containing the transactions and the rules generated from the training dataset
# 
create_model <- function(train, support_value, confidence_value, train_weights = NULL) {
  # Convert the training dataset into transactions
  trans <- as(train, "transactions")

  # Create rule base with Classification Association Rules (CARs)
  cars <- mineCARs(Class ~ ., trans, parameter = list(support = support_value, confidence = confidence_value))

  # Remove redundant rules
  cars <- cars[!is.redundant(cars)]

  # Sort the rules by confidence
  cars <- sort(cars, by = "conf")

  # Return a list containing the transactions and the rules generated from the training dataset
  list(transactions = trans, rules = cars)
}
# Function to log input, output, and rules into a JSON file
# 
# Args:
#   input: Input data or parameters
#   output: Output data or results
#   rules: Rules generated by the model
# 
# Returns:
#   None
# 
log <- function(input, output, rules) {
  # Get current date
  current_date <- as.Date(Sys.time())
  
  # Check if there are existing log files
  log_files <- list.files("log", pattern = "*.json", full.names = TRUE)
  
  if (length(log_files) > 0) {
    # Find the most recent log file
    most_recent_file <- log_files[which.max(file.mtime(log_files))]
    
    # Extract the date from the filename
    filename_date <- gsub("log_|\\.json", "", basename(most_recent_file))
    
    # Convert the filename date to Date object
    file_date <- as.Date(filename_date, format = "%Y-%m-%d")
    
    # Check if the most recent log file is less than 30 days old
    if (current_date - file_date <= 30) {
      log_file <- most_recent_file
    } else {
      # If more than 30 days have passed, create a new log file with the current date
      log_file <- paste("log/log_", format(Sys.time(), "%Y-%m-%d"), ".json", sep="")
      print('Realizar el informe del mes anterior')
      source("report.R")
      create_report(date)
    }
  } else {
    # If no existing log files, create a new log file with the current date
    log_file <- paste("log/log_", format(Sys.time(), "%Y-%m-%d"), ".json", sep="")
  }
  
  # Combine input, output, and rules into a list with current timestamp
  combined_list <- list(time = Sys.time(), input = input, output = output, rules = rules)
  
  # Convert the combined list to JSON format
  new_json_string <- toJSON(combined_list)
  
  # Write the JSON data to the log file
  if (file.exists(log_file)) {
    # Read existing JSON data
    existing_data <- paste(readLines(log_file), collapse = "")
    # Remove the closing bracket "]" if it exists
    if (endsWith(existing_data, "]")) {
      existing_data <- substr(existing_data, 1, nchar(existing_data) - 1)
    }
    # Append a comma before writing the new JSON data
    write(paste0(existing_data, ",", new_json_string, "]"), log_file)
    } else {
    # If the file does not exist, create a new file and write the JSON array
    write(paste0("[", new_json_string, "]"), log_file)
  }
  detect_consecutive(log_file)
}
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