with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

joined as (
    select
        items.order_item_id,
        items.order_id,
        items.customer_id,
        items.sale_price,
        items.item_status,
        products.cost,
        items.sale_price - products.cost as gross_margin
    from order_items as items
    left join products
        on items.product_id = products.product_id
),

aggregated as (
    select
        order_id,
        customer_id,

        -- Métricas agregadas do pedido
        count(order_item_id) as total_items,
        round(sum(sale_price), 2) as total_order_amount,
        round(sum(cost), 2) as total_order_cost,
        round(sum(gross_margin), 2) as total_gross_margin

    from joined
    group by
        order_id,
        customer_id
)

select * from aggregated