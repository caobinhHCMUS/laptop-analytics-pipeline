with source as (
    select * from {{ source('sqlserver_raw', 'raw_gpu_model') }}
),

renamed as (
    select
        cast(id as bigint) as gpu_model_id,
        trim(cast(name as nvarchar(255))) as gpu_model_name,
        cast(brand_id as bigint) as brand_id,
        cast(is_active as bit) as is_active,
        cast(created_on as datetime2) as created_at,
        cast(changed_on as datetime2) as updated_at
    from source
)
select * from renamed