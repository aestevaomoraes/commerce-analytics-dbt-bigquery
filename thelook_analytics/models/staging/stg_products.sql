with source as (
    select * from {{ source('thelook_ecommerce', 'products') }}
),

renamed as (
    select
        -- Chave primária
        id as product_id,

        -- Custos e preços de tabela (tabela base em USD)
        cost,
        retail_price,

        -- Atributos descritivos do produto
        department,
        category,
        brand,
        name as product_name,
        sku,
        distribution_center_id

    from source
)

select * from renamed