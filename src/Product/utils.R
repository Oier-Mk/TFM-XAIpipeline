
### Utils.R

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

### Log.R

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

### Warnings.R

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

### report.R

read_log <- function(date) {
  # Load required packages
  library(jsonlite)

  # Convert date to string in 'YYYY-MM-DD' format
  date <- format(date, "%Y-%m-%d")

  # Read JSON file
  file_path <- paste0('log/log_', date, '.json')
  data <- fromJSON(file_path)

  # get the percentage of approved credits
  n_inferences <- length(data$output)
  approved  <- sum(data$output == 2)
  percentage <- as.integer(approved / n_inferences * 100)

  print(paste("Total inferences:", n_inferences))
  print(paste("Percentage of approved credits:", percentage, "%"))

  return(list(inferences = data, n_inferences = n_inferences, percentage = percentage))
}

gender_credits <- function(data) {
  # Extract Gender information from data
  genders <- sapply(data$input, function(sublist) sublist$Gender)
  outputs <- unlist(data$output)

  # Get the corresponding outputs for "male" and "female"
  male_amounts <- unlist(outputs[genders == "male"])
  female_amounts <- unlist(outputs[genders == "female"])

  # Count the occurrences of each amount for males and females
  male_counts <- table(male_amounts)
  female_counts <- table(female_amounts)

  # Calculate the total number of males and females
  total_male <- sum(male_counts)
  total_female <- sum(female_counts)

  # Calculate the values porcentually


  # Set up the plot
  png("gender.png", width=800, height=400)  # Adjust width and height as needed
  par(mfrow=c(1, 2), mar=c(1, 1, 3, 3))  # Set up the layout and margins

  # Plot for males
  pie(male_counts, main="Male", col=c("#9966ff", "#99ccff"), labels=c("Denied", "Accepted"))
  legend("topright", legend = c("Denied", "Accepted"), fill = c("#9966ff", "#99ccff"))
  text(x=0, y=-0.9, labels=paste("Total Males:", total_male), cex=0.8)

  # Plot for females
  pie(female_counts, main="Female", col=c("#ff6666", "#ff99cc"), labels=c("Denied", "Accepted"))
  legend("topright", legend = c("Denied", "Accepted"), fill = c("#ff6666", "#ff99cc"))
  text(x=0, y=-0.9, labels=paste("Total Females:", total_female), cex=0.8)

  # Save the plot
  dev.off()
}

gender_credits <- function(data) {
  # Extract Gender information from data
  genders <- sapply(data$input, function(sublist) sublist$Gender)
  outputs <- unlist(data$output)

  # Get the corresponding outputs for "male" and "female"
  male_amounts <- unlist(outputs[genders == "male"])
  female_amounts <- unlist(outputs[genders == "female"])

  # Count the occurrences of each amount for males and females
  male_counts <- table(male_amounts)
  female_counts <- table(female_amounts)

  # Calculate the total number of males and females
  total_male <- sum(male_counts)
  total_female <- sum(female_counts)

  # Calculate the values proportionally
  male_percentages <- prop.table(male_counts) * 100
  female_percentages <- prop.table(female_counts) * 100

  # Set up the plot
  png("tex/media/gender.png", width=800, height=400)  # Adjust width and height as needed
  par(mfrow=c(1, 2), mar=c(1, 1, 3, 3))  # Set up the layout and margins

  # Plot for males
  pie(male_counts, main="Male", col=c("#9966ff", "#99ccff"), labels=c("Denied", "Accepted"))
  legend("topright", legend = c("Denied", "Accepted"), fill = c("#9966ff", "#99ccff"))
  text(x=0, y=-0.9, labels=paste("Total Males:", total_male, "(", round(male_percentages[1], 2), "% Denied, ", round(male_percentages[2], 2), "% Accepted)"), cex=0.8)

  # Plot for females
  pie(female_counts, main="Female", col=c("#ff6666", "#ff99cc"), labels=c("Denied", "Accepted"))

  # Add rectangle to indicate protected attribute
  rect(xleft = -3.5, xright = 3.5, ybottom = -3.5, ytop = 3.5, col = rgb(0, 1, 0, 0.1), border = NA)

  legend("topright", legend = c("Denied", "Approved", "Protected Attribute"), fill = c("#ff6666", "#99ff99", rgb(0, 1, 0, 0.2)), title = "Legend")
  text(x=0, y=-0.9, labels=paste("Total Females:", total_female, "(", round(female_percentages[1], 2), "% Denied, ", round(female_percentages[2], 2), "% Accepted)"), cex=0.8)

  # Save the plot
  dev.off()
}

