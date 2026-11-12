*Leer este documento en otros idiomas: [English](README.md)*

# Grocery Store Analytics | Proyecto SQL e Ingeniería de Datos (Data Science)

## Descripción del Proyecto

Este proyecto implementa un flujo de trabajo integral de análisis e ingeniería de datos sobre un conjunto de datos de ventas de una tienda de comestibles utilizando PostgreSQL y Python, simulando tareas reales de un Data Scientist / Analytics Engineer.

Abarca todo el pipeline, desde el modelado de datos y los procesos ETL hasta análisis avanzados y exploración basada en Python, generando conjuntos de datos preparados para herramientas de BI como Tableau o Power BI.

## Componentes Principales

- Ingeniería de datos basada en PostgreSQL (esquema, modelo estrella, ETL)
- KPIs de negocio y consultas analíticas
- Segmentación de clientes (RFM) y análisis de cohortes
- Análisis de cesta de mercado y conocimiento de productos
- Análisis de inventario y demanda
- Validación de calidad de datos
- Integración con Python para consultas y EDA
- Exportaciones CSV para uso en herramientas de BI

## Conjunto de Datos

El proyecto utiliza una base de datos relacional simulada de ventas de una tienda de comestibles con 7 tablas:

- categories
- cities
- countries
- customers
- employees
- products
- sales

Incluye datos transaccionales, de clientes, productos y geográficos adecuados para análisis SQL, BI de retail y análisis de comportamiento.

