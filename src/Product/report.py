import matplotlib.pyplot as plt
import subprocess
import pandas as pd
import json

def read_log(date):
    """
    Reads log data from a JSON file for a specific date.
    
    Args:
        date (datetime): The date for which log data is to be read.
        
    Returns:
        list: A list of lists containing log information for each inference.
        n_inferences (int): The number of inferences.
        percentage (int): The percentage of approved credits.

    """
    # Open the JSON file
    date = date.strftime("%Y-%m-%d")
    with open('log/log_' + date + '.json') as f:
        # Load the content of the file into a list of dictionaries
        data = json.load(f)

    inferences = []
    # Iterate over the elements of the list
    for inference in data:
        # Access the data of each person
        time = inference['time'][0]
        input_data = (inference['input'][0])
        output = inference['output'][0]
        rules = pd.DataFrame(inference['rules'])

        # print(time)
        # print(input)
        # print(output)
        # print(rules)

        inferences.append([time, input_data, output, rules])

    # get the percentage of approved credits
    n_inferences = len(inferences)
    approved = sum([1 for inference in inferences if inference[2] == '2'])
    percentage = int(approved / n_inferences * 100)

    return inferences, n_inferences, percentage


def gender_credits(data):
    """
    Visualizes gender-based credits data.
    
    Args:
        data (list): A list of lists containing log information.
    """
    # Extract Gender information from data
    genders = [inference[1]['Gender'] for inference in data]
    outputs = [inference[2] for inference in data]

    male = []
    female = []

    for i, value in enumerate(outputs):
        if genders[i] == "male":
            male.append(value)
        elif genders[i] == "female":
            female.append(value)

    # Plot pie charts
    fig, axs = plt.subplots(1, 2, figsize=(12, 6))

    # Pie chart for males
    axs[0].pie([male.count('2'), male.count('1')], labels=['Approved', 'Denied'], colors=['#99ccff', '#9966ff'], autopct='%1.1f%%', startangle=90)
    axs[0].set_title('Males')
    axs[0].axis('equal')
    axs[0].text(0, 0, str(len(male)) + ' hombres', ha='center', va='center', fontsize=12, color='black')
    axs[0].legend()

    # Pie chart for females
    axs[1].pie([female.count('2'), female.count('1')], labels=['Approved', 'Denied'], colors=['#ff99cc', '#ff6666'], autopct='%1.1f%%', startangle=90)
    axs[1].set_title('Females')
    axs[1].axis('equal')
    axs[1].text(0, 0, str(len(female)) + ' mujeres', ha='center', va='center', fontsize=12, color='black')
    axs[1].legend()

    # save the plot as a svg file   
    plt.savefig('tex/media/gender.png', bbox_inches='tight')


def foreign_credits(data):
    """
    Visualizes foreign worker credits data.
    
    Args:
        data (list): A list of lists containing log information.
    """
    foreign_status = [inference[1]['Foreign.worker'] for inference in data]
    outputs = [inference[2] for inference in data]

    counts_1 = []
    counts_2 = []

    for status in set(foreign_status):
        count_1 = 0
        count_2 = 0
        for i in range(len(foreign_status)):
            if foreign_status[i] == status:
                if outputs[i] == '1':
                    count_1 += 1
                elif outputs[i] == '2':
                    count_2 += 1
        counts_1.append(count_1)
        counts_2.append(count_2)

    # Etiquetas para las barras
    labels = list(set(foreign_status))

    # Posiciones de las barras
    x = range(len(labels))

    # Ancho de las barras
    width = 0.35

    # Colores personalizados
    color_denegado = '#ff6666'
    color_aceptado = '#99ff99'

    # Crear el gráfico de barras
    fig, ax = plt.subplots()
    ax.bar(x, counts_1, width, label='Denied', color=color_denegado)
    ax.bar([i + width for i in x], counts_2, width, label='Approved', color=color_aceptado)

    # Añadir etiquetas, título y leyenda
    ax.set_xlabel('Foreign Status')
    ax.set_ylabel('Count')
    ax.set_title('Approvals and denials by foreign status')
    ax.set_xticks([i + width / 2 for i in x])
    ax.set_xticklabels(labels, ha='center')
    ax.legend()

    # Mostrar el gráfico
    plt.tight_layout()
    plt.savefig('tex/media/foreign.png', bbox_inches='tight')