foreign_credits <- function(data) {
  # Extract marital status and outputs from data
  categories <- sapply(data$input, function(sublist) sublist$`Foreign.worker`)
  outputs <- unlist(data$output)

  # Replace '/' with newline character
  categories <- gsub("/", "\n", categories)

  # Create a data frame with categories and outputs
  data_df <- data.frame(Category = categories, Output = outputs)

  # Count occurrences of each output value for each category
  count_data <- table(data_df$Category, data_df$Output)

  # Transpose the data for plotting
  count_data <- t(count_data)

  # Calculate row sums (totals) for percentages
  row_sums <- apply(count_data, 1, sum)

  # Calculate percentages
  count_data_percent <- prop.table(count_data, margin = 1) * 100

  png("tex/media/foreign.png", width=400, height=400)  # Adjust width and height as needed
  # Plot the barplot
  barplot(as.matrix(count_data_percent), beside = TRUE,
          col = c("#ff6666", "#99ff99"),
          main = "Percentage of outputs by category",
          xlab = "Category", ylab = "Percentage",
          legend = c("Denied", "Approved"))

  # Add rectangle to indicate protected attribute
  rect(xleft = 8.75 , xright = 3.75, ybottom = -5, ytop = 100, col = rgb(0, 1, 0, 0.2), border = NA)

  # Add protected attribute to legend
  legend("topright", legend = c("Denied", "Approved", "Protected Attribute"), fill = c("#ff6666", "#99ff99", rgb(0, 1, 0, 0.2)), title = "Legend")

  dev.off()
}

marital_credits <- function(data) {
  # Extract marital status and outputs from data
  categories <- sapply(data$input, function(sublist) sublist$`Marital.Status`)
  outputs <- unlist(data$output)

  # Replace '/' with newline character
  categories <- gsub("/", "\n", categories)

  # Create a data frame with categories and outputs
  data_df <- data.frame(Category = categories, Output = outputs)

  # Count occurrences of each output value for each category
  count_data <- table(data_df$Category, data_df$Output)

  # Transpose the data for plotting
  count_data <- t(count_data)

  # Calculate column-wise percentages
  col_percentages <- prop.table(count_data, margin = 2) * 100

  png("tex/media/marital.png", width=600, height=400)  # Adjust width and height as needed
  par(mar=c(5, 4, 4, 6))  # Adjust the margin to accommodate the legend

  # Plot the barplot with percentages
  barplot(as.matrix(col_percentages), beside = TRUE,
          col = c("#ff6666", "#99ff99"),
          main = "Percentage of outputs by marital status",
          xlab = "Marital Status", ylab = "Percentage",
          legend = c("Denied", "Approved"))

  # Add rectangles to indicate protected attribute
  rect(xleft = 0, xright = 3.5, ybottom = 0, ytop = 100, col = rgb(0, 1, 0, 0.2), border = NA)
  rect(xleft = 6.5, xright = 10, ybottom = 0, ytop = 100, col = rgb(0, 1, 0, 0.2), border = NA)

  # Add protected attribute to legend
  legend("topright", legend = c("Denied", "Approved", "Protected Attribute"), fill = c("#ff6666", "#99ff99", rgb(0, 1, 0, 0.2)), title = "Legend")

  dev.off()
}

