# Taller 3.3 - Implementación de Triggers y Mecanismos de Auditoría

Este repositorio contiene el desarrollo práctico correspondiente al **Taller 3.3 de Triggers**, desarrollado para la asignatura de **Modelado de Bases de Datos**. El objetivo principal del proyecto es diseñar, programar y evaluar soluciones complejas mediante disparadores (*triggers*) en SQL Server para automatizar reglas de negocio, garantizar la integridad referencial y establecer logs de auditoría en sistemas relacionales.

---

## 👥 Integrantes del Equipo
Todos los miembros han contribuido de manera equitativa (100%) en el análisis, codificación y documentación del proyecto:
* **Carpio Delgado, Alejandro Eduardo** - Código: `024100051j`
* **Haro Rosales, Joaquín** - Código: `024100970e`
* **Molero Zegarra, Thiago Valentino** - Código: `024100247a`
* **Olivera Ochoa, Paúl Claus** - Código: `024100569i`

**Docente:** Espetia Huamanga, Hugo  
**Institución:** Universidad Andina del Cusco  
**Escuela Profesional:** Ingeniería de Sistemas  
**Semestre Académico:** 2025-I (Junio de 2026)

---

## 📊 Estructura del Proyecto

El proyecto se encuentra dividido estratégicamente para abordar dos bases de datos clásicas de pruebas de Microsoft, distribuyendo las responsabilidades del equipo de la siguiente manera:

### 1. Base de Datos: PUBS 📚
Estructura de triggers enfocada en el control transaccional de ventas de libros, protección de contratos editoriales y auditoría del personal:
* **Tabla de Auditoría (`Auditoria_Pubs`):** Infraestructura centralizada encargada de registrar las acciones automáticas controladas por el sistema.
* **Trigger 1 (`trg_AuditarPrecioLibro`):** Monitorea cambios de precios en la tabla `titles`, almacenando el historial con el valor antiguo y el nuevo valor.
* **Trigger 2 (`trg_ValidarCantidadVenta`):** Bloquea e invalida mediante un `ROLLBACK` cualquier inserción en la tabla `sales` si el volumen de libros solicitado es superior a 100 unidades.
* **Trigger 3 (`trg_ActualizarYTD`):** Automatiza la acumulación anual de unidades vendidas (`ytd_sales`) en base a los registros nuevos ingresados.
* **Trigger 4 (`trg_ProtegerAutoresActivos`):** Restricción de integridad que impide la eliminación de un autor en `authors` si mantiene un contrato vigente activo.
* **Trigger 5 (`trg_LogNuevoEmpleado`):** Log de auditoría que registra de manera exacta los datos identificativos de cada nuevo colaborador en `employee`.

### 2. Base de Datos: NORTHWIND 🛒
Estructura transaccional avanzada encargada del aprovisionamiento, control riguroso de inventarios, fluctuaciones comerciales de clientes y catálogos de productos:
* **Triggers de Auditoría e Integridad:** Diseñados para mitigar errores humanos, automatizar el reabastecimiento técnico de stock y guardar logs detallados de manipulación de registros comerciales.

---

## 📁 Organización de Archivos en el Repositorio

```micro
├── README.md                 # Documentación principal del repositorio (este archivo)
├── triggers_pubs.sql         # Script SQL con la tabla de auditoría, triggers y pruebas de PUBS
├── triggers_northwind.sql    # Script SQL con la solución lógica e implementación de NORTHWIND
└── informe/
    └── Taller_3.3_Triggers.pdf  # Informe Formal Completo con capturas de pantalla y conclusiones
