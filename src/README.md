# Carpeta raiz del proyecto
# SRC

Esta carpeta contiene los scripts desarrollados tanto en Python como en R para el preprocesamiento de datos y la implementación de modelos de machine learning.

## Python

En la carpeta de Python se encuentra el código para realizar el preprocesamiento básico de outliers y valores anómalos, así como la integración de la librería AIF360 para mitigar sesgos en los datos.

## R

Dentro de la carpeta R se encuentra el código para realizar el preprocesamiento de datos específico para cada uno de los modelos y la implementación de los mismos.

## Modelos

### Elección de XGBoost

XGBoost es una elección común y sólida para muchos proyectos de machine learning por varias razones:

1. **Rendimiento y Escalabilidad**: es conocido por su alto rendimiento y escalabilidad. Está diseñado para manejar grandes conjuntos de datos y puede ejecutarse eficientemente en entornos distribuidos, lo que lo hace adecuado para proyectos que requieren modelado con conjuntos de datos extensos.

2. **Regularización Incorporada**: incluye regularización incorporada que ayuda a prevenir el sobreajuste. Esto significa que puede manejar de manera efectiva la complejidad del modelo y generalizar bien a datos no vistos, lo que resulta en modelos más robustos y confiables.

3. **Flexibilidad y Versatilidad**: es altamente flexible y versátil. Puede manejar una variedad de tipos de datos y es compatible con una amplia gama de tareas de aprendizaje supervisado, como clasificación, regresión y ranking.

4. **Historial de Éxito**: ha sido utilizado con éxito en numerosos desafíos de aprendizaje automático y competiciones de ciencia de datos (muchas en Kaggle), y ha demostrado ser efectivo en una amplia gama de aplicaciones del mundo real. Su robustez y rendimiento lo hacen una elección confiable para proyectos de alta exigencia.

### Elección de rCBA

rCBA (Regression Classification Based Association) es una elección adecuada para este proyecto por las siguientes razones:

1. **Interpretación de Reglas**: es un algoritmo de aprendizaje basado en reglas que produce modelos fácilmente interpretables en forma de reglas de decisión. Estas reglas pueden ser comprensibles para los expertos del dominio y los usuarios finales, lo que facilita la comprensión del modelo y la toma de decisiones basada en el mismo.

2. **Manejo de Datos Categóricos**: está diseñado para manejar conjuntos de datos que contienen atributos categóricos, lo que lo hace adecuado para aplicaciones donde este tipo de datos es común. En el contexto de la evaluación de crédito, donde los atributos como el tipo de empleo o el estado civil pueden ser categóricos, tiene mucho potencial.

3. **Transparencia y Explicabilidad**: ya que son aspectos clave en aplicaciones sensibles como la evaluación de crédito. rCBA produce modelos transparentes y explicables que pueden ser auditados y comprendidos por cualquiera, lo que ayuda a garantizar la equidad y la transparencia en el proceso de toma de decisiones.

4. **Historial de Uso en Contextos Sensibles**: rCBA ha sido utilizado en aplicaciones sensibles y críticas en el pasado, como en la medicina y la evaluación de riesgos, lo que demuestra su utilidad y eficacia en situaciones donde la confiabilidad y la interpretación son fundamentales.

### Uso de XGBoost y rCBA

El modelo de XGBoost se empleará con el objetivo de obtener una separación de los datos lo más precisa posible. XGBoost es conocido por su capacidad para crear modelos altamente precisos y generalizables, lo que lo convierte en una elección apropiada para este propósito. Al entrenar un modelo de XGBoost en los datos de crédito, se espera obtener una separación óptima que permita clasificar con precisión entre las instancias de aceptación y denegación de créditos.

Por otro lado, se pretende utilizar el modelo rCBA para imitar y encontrar esta separación de manera explicativa. La ingeniería inversa es una técnica que implica analizar un sistema complejo para comprender su funcionamiento interno. En este contexto, rCBA se empleará para realizar una especie de "ingeniería inversa" en el modelo de XGBoost. Esto implica intentar descomponer la compleja separación de datos realizada por XGBoost en un conjunto de reglas de decisión más simples y explicativas.

Al emplear rCBA de esta manera, se busca obtener un modelo que no solo sea preciso, sino también interpretable y comprensible para los humanos. Esta interpretabilidad es crucial en aplicaciones como la evaluación de crédito, donde es importante entender las razones detrás de las decisiones tomadas por el modelo. Al comprender cómo rCBA imita la separación de datos de XGBoost, se puede obtener una visión más clara de las características y los patrones que influyen en las decisiones de aceptación o denegación de créditos.