job_credits <- function(data) {
  # Extract job categories and outputs from data
  categories <- sapply(data$input, function(sublist) sublist$Job)
  outputs <- unlist(data$output)

  # Replace spaces with newline character
  categories <- gsub(" ", "\n", categories)

  # Create a data frame with categories and outputs
  data_df <- data.frame(Category = categories, Output = outputs)

  # Count occurrences of each output value for each category
  count_data <- table(data_df$Category, data_df$Output)

  # Transpose the data for plotting
  count_data <- t(count_data)

  # Calculate row-wise percentages
  row_percentages <- prop.table(count_data, margin = 1) * 100

  png("tex/media/jobs.png", width=600, height=400)  # Adjust width and height as needed
  par(mar=c(5, 4, 4, 6))  # Adjust the margin to accommodate the legend

  # Plot the barplot with percentages
  barplot(as.matrix(row_percentages), beside = TRUE,
          col = c("#ff6666", "#99ff99"),
          main = "Percentage of outputs by job category",
          xlab = "Job Category", ylab = "Percentage")

  # Add rectangles to indicate protected attribute
  rect(xleft = 6.5, xright = 9.5, ybottom = 0, ytop = 100, col = rgb(0, 1, 0, 0.2), border = NA)
  rect(xleft = 9.5, xright = 15, ybottom = 0, ytop = 100, col = rgb(0, 1, 0, 0.2), border = NA)

  # Add protected attribute to legend in a margin
  legend("topright", legend = c("Denied", "Approved", "Protected Attribute"), fill = c("#ff6666", "#99ff99", rgb(0, 1, 0, 0.2)), title = "Legend", xpd = TRUE)

  dev.off()
}

credit_inference <- function(data) {
  dates <- unlist(data$time)
  outputs <- as.numeric(unlist(data$output))

  # Replace ' ' with newline character in dates
  dates <- gsub(" ", "\n", dates)

  # Define colors based on output values
  colors <- ifelse(outputs == 1, "#ff6666", "#99ff99")

  # Create the bar chart
  png("tex/media/sequence.png", width=800, height=400)
  barplot(outputs, names.arg=dates, col=colors,
          xlab='Time', ylab='Denied or Approved',
          main='Inferences over time')

  # Update legend
  legend("topright", legend=c("Denied", "Approved"), fill=c("#ff6666", "#99ff99"))

  dev.off()
}


