Installation.md

Instalar miniconda:

https://docs.anaconda.com/free/miniconda/ 

Tras instalar miniconda:

En una terminal con permisos de administrador, ejecutar: 

```bash
conda env create -f environment.yml
conda activate xai
```

Instalar R:

https://cran.r-project.org/

Tras instalar R:

En una terminal con permisos de administrador, ejecutar: 

```bash
R
```

```R
install.packages('arules=1.7.7')
install.packages('ArulesCBA=1.2.5')
install.packages('tidyverse=2.0.0')
install.packages('Caret=6.0.94')
```