with source as (
    select * from {{ source('thelook_ecommerce', 'order_items') }}
),

renamed as (
    select
        -- Chaves primárias e relacionais
        id as order_item_id,
        order_id,
        user_id as customer_id,
        product_id,
        inventory_item_id,

        -- Status do item individual
        status as item_status,

        -- Métrica financeira atômica
        sale_price,

        -- Timestamps do ciclo de vida do item
        created_at as item_created_at,
        shipped_at as item_shipped_at,
        delivered_at as item_delivered_at,
        returned_at as item_returned_at

    from source
)

select * from renamed