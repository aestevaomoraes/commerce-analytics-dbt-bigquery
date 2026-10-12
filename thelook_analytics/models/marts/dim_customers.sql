{{
    config(
        materialized='table'
    )
}}

with users as (
    select * from {{ ref('stg_users') }}
),

orders as (
    select * from {{ ref('fct_orders') }}
),

customer_orders_summary as (
    select
        customer_id,
        count(order_id) as total_orders,
        round(sum(total_order_amount), 2) as lifetime_spend,
        min(order_created_at) as first_order_date,
        max(order_created_at) as last_order_date
    from orders
    group by customer_id
),

final as (
    select
        -- Identificação
        users.customer_id,
        users.first_name,
        users.last_name,
        users.email,
        users.age,
        users.gender,

        -- Localização
        users.city,
        users.state,
        users.country,
        users.traffic_source,
        users.customer_created_at,

        -- Métricas de Comportamento e Valor (LTV)
        coalesce(summary.total_orders, 0) as total_orders_placed,
        coalesce(summary.lifetime_spend, 0.0) as lifetime_spend,
        summary.first_order_date,
        summary.last_order_date,

        -- Segmentação Atômica
        case 
            when summary.total_orders is null or summary.total_orders = 0 then 'Never Purchased'
            when summary.total_orders = 1 then 'One-Time Buyer'
            else 'Repeat Buyer'
        end as customer_segment

    from users
    left join customer_orders_summary as summary
        on users.customer_id = summary.customer_id
)

select * from final