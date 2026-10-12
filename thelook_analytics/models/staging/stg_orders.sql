with source as (
    select * from {{ source('thelook_ecommerce', 'orders') }}
),

renamed as (
    select
        -- Chaves
        order_id,
        user_id as customer_id,

        -- Status e dimensões
        status as order_status,
        gender as customer_gender,

        -- Timestamps do ciclo de vida
        created_at as order_created_at,
        returned_at as order_returned_at,
        shipped_at as order_shipped_at,
        delivered_at as order_delivered_at,

        -- Métricas atômicas
        num_of_item as total_items_count,

        -- Flags operacionais
        case 
            when status in ('Cancelled', 'Returned') then 1 
            else 0 
        end as is_cancelled_or_returned,

        case 
            when delivered_at is not null then 1 
            else 0 
        end as is_delivered

    from source
)

select * from renamed