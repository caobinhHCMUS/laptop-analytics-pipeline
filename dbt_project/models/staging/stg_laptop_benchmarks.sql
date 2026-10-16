with source as (
    select * from {{ source('sqlserver_raw', 'raw_laptop_benchmark_result') }}
),

renamed as (
    select
        cast(id as bigint) as benchmark_id,
        cast(laptop_model_id as bigint) as laptop_model_id,
        cast(is_active as bit) as is_active,
        cast(office_battery_result_minutes as float) as office_battery_result_minutes,
        cast(gaming_battery_result_minutes as float) as gaming_battery_result_minutes,
        cast(geekbench_6_compute_gpu_plugged_in as float) as gb6_gpu_plugged_in,
        cast(geekbench_6_compute_gpu_battery as float) as gb6_gpu_battery,
        cast(geekbench_6_cpu_single_core_plugged_in as float) as gb6_cpu_single_plugged_in,
        cast(geekbench_6_cpu_single_core_battery as float) as gb6_cpu_single_battery,
        cast(geekbench_6_cpu_multi_core_plugged_in as float) as gb6_cpu_multi_plugged_in,
        cast(geekbench_6_cpu_multi_core_battery as float) as gb6_cpu_multi_battery,
        cast(geekbench_7_cpu_single_core_plugged_in as float) as gb7_cpu_single_plugged_in,
        cast(geekbench_7_cpu_single_core_battery as float) as gb7_cpu_single_battery,
        cast(geekbench_7_cpu_multi_core_plugged_in as float) as gb7_cpu_multi_plugged_in,
        cast(geekbench_7_cpu_multi_core_battery as float) as gb7_cpu_multi_battery,
        cast(geekbench_7_compute_gpu_plugged_in as float) as gb7_gpu_plugged_in,
        cast(geekbench_7_compute_gpu_battery as float) as gb7_gpu_battery,
        trim(cast(review_video_url as nvarchar(1000))) as review_video_url,
        trim(cast(note as nvarchar(max))) as note,
        cast(created_on as datetime2) as created_at,
        cast(changed_on as datetime2) as updated_at
    from source
)

select * from renamed