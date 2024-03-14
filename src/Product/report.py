import subprocess


def write(date):
    with open('tex/latex.log', 'w') as log_file:
        subprocess.run(['latexmk', '--pdf', '--interaction=nonstopmode',
                        '-output-directory=pdf', 'tex/'+ date +'.tex'],
                       stdout=log_file, stderr=log_file)


def create(date):

# fichero latex
    string = """
\documentclass{minimal}
\\begin{document}

Hello World! """ + date + """ 


\end{document}
"""

    with open('tex/'+ date +'.tex', 'w') as log_file:
        log_file.write(string)
        log_file.close()
