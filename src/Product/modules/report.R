
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