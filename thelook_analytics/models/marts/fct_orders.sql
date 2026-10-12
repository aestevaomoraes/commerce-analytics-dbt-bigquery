{{
    config(
        materialized='table'
    )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items_aggregated as (
    select * from {{ ref('int_order_items_aggregated') }}
),

final as (
    select
        -- Chaves
        orders.order_id,
        orders.customer_id,

        -- Status e Atributos
        orders.order_status,
        orders.customer_gender,
        orders.is_cancelled_or_returned,
        orders.is_delivered,

        -- Timestamps
        orders.order_created_at,
        orders.order_shipped_at,
        orders.order_delivered_at,
        orders.order_returned_at,

        -- Métricas agregadas de itens e valores
        coalesce(order_items_aggregated.total_items, 0) as total_items,
        coalesce(order_items_aggregated.total_order_amount, 0.0) as total_order_amount,
        coalesce(order_items_aggregated.total_order_cost, 0.0) as total_order_cost,
        coalesce(order_items_aggregated.total_gross_margin, 0.0) as total_gross_margin

    from orders
    left join order_items_aggregated
        on orders.order_id = order_items_aggregated.order_id
)

select * from final