with source as (
    select * from {{ source('thelook_ecommerce', 'users') }}
),

renamed as (
    select
        -- Chave primária
        id as customer_id,

        -- Dados demográficos
        first_name,
        last_name,
        email,
        age,
        gender,

        -- Localização geográfica
        state,
        street_address,
        postal_code,
        city,
        country,
        latitude,
        longitude,

        -- Atributos de canal e tráfego
        traffic_source,

        -- Timestamps
        created_at as customer_created_at

    from source
)

select * from renamed