def marital_credits(data):
    """
    Visualizes marital status-based credits data.
    
    Args:
        data (list): A list of lists containing log information.
    """
    marital = [inference[1]['Marital.Status'] for inference in data]
    outputs = [inference[2] for inference in data]

    marital = [m.replace('/', '\n') for m in marital]
    
    counts_1 = []
    counts_2 = []

    for status in set(marital):
        count_1 = 0
        count_2 = 0
        for i in range(len(marital)):
            if marital[i] == status:
                if outputs[i] == '1':
                    count_1 += 1
                elif outputs[i] == '2':
                    count_2 += 1
        counts_1.append(count_1)
        counts_2.append(count_2)

    # Etiquetas para las barras
    labels = list(set(marital))

    # Posiciones de las barras
    x = range(len(labels))

    # Ancho de las barras
    width = 0.35

    # Colores personalizados
    color_denegado = '#ff6666'
    color_aceptado = '#99ff99'

    # Crear el gráfico de barras
    fig, ax = plt.subplots()
    ax.bar(x, counts_1, width, label='Denied', color=color_denegado)
    ax.bar([i + width for i in x], counts_2, width, label='Approved', color=color_aceptado)

    # Añadir etiquetas, título y leyenda
    ax.set_xlabel('Marital Status')
    ax.set_ylabel('Count')
    ax.set_title('Approvals and denials by marital status')
    ax.set_xticks([i + width / 2 for i in x])
    ax.set_xticklabels(labels, rotation=0, ha='center')
    ax.legend()

    # Mostrar el gráfico
    plt.tight_layout()
    plt.savefig('tex/media/marital.png', bbox_inches='tight')


def job_credits(data):
    """
    Visualizes job-based credits data.
    
    Args:
        data (list): A list of lists containing log information.
    """
    jobs = [inference[1]['Job'] for inference in data]
    outputs = [inference[2] for inference in data]

    jobs = [job.replace('/', '\n') for job in jobs]
    jobs = [job.replace(' ', '\n') for job in jobs]

    # Count occurrences of "1" and "2" for each category
    counts_1 = []
    counts_2 = []

    for job in set(jobs):
        count_1 = 0
        count_2 = 0
        for i in range(len(jobs)):
            if jobs[i] == job:
                if outputs[i] == '1':
                    count_1 += 1
                elif outputs[i] == '2':
                    count_2 += 1
        counts_1.append(count_1)
        counts_2.append(count_2)

    # Labels for the bars
    labels = list(set(jobs))

    # Positions of the bars
    x = range(len(labels))

    # Width of the bars
    width = 0.35

    # Custom colors
    color_denegado = '#ff6666'
    color_aceptado = '#99ff99'

    # Create the bar chart
    fig, ax = plt.subplots()
    ax.bar(x, counts_1, width, label='Denied', color=color_denegado)
    ax.bar([i + width for i in x], counts_2, width, label='Approved', color=color_aceptado)

    # Add labels, title, and legend
    ax.set_xlabel('Job Category')
    ax.set_ylabel('Count')
    ax.set_title('Approvals and denials by job category')
    ax.set_xticks([i + width / 2 for i in x])
    ax.set_xticklabels(labels, rotation=0, ha='center')
    ax.legend()

    # Show the plot
    plt.tight_layout()
    plt.savefig('tex/media/jobs.png', bbox_inches='tight')


