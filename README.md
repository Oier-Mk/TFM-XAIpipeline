# TFM-XAIpipeline

## Descripción del Proyecto

Este proyecto, titulado TFG-XAIpipeline, se enfoca en el desarrollo de una herramienta para generar conjuntos de datos destinados a alimentar sistemas de inteligencia artificial de alto riesgo. La necesidad de este tipo de herramienta surge de la creciente demanda de sistemas de IA en aplicaciones críticas, donde la precisión y la equidad son de suma importancia. Este proyecto se centra específicamente en asegurar que los conjuntos de datos utilizados en estos sistemas sean conformes con la legislación europea relacionada con la protección de datos y la equidad en el procesamiento automatizado de decisiones. Con este proyecto se pretende hacer uso de la inteligencia artificial de _caja negra_ para poder obtener conclusiones e imitarla con algoritmos de _caja blanca_ para construir un sistema de alto riesto **ético, legal y transparente**.

## Objetivos

Los objetivos principales de este proyecto son:

# Lista de Objetivos

1. **Adquisición de Dataset Aceptación/Denegación de Créditos Bancarios**: Seleccionar un dataset adecuado que contenga información sobre la aceptación o denegación de créditos bancarios, considerado un caso de alto riesgo y con salida binaria (aceptado o denegado).

2. **Preprocesamiento No Sesgado según Directrices Legales**: Implementar un preprocesamiento de datos que no esté sesgado y que cumpla con las directrices marcadas por la ley. Se utilizará un algoritmo de IBM, una librería llamada AI Fairness 360, debido a su capacidad para mitigar el sesgo y garantizar la equidad en los datos de entrenamiento.

3. **Modelado con XGBoost y rCBA**: Utilizar los algoritmos XGBoost y rCBA para el modelado de los datos. XGBoost es seleccionado por su eficacia y amplia adopción en la comunidad de machine learning, mientras que rCBA es útil por su trazabilidad y transparencia.

4. **Alineación de la Precisión del Modelo rCBA con XGBoost**: Estudiar las posibles diferencias entre los modelos obtenidos con XGBoost y rCBA, y buscar maneras de asemejar el valor de precisión del modelo rCBA al de XGBoost, asegurando que la diferencia sea menor al 10%.

5. **Resultado del Modelo rCBA y Comparación con XGBoost**: Presentar los resultados del modelo rCBA y indicar la ligera superioridad del modelo XGBoost en términos de precisión. Se debe resaltar que el modelo XGBoost corrobora en todo momento lo obtenido con rCBA.

6. **Justificación para Introducir el Modelo al Mercado de Alto Riesgo**: Ofrecer una justificación sobre cómo el modelo, a pesar de ser de alto riesgo, puede ser introducido al mercado. Esto podría incluir medidas de mitigación de riesgos, garantías de cumplimiento legal y ético, y beneficios potenciales para los usuarios.

7. **Trabajo a Futuro para Comercialización**: Especificar el trabajo futuro necesario para la comercialización del modelo, considerando aspectos teóricos y legales establecidos por la ley. Esto podría incluir la realización de pruebas adicionales, la optimización del modelo para diversos contextos y la documentación detallada sobre su funcionamiento y aplicaciones éticas.

8. **Impacto Ético y Legal de la Comercialización del Modelo de IA**: Realizar un estudio exhaustivo sobre las implicaciones éticas y legales de comercializar un modelo de IA de este estilo, abordando preocupaciones relacionadas con la privacidad, la equidad y el cumplimiento normativo.

## Estructura del Repositorio

El repositorio está organizado de la siguiente manera:

- **docs/**: Contiene la documentación relacionada con el proyecto.
- **src/**: Contiene el código fuente del generador de conjuntos de datos.
- **tests/**: Contiene los casos de prueba para validar el funcionamiento del generador.
- **README.md**: Este archivo que proporciona una visión general del proyecto y las instrucciones para su uso.

## Uso

Para utilizar el generador de conjuntos de datos, sigue las instrucciones detalladas en la documentación proporcionada en el directorio 'docs'. Asegúrate de cumplir con todas las regulaciones y requisitos legales aplicables antes de utilizar este software en un entorno de producción.

[ ] TODO

## Contribución

Codirector del Trabajo de fin de master: Francisco Herrera[^1] es un catedrático en el Departamento de Ciencias de la Computación e Inteligencia Artificial de la Universidad de Granada, y director del grupo de investigación 'Soft Computing y Sistemas de Información Inteligentes’.

Coddirector del Trabajo de fin de master: Pablo García Bringas[^2] es Doctor Ingeniero Informático, especializado en aplicación de Inteligencia Artificial al campo de la Ciber-Seguridad. Es profesor titular de ingeniería en la Universidad de Deusto y actualmente es Vicedecano de relaciones externas, formación continua, e investigación.

[^1]: [Francisco Herrera - Universidad de Granada](https://www.ugr.es/personal/francisco-herrera-triguero)
[^2]: [Pablo García Bringas - Universidad de Deusto](https://deustotech.deusto.es/member/garcia-bringas-pablo/)

