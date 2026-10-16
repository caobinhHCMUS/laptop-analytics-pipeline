with source as (
    select * from {{ source('sqlserver_raw', 'raw_brand') }}
),

renamed as (
    select
        cast(id as bigint) as brand_id,
        trim(cast(name as nvarchar(255))) as brand_name,
        cast(is_chip_brand as bit) as is_chip_brand,
        cast(created_on as datetime2) as created_at,
        cast(changed_on as datetime2) as updated_at
    from source
)

select * from renamed

