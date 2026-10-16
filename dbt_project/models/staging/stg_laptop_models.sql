with source as (
    select * from {{ source('sqlserver_raw', 'raw_laptop_model') }}
),

renamed as (
    select
        cast(id as bigint) as laptop_model_id,
        trim(cast(name as nvarchar(255))) as laptop_name,
        cast(brand_id as bigint) as brand_id,
        cast(cpu_model_id as bigint) as cpu_model_id,
        cast(gpu_model_id as bigint) as gpu_model_id,
        cast(year_introduce as int) as release_year,
        cast(is_gaming_laptop as bit) as is_gaming_laptop,
        cast(is_workstation as bit) as is_workstation,
        cast(is_mobile_device as bit) as is_mobile_device,
        cast(is_active as bit) as is_active,
        cast(is_visible as bit) as is_visible,
        cast(battery_capacity_whr as float) as battery_capacity_whr,
        cast(screen_size as float) as screen_size,
        cast(screen_dimension_width as int) as screen_dimension_width,
        cast(screen_dimension_height as int) as screen_dimension_height,
        cast(screen_ppi as float) as screen_ppi,
        cast(laptop_weight as float) as laptop_weight,
        cast(charger_weight as float) as charger_weight,
        cast(cpu_tdp as float) as cpu_tdp,
        cast(gpu_tdp as float) as gpu_tdp,
        trim(cast(cpu_note as nvarchar(max))) as cpu_note,
        trim(cast(gpu_note as nvarchar(max))) as gpu_note,
        trim(cast(brand_model_codename as nvarchar(255))) as brand_model_codename,
        trim(cast(thumbnail_image_url as nvarchar(1000))) as thumbnail_image_url,
        cast(created_on as datetime2) as created_at,
        cast(changed_on as datetime2) as updated_at
    from source
)

select * from renamed