create_latex_document <- function(date, n_inferences, percentage) {
  # Open the file for writing  
  date <- format(date, "%Y-%m-%d")
  file_conn <- file(paste0('tex/', date, '.tex'), "w", encoding = "UTF-8")

    tex <- paste0("
\\documentclass{article}
\\usepackage[utf8]{inputenc}
\\usepackage{graphicx}
\\usepackage{geometry}
\\usepackage{multicol}


% Ajustar los márgenes para que todo quepa en una página
\\geometry{
    a4paper,
    total={170mm,257mm},
    left=20mm,
    top=10mm,
}

\\begin{document}


\\begin{flushright} % Alinea el logo a la derecha
    \\includegraphics[width=1.5cm]{tex/media/logo.png} 
\\end{flushright}

\\centering
{\\Huge \\textbf{Informe}}

\\vspace{0.5cm}

{\\Large Autogenerado por XaiCreditCopilot}

\\vspace{0.5cm}

{\\large \\today}

\\raggedright

El presente informe ha sido autogenerado con el propósito de cumplir con el plan de seguimiento posterior del proyecto. Toda la información contenida en este documento se proporciona únicamente como un hecho informativo para evaluar el funcionamiento adecuado del sistema.

\\begin{multicols}{2}

En el presente documento se muestran estadísticas creadas por el sistema durante el último mes. Podemos apreciar cómo se han realizado {\\huge ", n_inferences, " inferencias} con el sistema y se han generado conclusiones relevantes sobre el proceso de otorgamiento de créditos. Los siguientes gráficos representan la distribución de la aceptación y denegación de crédito en función de variables protegidas, como género, nacionalidad, tipo de trabajo y estado civil. Estos análisis son cruciales para identificar posibles sesgos en el proceso de toma de decisiones y garantizar la equidad en el acceso al crédito.

\\vspace{0.5cm}
\\textbf{Análisis por género:}

En primer lugar, podemos apreciar dos gráficos de tarta que representan la distribución de créditos aceptados y denegados según el género de los solicitantes. Estos gráficos proporcionan una visión clara de la proporción de créditos otorgados y rechazados para mujeres y hombres. Además, se muestra el total de créditos solicitados por cada género, lo que permite una comparación directa entre la cantidad de créditos solicitados por mujeres y hombres.

\\begin{center} % Alinea el logo a la derecha
    \\includegraphics[width=8cm]{tex/media/gender.png} 
\\end{center}

Después de un análisis exhaustivo de los registros, la aplicación ha concluido que es pertinente {\\huge otorgar un ", percentage, "\\%} de los créditos evaluados durante este período.

\\vspace{0.5cm}
\\textbf{Análisis por extranjería:}

Uno de los aspectos clave que se analizan en este estudio es el estatus de extranjería del solicitante. Este factor desempeña un papel fundamental en el proceso de evaluación de créditos, ya que puede influir en la decisión final sobre la aprobación o denegación del crédito. A continuación, se presentan los hallazgos relacionados con la distribución de créditos en función del estatus de extranjería de los solicitantes.


\\begin{center} % Alinea el logo a la derecha
    \\includegraphics[width=8cm]{tex/media/foreign.png} 
\\end{center}

\\vspace{0.5cm}
\\textbf{Análisis por tipo de empleo:}

Otro aspecto relevante que se considera en este análisis es el puesto de trabajo del solicitante. Este factor se examina con detenimiento para evitar sesgos por nivel educativo en el conjunto de datos. Dado que el tipo de trabajo puede estar correlacionado con el nivel de ingresos y estabilidad laboral, comprender su distribución en relación con la aprobación o denegación de créditos es esencial para garantizar la equidad en el proceso de evaluación. A continuación, se presentan los resultados relacionados con la distribución de créditos según el puesto de trabajo de los solicitantes.


\\begin{center} % Alinea el logo a la derecha
    \\includegraphics[width=8cm]{tex/media/jobs.png} 
\\end{center}

\\vspace{0.5cm}
\\textbf{Análisis por estadi civil:}

Otro aspecto relevante bajo estudio es el estado civil del solicitante. Reconociendo que el estado civil, como estar casado, puede conferir ciertos privilegios en algunas circunstancias, es esencial examinar su impacto en el proceso de evaluación de créditos. 

\\begin{center} % Alinea el logo a la derecha
    \\includegraphics[width=8cm]{tex/media/marital.png} 
\\end{center}

Es fundamental comprender cómo se distribuyen los créditos según diversos atributos protegidos de los solicitantes para identificar posibles sesgos y garantizar la imparcialidad en el proceso de otorgamiento.

\\end{multicols}

A continuación, se presenta una gráfica que ilustra la evolución temporal de las inferencias, reflejando la cantidad de créditos otorgados en distintos períodos.

\\begin{center} % Alinea el logo a la derecha
    \\includegraphics[width=16cm]{tex/media/sequence.png} 
\\end{center}

En conclusión, revisar periódicamente el informe es crucial para asegurar que el modelo de inferencia opere de manera adecuada y sin sesgos en relación a los distintos atributos a lo largo del tiempo. Esta práctica no solo garantiza la precisión y fiabilidad de las decisiones tomadas por el sistema, sino que también promueve la equidad y transparencia en el proceso de evaluación de créditos.


Con aprecio y dedicación,

XaiCreditCopilot

\\begin{center}
    \\textbf{Con aprecio y dedicación,}\\
    \\vspace{0.5cm}
    \\textsc{XaiCreditCopilot}\\
    \\vspace{0.2cm}
\\end{center}

{\\small
Gracias por confiar en nuestro sistema para el análisis y evaluación de créditos. Estamos comprometidos a seguir mejorando y garantizar la equidad y precisión en cada decisión. No dudes en contactarnos si alguno de los parámetros difiere de un rango normal.
}

\\end{document}
")

    
  # Write LaTeX content to file
  cat(tex, file = file_conn)

  # Close the file connection
  close(file_conn)
}
compile_latex_to_pdf <- function(date) {
  # Format date
  date <- format(date, "%Y-%m-%d")

  # Run pdflatex to compile the document
  log_file <- file("tex/latex.log", "w")
  cmd <-paste0("pdflatex -output-directory=pdf -interaction=nonstopmode tex/", date, ".tex")
  system(cmd)
  close(log_file)
}
create_report <- function(date) {
  # Read log data
  read_data <- read_log(date)
  gender_credits(read_data$inferences)
  foreign_credits(read_data$inferences)
  marital_credits(read_data$inferences)
  job_credits(read_data$inferences)
  credit_inference(read_data$inferences)
  create_latex_document(date, read_data$n_inferences, read_data$percentage)
  compile_latex_to_pdf(date)
}

if (!interactive()) {
    suppressPackageStartupMessages(library(reticulate))
    # create a date object with 2024-03-14
    date <- as.Date("2024-03-24")
    create_report(date)
    print("Report created successfully!")
}