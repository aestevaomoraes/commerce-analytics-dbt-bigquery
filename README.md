# 🛒 TheLook E-Commerce: Analytics Engineering Pipeline com dbt Core & Google BigQuery

[![dbt](https://img.shields.io/badge/dbt-v1.12-FF694B?logo=dbt&logoColor=white)](https://www.getdbt.com/)
[![Google BigQuery](https://img.shields.io/badge/Google%20BigQuery-Cloud%20Data%20Warehouse-4285F4?logo=googlecloud&logoColor=white)](https://cloud.google.com/bigquery)
[![Data Quality](https://img.shields.io/badge/Data%20Quality-24%20Tests%20Passing-success)](https://docs.getdbt.com/docs/build/data-tests)

Pipeline de Engenharia Analítica ponta a ponta construído sobre o dataset público **TheLook E-Commerce** no Google BigQuery. O projeto implementa princípios modernos de modelagem dimensional (Kimball / Medallion Architecture), contratos de dados rigorosos, testes automatizados e separação estrita de camadas analíticas utilizando **dbt Core**.

---

## 🏛️ Arquitetura do Pipeline (DAG)

O projeto segue a separação canónica de responsabilidades em três camadas de transformação:

```text
[BigQuery Raw Data]
       │
       ▼
 ┌─────────────┐
 │   Staging   │  Materialização: VIEW (Custo Zero de Scan)
 └──────┬──────┘  Padronização, renomeação canónica e tipagem
        │
        ▼
 ┌─────────────┐
 │Intermediate │  Materialização: VIEW
 └──────┬──────┘  Cálculos atómicos, granularidade e margens brutas
        │
        ▼
 ┌─────────────┐
 │    Marts    │  Materialização: TABLE (Alta Performance de Consulta)
 └─────────────┘  Star Schema para consumo (fct_orders, dim_customers)
```

---

## 📂 Estrutura de Camadas & Modelagem

### 1. Camada de Staging (`models/staging`)
- **Objetivo:** Isolar as fontes brutas, padronizar nomes de colunas no padrão de negócio e tipar campos sem aplicar joins entre tabelas.
- **Materialização:** `view` (gravação de metadados no BigQuery com custo zero de processamento e faturação).
- **Modelos:**
  - `stg_orders`: Padronização de datas de ciclo de vida (`created`, `shipped`, `delivered`, `returned`) e flags operacionais.
  - `stg_order_items`: Granularidade atómica do produto vendido, preços de venda e status unitário.
  - `stg_products`: Catálogo de produtos, departamentos, categorias e custos de mercadoria (`cost`, `retail_price`).
  - `stg_users`: Base demográfica, geográfica e canais de aquisição de clientes.

### 2. Camada Intermédia (`models/intermediate`)
- **Objetivo:** Resolver regras de negócio intermédias e divergências de granularidade antes da exposição em produção.
- **Modelo:**
  - `int_order_items_aggregated`: Enriquecimento dos itens com o custo unitário do produto via `stg_products`, cálculo de margem bruta (`sale_price - cost`) e agregação ao nível de granularidade do pedido (`order_id`).

### 3. Camada de Marts (`models/marts`)
- **Objetivo:** Fornecer tabelas dimensionais e de fatos prontas para BI, Data Science e tomadores de decisão em esquema estrela (*Star Schema*).
- **Materialização:** `table` (tabelas colunares físicas no BigQuery para consultas rápidas com baixa latência).
- **Modelos:**
  - `fct_orders`: Fato centralizada contendo status, flags operacionais e métricas financeiras consolidadas (receita líquida, custo e margem bruta).
  - `dim_customers`: Dimensão enriquecida com atributos cadastrais, métricas de ciclo de vida (*Lifetime Value*, frequência) e segmentação de clientes (`Never Purchased`, `One-Time Buyer`, `Repeat Buyer`).

---

## 🛡️ Qualidade de Dados & Governança (Data Tests)

A integridade do pipeline é validada continuamente através de **24 testes automatizados** definidos nos ficheiros `schema.yml`:

- **Unicidade (`unique`) e Não-Nulidade (`not_null`):** Garantidos em todas as chaves primárias (`order_id`, `order_item_id`, `product_id`, `customer_id`).
- **Integridade Referencial (`relationships`):** Validação de chaves estrangeiras entre `stg_order_items -> stg_orders`, `stg_orders -> stg_users` e `fct_orders -> dim_customers`.
- **Valores Aceites (`accepted_values`):** Homologação do domínio de status operacionais (`order_status` e `customer_segment`).

---

## 🛠️ Tecnologias & Ferramentas

- **dbt Core (v1.12):** Orquestração, compilação de código Jinja/SQL e validação de contratos.
- **Google BigQuery:** Data Warehouse analítico colunar (Cloud Data Platform).
- **SQL (GoogleSQL):** CTEs modulares, funções agregadas e analíticas.
- **GitHub Codespaces / Git:** Ambiente de desenvolvimento reprodutível e controlo de versões.

---

## 🚀 Como Reproduzir o Projeto

1. Clone o repositório:
   ```bash
   git clone https://github.com/aestevaomoraes/commerce-analytics-dbt-bigquery.git
   cd commerce-analytics-dbt-bigquery/thelook_analytics
   ```

2. Configure o seu ficheiro `profiles.yml` com as credenciais de acesso ao Google BigQuery.

3. Execute o pipeline completo:
   ```bash
   # Compilar e materializar todas as camadas
   dbt run

   # Executar suíte completa de testes de integridade
   dbt test

   # Gerar e visualizar a documentação e o catálogo
   dbt docs generate
   dbt docs serve
   ```