# Instalación
## Instalar miniconda:

https://docs.anaconda.com/free/miniconda/ 

Tras instalar miniconda:

En una terminal con permisos de administrador, ejecutar: 

```bash
conda env create -f environment.yml
conda activate xai
```

## Instalar R:

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

## Instrucciones de uso

Este producto puede ser accedido tanto desde R como desde python. 

Para acceder desde R, se debe ejecutar el script `rCBA.R` en la carpeta `src/Product/` de la siguiente manera:

```bash
Rscript rCBA.R 
```

De esta manera se ejecutará el ejemplo hecho en R que hay en la función `main`.

Para acceder desde python, se debe ejecutar el script `pythonCBA.py` en la carpeta `src/Product/` de la siguiente manera:

```bash
python pyCBA.py
```
De esta manera se ejecutará el ejemplo hecho en python que hay en la función `main`.

Este ejemplo sencillo puede sustituirse llamando a las funciones `init_model` y `predict_model` en este orden con los datos que se deseen.

Para el correcto funcionamiento del modelo que se ha realizado tras un exhaustivo análisis de los datos, se debe inicializar con los siguientes parámetros:

- `Data`: Statlog_rCBA.csv
- `Train size`: 0.7
- `Support`: 0.01
- `Confidence`: 0.01

En caso de querer trabajar con ello en un entorno remoto o en un servidor, se puede acceder mediante la dirección IP de la máquina en la que se instale.

Para ejecutarlo habría que instalar las mismas dependencias que se han mencionado anteriormente y se ejecutaría el siguiente comando:

```bash
uvicorn main:app --reload
```

De esta manera se ejecutaría el modelo en un servidor y sabiendo su IP y puerto podría hacerse una llamada a la API que se ha creado y tiene las siguentes vistas:

- `/`: Vista principal que muestra un mensaje de bienvenida.
- `/applicationForm`: Vista que muestra un formulario para introducir los datos y obtener una predicción.
- `/sendApplication`: Vista que recibe los datos del formulario y devuelve la predicción obtenida en el modelo.

El modelo de esta API ha sido inicializado con los parámetros que se han mencionado anteriormente.