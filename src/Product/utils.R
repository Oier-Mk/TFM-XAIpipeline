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