Fuente: *Grocery Sales Database* de Andrex Ibiza, MBA, [Kaggle](https://www.kaggle.com/datasets/andrexibiza/grocery-sales-dataset) (CC0: dominio público). Ventas simuladas del 2018-01-01 al 2018-05-09: ~6,7M líneas de venta, 98.759 clientes, 452 productos y 23 empleados.

## Estructura del Proyecto

```
├── data/                                   CSV originales (sales.csv se descarga aparte, ver abajo)
├── 1) sql/
│   ├── 1) Creation of the database and tables/   Tablas transaccionales (01-07) + carga de CSV (08)
│   ├── 2) data_engineering/                      Esquema estrella y ETL (esquema analytics)
│   └── 3) data_science/                          KPIs, RFM, cohortes, cesta, inventario, calidad, vistas BI
├── 2) Results ready for tableau/           Exportaciones CSV para Tableau
├── 3) notebooks/groceries shop.ipynb       Análisis con Python + PostgreSQL
├── ERD.png                                 Diagrama entidad-relación
└── requirements.txt
```

## Cómo Ejecutarlo

1. Crear la base de datos: `CREATE DATABASE groceries_db;`
2. Ejecutar `1) sql/1) Creation of the database and tables/01` a `07` (tablas con claves primarias y foráneas).
3. Descargar `sales.csv` (~500 MB, demasiado grande para GitHub) desde el
   [Grocery Sales Database en Kaggle](https://www.kaggle.com/datasets/andrexibiza/grocery-sales-dataset) en `data/`,
   y luego cargar los CSV desde la raíz del repositorio con psql:
   `psql -U postgres -d groceries_db -f "1) sql/1) Creation of the database and tables/08_load_data.sql"`
4. Ejecutar en orden los scripts de `1) sql/2) data_engineering/` (01 → 06).
5. Ejecutar en orden los scripts de `1) sql/3) data_science/` (01 → 07).
6. Abrir el notebook. Las credenciales se leen de variables de entorno (`PGUSER`, `PGPASSWORD`, `PGHOST`, `PGPORT`, `PGDATABASE`); si `PGPASSWORD` no está definida, la contraseña se pide al ejecutar.

```bash
pip install -r requirements.txt
```

## Notas y Supuestos sobre los Datos

- **El revenue se calcula**: la columna `TotalPrice` del dataset original siempre vale `0`, por eso el ETL calcula
  `revenue = Quantity × Price × (1 − Discount)` usando el precio del producto.
- **Fechas faltantes**: ~1% de las ventas no tiene `SalesDate`. Se mantienen en la tabla de hechos (suman en los
  totales) pero se excluyen de los análisis temporales (tendencias mensuales, cohortes, recencia).
- **Definición de visita (cesta)**: cada `TransactionNumber` contiene una sola línea de producto, por lo que una visita es
  *todos los productos comprados por el mismo cliente en el mismo día*. La misma definición se usa en el ticket promedio,
  la frecuencia RFM, el tiempo entre visitas y el análisis de cesta.
- **Mes parcial**: los datos terminan el 2018-05-09, por eso la comparación mensual usa el revenue promedio por día con ventas.
- `customers.csv` guarda las iniciales faltantes como el texto `NULL`; el script de carga las convierte en NULL reales.

## PostgreSQL: Capa de Ingeniería de Datos

Esta capa construye un almacén de datos preparado para análisis mediante modelado dimensional.

### Orden de Ejecución (`1) sql/2) data_engineering/`)

1. `01_schema.sql`
2. `02_dimensions.sql`
3. `03_fact_sales.sql`
4. `04_indexes.sql`
5. `05_etl_full_load.sql`
6. `06_etl_incremental.sql`

### Responsabilidades Principales

- Diseño de esquema estrella con `fact_sales` y dimensiones (fecha, producto, cliente, etc.)
- Pipelines ETL (cargas completas e incrementales)
- Indexación y optimización del rendimiento
- Preparación de datos para cargas de trabajo analíticas

## Capa Analítica: Scripts SQL

Construida sobre el almacén de datos para generar insights y vistas de BI.

### Scripts (`1) sql/3) data_science/`)

1. `01_materialized_views.sql`
2. `02_kpis.sql`
3. `03_rfm_cohort.sql`
4. `04_market_basket.sql`
5. `05_inventory.sql`
6. `06_data_quality.sql`
7. `07_tableau_views.sql`

### Áreas de Enfoque

- Generación de KPIs de negocio (ingresos, tendencias de ventas, unidades vendidas)
- Analítica de clientes (RFM, cohortes, comportamiento)
- Análisis de rendimiento de productos y demanda
- Análisis de cesta de mercado (afinidad entre productos)
- Análisis de inventario
- Validación de calidad de datos
- Vistas preparadas para BI y capas de reporting

## Componentes Analíticos Clave

### Vistas y Vistas Materializadas

- Ventas mensuales por categoría, KPIs diarios, productos top, ventas por empleado y por país
- `v_customer_rfm`: scores RFM y segmento por cliente
- `v_cohort_retention`: retención mensual por cohorte
- `mv_product_pairs`: support, confidence y lift de cada par de productos
- `v_tableau_*`: vistas listas para BI

### Analítica de Clientes

- Scoring y segmentación RFM (Champions, Loyal, At Risk, ...)
- Análisis de cohortes con tasas de retención mensual
- Patrones de comportamiento de compra

### Analítica de Productos

- Productos con mejor y peor rendimiento
- Tendencias de demanda a lo largo del tiempo

### Análisis de Cesta de Mercado

- Relaciones de compra conjunta de productos (support, confidence y lift)
- Insights para venta cruzada y recomendaciones

### Calidad de Datos

- Detección de duplicados
- Valores faltantes
- Registros inválidos o inconsistentes

## Integración con Python

Python se conecta a PostgreSQL mediante SQLAlchemy y pandas para simular flujos de trabajo analíticos reales.

### Tareas Principales

- Conexión y consultas a la base de datos
- Agregaciones resueltas en PostgreSQL (a pandas solo llegan los resultados)
- Análisis exploratorio con gráficos (revenue mensual por día, categorías)
- Analítica de clientes y productos
- Segmentos RFM, retención por cohortes y lift de la cesta
- Tiempo entre visitas
- Validaciones de calidad de datos y conciliación de las vistas de BI

## Hallazgos Clave

- **Escala**: 6.758.125 líneas de venta, 98.759 clientes, 452 productos y 23 empleados en 129 días; revenue total 4.332.446.453,51.
- **Visitas**: 5.203.059 visitas (cliente-día) con un ticket promedio de 824,37 y 1,29 líneas por visita.
- **Demanda estable**: el revenue por día con ventas se mantiene entre 33,19M y 33,31M todos los meses; mayo solo parece menor porque tiene 9 días de datos.
- **Clientes**: los Champions son el 8,0% de los clientes y el 13,5% del revenue; los clientes vuelven tras una mediana de 2 días (41,3% al día siguiente).
- **Cesta de mercado**: las co-compras de los 101.926 pares de productos coinciden con lo que predice el azar (observado / esperado = 1,002). Ningún par sobrevive a la corrección de Bonferroni (mejor p ajustado = 0,51), así que no hay evidencia para recomendar combos.
- **Calidad de datos**: 67.526 ventas sin fecha (1,00%), sin duplicados ni claves huérfanas, y las vistas de BI concilian con `fact_sales`.

## Resultados Clave

- Almacén de datos SQL de extremo a extremo
- Modelo dimensional en esquema estrella
- Segmentación avanzada de clientes (RFM)
- Análisis de retención basado en cohortes
- Insights de cesta de mercado
- Analítica de inventario y demanda
- Framework de calidad de datos
- Flujo de trabajo integrado Python + PostgreSQL
- Resultados analíticos preparados para BI

## Autor

**Armando Guarnera**  
Data Scientist, Argentina