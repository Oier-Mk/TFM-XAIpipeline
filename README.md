# TFM-XAIpipeline & XaiCreditCopilot

## Descripción del Proyecto

Este proyecto, titulado TFG-XAIpipeline, se enfoca en el desarrollo de una herramienta para generar conjuntos de datos destinados a alimentar sistemas de inteligencia artificial de alto riesgo. La necesidad de este tipo de herramienta surge de la creciente demanda de sistemas de IA en aplicaciones críticas, donde la precisión y la equidad son de suma importancia. Este proyecto se centra específicamente en asegurar que los conjuntos de datos utilizados en estos sistemas sean conformes con la legislación europea relacionada con la protección de datos y la equidad en el procesamiento automatizado de decisiones. Con este proyecto se pretende hacer uso de la inteligencia artificial de _caja negra_ para poder obtener conclusiones e imitarla con algoritmos de _caja blanca_ para construir un sistema de alto riesto **ético, legal y transparente**.

## Objetivos

Los objetivos principales de este proyecto son:

- [x] 1. **Adquisición de Dataset Aceptación/Denegación de Créditos Bancarios**: Seleccionar un dataset adecuado que contenga información sobre la aceptación o denegación de créditos bancarios, considerado un caso de alto riesgo y con salida binaria (aceptado o denegado).

- [x] 2. **Preprocesamiento No Sesgado según Directrices Legales**: Implementar un preprocesamiento de datos que no esté sesgado y que cumpla con las directrices marcadas por la ley. Se utilizará un algoritmo de IBM, una librería llamada AI Fairness 360, debido a su capacidad para mitigar el sesgo y garantizar la equidad en los datos de entrenamiento.

- [x] 3. **Modelado con XGBoost y rCBA**: Utilizar los algoritmos XGBoost y rCBA para el modelado de los datos. XGBoost es seleccionado por su eficacia y amplia adopción en la comunidad de machine learning, mientras que rCBA es útil por su trazabilidad y transparencia.

- [x] 4. **Alineación de la Precisión del Modelo rCBA con XGBoost**: Estudiar las posibles diferencias entre los modelos obtenidos con XGBoost y rCBA, y buscar maneras de asemejar el valor de precisión del modelo rCBA al de XGBoost, asegurando que la diferencia sea menor al 10%.

- [x] 5. **Resultado del Modelo rCBA y Comparación con XGBoost**: Presentar los resultados del modelo rCBA y indicar la ligera superioridad del modelo XGBoost en términos de precisión. Se debe resaltar que el modelo XGBoost corrobora en todo momento lo obtenido con rCBA.

- [ ] 6. **Justificación legal para Introducir el Modelo al Mercado de Alto Riesgo**: Proporcionar una fundamentación legal que respalde la introducción del modelo en un mercado de alto riesgo. Esto implica presentar medidas para mitigar riesgos, asegurar el cumplimiento legal y ético, y destacar los beneficios potenciales para los usuarios.

  - [x] Documentación técnica
    - [ ] Flowchart 2.B
    - [ ] Sequence diagram 2.C
  - [x] Requerimientos del programa y versiones
  - [x] Instalación
  - [x] Sistema de gestión de riesgos
  - [x] Plan de seguimiento posterior
    - [ ] Notificación de fallos e incidentes graves A62
    - [ ] Especificar tareas
  - [x] Declaración de conformidad
  - [x] Marcado de conformidad
  - [x] Sistema de gestión de calidad
  - [x] Registro del sistema

- [ ] 7. **Justificación ética para Introducir el Modelo al Mercado de Alto Riesgo**: Ofrecer una justificación sobre cómo el modelo, a pesar de ser de alto riesgo, puede ser introducido al mercado. Esto podría incluir medidas de mitigación de riesgos, garantías de cumplimiento legal y ético, y beneficios potenciales para los usuarios.

- [x] 8. **Impacto económico del uso de inteligencia artificial de caja blanca frente a caja negra**: Analizar de manera exhaustiva el uso de sistemas de inteligencia artificial caja blanca en comparación con los caja negra afecta económicamente a las empresas y las industrias.
  - [x] Presupuesto completo
  - [x] Presupuesto sin aplicar la ley
  - [x] Valor generado

## Estructura del Repositorio

El repositorio está organizado de la siguiente manera:

- **docs/**: Contiene la documentación relacionada con el proyecto.
- **src/**: Contiene el código fuente del generador de conjuntos de datos.
- **tests/**: Contiene los casos de prueba para validar el funcionamiento del generador.
- **README.md**: Este archivo que proporciona una visión general del proyecto y las instrucciones para su uso.

## Contribución

Codirector del Trabajo de fin de master: Francisco Herrera[^1] es un catedrático en el Departamento de Ciencias de la Computación e Inteligencia Artificial de la Universidad de Granada, y director del grupo de investigación 'Soft Computing y Sistemas de Información Inteligentes’.

Coddirector del Trabajo de fin de master: Pablo García Bringas[^2] es Doctor Ingeniero Informático, especializado en aplicación de Inteligencia Artificial al campo de la Ciber-Seguridad. Es profesor titular de ingeniería en la Universidad de Deusto y actualmente es Vicedecano de relaciones externas, formación continua, e investigación.

Colaborador: Iñaki Sasia[^3], es un Ingeniero Informático y antiguo profesor en la Universidad de Deusto. Además, ha dirigido proyectos tecnológicos tanto para el sector privado como para la Administración Pública. Su colaboración se ha centrado en la formulación de presupuestos precisos y documentación espeífica. 

Colaboradora: Demelsa Benito[^4], es doctora de Derecho penal en la Universidad de Deusto y profesora de Derecho penal y Criminología. Su colaboración ha sido vital para la correcta comprensión de la Ley de Inteligencia Artificial y la Ley de Protección de Datos además de la redacción de la documentación legal.

Colaborador: Jose Luis Retolaza[^5], es doctor en Ciencias Económicas y Empresariales y profesor de la Universidad de Deusto. Su colaboración se ha centrado en el análisis del valor generado con un sistema de inteligencia artificial de caja blanca frente a los modelos de caja negra.

Colaborador: Alfonso Peralta[^6], es un juez con experiencia en Inteligencia Artificial. Entre sus logros, destaca su participación como codirector del curso “El derecho y la Inteligencia artificial” organizado por el Consejo General del Poder Judicial y la Universidad de Granada. Además, está involucrado en el máster “Digital Law and Business Tech” de la Escuela de Dirección y Altos Estudios. Su colaboración ha sido vital para la correcta comprensión de la Ley de Inteligencia Artificial y la Ley de Protección de Datos además de la redacción de la documentación legal.

[^1]: [Francisco Herrera - Universidad de Granada](https://www.ugr.es/personal/francisco-herrera-triguero)
[^2]: [Pablo García Bringas - Universidad de Deusto](https://deustotech.deusto.es/member/garcia-bringas-pablo/)
[^3]: [Iñaki Sasia - Universidad de Deusto](https://www.linkedin.com/in/i%C3%B1aki-sasia-olaz%C3%A1bal-3b3b3b3b/)
[^4]: [Demelsa Benito - Universidad de Deusto](https://www.deusto.es/es/inicio/somos-deusto/equipo/investigadores/1657/investigador)
[^5]: [Jose Luis Retolaza - Universidad de Deusto](https://www.deusto.es/es/inicio/somos-deusto/equipo/investigadores/57912/investigador)
[^6]: [Alfonso Peralta - Universidad de Granada](https://www.linkedin.com/in/a-peralta/?originalSubdomain=es)