def credit_inference(data):
    """
    Visualizes credit inference data over time.
    
    Args:
        data (list): A list of lists containing log information.
    """
    dates = [inference[0] for inference in data]
    outputs = [inference[2] for inference in data]

    dates = [date.replace(' ', '\n') for date in dates]

    # Create the bar chart
    plt.figure(figsize=(10, 4))
    plt.bar(dates, outputs, color='skyblue')

    # Labels and title
    plt.xlabel('Time')
    plt.ylabel('Denied or Approved')
    plt.title('Inferences over time')
    plt.legend(['Approved'])
    
    # Show the plot
    plt.xticks(rotation=90)
    plt.tight_layout()
    plt.savefig('tex/media/sequence.png', bbox_inches='tight')


def create_graphs(data):
    """
    Creates various graphs based on the provided data.
    
    Args:
        data (list): A list of lists containing log information.
    """
    gender_credits(data)
    foreign_credits(data)
    credit_inference(data)
    job_credits(data)
    marital_credits(data)
    foreign_credits(data)


def create(date, n_inferences, percentage):
    """
    Creates a LaTeX template file with the specified date.
    
    Args:
        date (datetime): The date to include in the file name.
        n_inferences (int): The number of inferences.
        percentage (int): The percentage of approved credits.
    """
    # Format date
    date = date.strftime("%Y-%m-%d")

    # LaTeX template string
    string = r"""
\documentclass{article}
\usepackage{graphicx}
\usepackage{geometry}
\usepackage{multicol}


% Ajustar los márgenes para que todo quepa en una página
\geometry{
    a4paper,
    total={170mm,257mm},
    left=20mm,
    top=10mm,
}

\begin{document}


\begin{flushright} % Alinea el logo a la derecha
    \includegraphics[width=1.5cm]{tex/media/logo.png} 
\end{flushright}

\centering
{\Huge \textbf{Informe}}

\vspace{0.5cm}

{\Large Autogenerado por XaiCreditCopilot}

\vspace{0.5cm}

{\large \today}

\raggedright

El presente informe ha sido autogenerado con el propósito de cumplir con el plan de seguimiento posterior del proyecto. Toda la información contenida en este documento se proporciona únicamente como un hecho informativo para evaluar el funcionamiento adecuado del sistema.

\begin{multicols}{2}

En el presente documento se muestran estadísticas creadas por el sistema durante el último mes. Podemos apreciar cómo se han realizado {\huge """+str(n_inferences)+r""" inferencias} con el sistema y se han generado conclusiones relevantes sobre el proceso de otorgamiento de créditos. Los siguientes gráficos representan la distribución de la aceptación y denegación de crédito en función de variables protegidas, como género, nacionalidad, tipo de trabajo y estado civil. Estos análisis son cruciales para identificar posibles sesgos en el proceso de toma de decisiones y garantizar la equidad en el acceso al crédito.

\vspace{0.5cm}
\textbf{Análisis por género:}

En primer lugar, podemos apreciar dos gráficos de tarta que representan la distribución de créditos aceptados y denegados según el género de los solicitantes. Estos gráficos proporcionan una visión clara de la proporción de créditos otorgados y rechazados para mujeres y hombres. Además, se muestra el total de créditos solicitados por cada género, lo que permite una comparación directa entre la cantidad de créditos solicitados por mujeres y hombres.

\begin{center} % Alinea el logo a la derecha
    \includegraphics[width=8cm]{tex/media/gender.png} 
\end{center}

Después de un análisis exhaustivo de los registros, la aplicación ha concluido que es pertinente {\huge otorgar un """+str(percentage)+r"""\%} de los créditos evaluados durante este período.

\vspace{0.5cm}
\textbf{Análisis por extranjería:}

Uno de los aspectos clave que se analizan en este estudio es el estatus de extranjería del solicitante. Este factor desempeña un papel fundamental en el proceso de evaluación de créditos, ya que puede influir en la decisión final sobre la aprobación o denegación del crédito. A continuación, se presentan los hallazgos relacionados con la distribución de créditos en función del estatus de extranjería de los solicitantes.


\begin{center} % Alinea el logo a la derecha
    \includegraphics[width=8cm]{tex/media/foreign.png} 
\end{center}

\vspace{0.5cm}
\textbf{Análisis por tipo de empleo:}

Otro aspecto relevante que se considera en este análisis es el puesto de trabajo del solicitante. Este factor se examina con detenimiento para evitar sesgos por nivel educativo en el conjunto de datos. Dado que el tipo de trabajo puede estar correlacionado con el nivel de ingresos y estabilidad laboral, comprender su distribución en relación con la aprobación o denegación de créditos es esencial para garantizar la equidad en el proceso de evaluación. A continuación, se presentan los resultados relacionados con la distribución de créditos según el puesto de trabajo de los solicitantes.


\begin{center} % Alinea el logo a la derecha
    \includegraphics[width=8cm]{tex/media/jobs.png} 
\end{center}

\vspace{0.5cm}
\textbf{Análisis por estadi civil:}

Otro aspecto relevante bajo estudio es el estado civil del solicitante. Reconociendo que el estado civil, como estar casado, puede conferir ciertos privilegios en algunas circunstancias, es esencial examinar su impacto en el proceso de evaluación de créditos. 

\begin{center} % Alinea el logo a la derecha
    \includegraphics[width=8cm]{tex/media/marital.png} 
\end{center}

Es fundamental comprender cómo se distribuyen los créditos según diversos atributos protegidos de los solicitantes para identificar posibles sesgos y garantizar la imparcialidad en el proceso de otorgamiento.

\end{multicols}

A continuación, se presenta una gráfica que ilustra la evolución temporal de las inferencias, reflejando la cantidad de créditos otorgados en distintos períodos.

\begin{center} % Alinea el logo a la derecha
    \includegraphics[width=16cm]{tex/media/sequence.png} 
\end{center}

En conclusión, revisar periódicamente el informe es crucial para asegurar que el modelo de inferencia opere de manera adecuada y sin sesgos en relación a los distintos atributos a lo largo del tiempo. Esta práctica no solo garantiza la precisión y fiabilidad de las decisiones tomadas por el sistema, sino que también promueve la equidad y transparencia en el proceso de evaluación de créditos.


Con aprecio y dedicación,

XaiCreditCopilot

\begin{center}
    \textbf{Con aprecio y dedicación,}\\
    \vspace{0.5cm}
    \textsc{XaiCreditCopilot}\\
    \vspace{0.2cm}
\end{center}

{\small
Gracias por confiar en nuestro sistema para el análisis y evaluación de créditos. Estamos comprometidos a seguir mejorando y garantizar la equidad y precisión en cada decisión. No dudes en contactarnos si alguno de los parámetros difiere de un rango normal.
}

\end{document}

"""

    # Write LaTeX template to file
    with open('tex/'+ date +'.tex', 'w') as log_file:
        log_file.write(string)


def export(date):    
    """
    Compiles the LaTeX file corresponding to the specified date into a PDF.
    
    Args:
        date (datetime): The date of the LaTeX file to compile.
    """
    # Format date
    date = date.strftime("%Y-%m-%d")
    
    # Run LaTeX to compile the document
    with open('tex/latex.log', 'w') as log_file:
        subprocess.run(['latexmk', '--pdf', '--interaction=nonstopmode',
                        '-output-directory=pdf', 'tex/'+ date +'.tex'],
                       stdout=log_file, stderr=log_file)

        
def create_report(date):
    """
    Creates a LaTeX report with graphs based on the log data for the specified date.
    
    Args:
        date (datetime): The date for which to create the report.
    """
    # Print the date
    print(date)
    
    # Read log data
    data, n_inferences, percentage = read_log(date)
    
    # Generate graphs and create LaTeX report
    create_graphs(data)
    create(date, n_inferences, percentage)
    
    # Compile LaTeX report
    export(date)
