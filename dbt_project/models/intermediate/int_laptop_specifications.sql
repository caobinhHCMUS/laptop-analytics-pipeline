with laptops as (
    select * from {{ ref('stg_laptop_models') }}
),

brands as (
    select * from {{ ref('stg_brands') }}
),

cpus as (
    select * from {{ ref('stg_cpu_models') }}
),

gpus as (
    select * from {{ ref('stg_gpu_models') }}
),

joined as (
    select
        l.laptop_model_id,
        l.laptop_name,
        l.brand_model_codename,
        
        -- Brand info
        b.brand_id,
        coalesce(b.brand_name, 'Unknown') as brand_name,
        
        -- CPU info
        l.cpu_model_id,
        coalesce(c.cpu_model_name, 'Unknown') as cpu_model_name,
        l.cpu_tdp,
        l.cpu_note,
        
        -- GPU info
        l.gpu_model_id,
        coalesce(g.gpu_model_name, 'Integrated/Unknown') as gpu_model_name,
        l.gpu_tdp,
        l.gpu_note,
        
        -- Phân loại & Đặc tả
        l.release_year,
        l.is_gaming_laptop,
        l.is_workstation,
        l.is_mobile_device,
        l.battery_capacity_whr,
        l.screen_size,
        l.screen_dimension_width,
        l.screen_dimension_height,
        l.screen_ppi,
        l.laptop_weight,
        l.charger_weight,
        l.thumbnail_image_url,
        l.is_active,
        l.is_visible,
        l.created_at,
        l.updated_at
    from laptops l
    left join brands b on l.brand_id = b.brand_id
    left join cpus c on l.cpu_model_id = c.cpu_model_id
    left join gpus g on l.gpu_model_id = g.gpu_model_id
)

select * from joined