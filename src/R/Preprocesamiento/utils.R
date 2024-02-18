
format_adapter <- function(data) {
    # Function: format_adapter
    # Description: Replaces commas with tildes (~) in all columns of the input dataframe.
    # Input:
    #   - data: The dataframe to be processed.
    # Output:
    #   - A modified dataframe where commas in all columns have been replaced with tildes (~).
  # Apply gsub to replace commas with tildes in all columns
  apply(data, 2, function(x) gsub(",", "~", x))
}
cut_numeric_columns <- function(data, num_bins) {
  # Function: cut_numeric_columns
  # Description: Converts numeric columns in a dataframe into categorical columns based on specified number of bins.
  # Input:
  #   - data: The dataframe containing numeric columns to be converted.
  #   - num_bins: The number of bins to use for converting numeric values into categories.
  # Output:
  #   - A modified dataframe where numeric columns have been replaced with categorical columns based on specified bins.
  
  # Filter only numeric columns excluding "pesos" and "class"
  numeric_columns <- data[sapply(data, is.numeric) & !names(data) %in% c("Weights", "Class")]
  
  # Calculate interval limits for each numeric column
  interval_limits <- lapply(numeric_columns, function(col) {
    quantiles <- quantile(col, probs = seq(0, 1, length.out = num_bins + 1), na.rm = TRUE)
    unique(quantiles)
  })
  
  # Adjust the first interval to be one less than the minimum value
  for (i in seq_along(interval_limits)) {
    interval_limits[[i]][1] <- min(numeric_columns[[i]]) - 1
  }

  # Apply cut function to all numeric columns
  cut_columns <- lapply(seq_along(numeric_columns), function(i) {
    cut(numeric_columns[[i]], breaks = interval_limits[[i]])
  })
  
  # Replace numeric columns with cut columns in the original data frame
  for (i in seq_along(numeric_columns)) {
    data[[names(numeric_columns)[i]]] <- cut_columns[[i]]
  }
  
  data
}
col_na_summary <- function(data) {
  # Function: col_na_summary
  # Description: Calculates the number of missing values (NA) in each column of the input dataframe.
  # Input:
  #   - data: The dataframe to be analyzed.
  # Output:
  #   - A dataframe summarizing the number of missing values (NA) in each column.
  
  # Use colSums and is.na to count NAs in each column
  na <- as.data.frame(colSums(is.na(data)))
  names(na) <- "NA_count"
  na
}
label_encoder <- function(data) {
  # Function: label_encoder_with_equivalents
  # Description: Performs label encoding for all non-numeric columns in the input dataframe
  #              and replaces the original values with the encoded values. It also prints
  #              a dataframe showing the equivalences between original values and encoded values.
  # Input:
  #   - data: The dataframe to be processed.
  # Output:
  #   - A modified dataframe with non-numeric columns encoded.
  #   - A dataframe showing the equivalences between original and encoded values.
  
  # Copiar el dataframe original
  encoded_data <- data
  
  # Iterar sobre las columnas del dataframe
  for (col in names(data)) {
    if (!is.numeric(data[[col]])) {
      # Realizar la codificación de la columna y sustituir los valores originales
      encoded_data[[col]] <- as.numeric(factor(data[[col]]))
      
      # Crear un dataframe de equivalencias para esta columna
      equivalencias <- data.frame(
        valor_original = levels(factor(data[[col]])),
        valor_codificado = as.numeric(factor(levels(factor(data[[col]]))))
      )
      
      # Imprimir el dataframe de equivalencias para esta columna
      cat("Equivalencias para la columna '", col, "':\n", sep = "")
      print(equivalencias)
      cat("\n")
    }
  }
  
  # Devolver el dataframe modificado
  encoded_data
}
one_hot_encoder <- function(data) {
  # Function: one_hot_encoder
  # Description: Performs one-hot encoding for all non-numeric columns in the input dataframe
  #              and replaces the original values with the encoded values. It removes the original
  #              columns and corrects the names of the new columns.
  # Input:
  #   - data: The dataframe to be processed.
  # Output:
  #   - A modified dataframe with one-hot encoded columns.
  
  # Copiar el dataframe original
  encoded_data <- data
  
  # Lista para almacenar las nuevas columnas
  new_columns <- list()
  
  # Iterar sobre las columnas del dataframe
  for (col in names(data)) {
    if (!is.numeric(data[[col]])) {
      # Realizar el one-hot encoding de la columna y sustituir los valores originales
      encoded_column <- model.matrix(~ data[[col]] - 1, data = data)
      # Corregir los nombres de las nuevas columnas
      colnames(encoded_column) <- gsub("^data\\[\\[col\\]\\]", col, colnames(encoded_column))
      # Eliminar la columna original
      encoded_data <- encoded_data[, !colnames(encoded_data) %in% col]
      # Agregar las nuevas columnas al dataframe
      encoded_data <- cbind(encoded_data, encoded_column)
      # Agregar las nuevas columnas a la lista
      new_columns <- c(new_columns, colnames(encoded_column))
    }
  }
  
  # Devolver el dataframe modificado y el nombre de las nuevas columnas
  encoded_data
}