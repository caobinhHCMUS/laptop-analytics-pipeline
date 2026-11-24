with benchmarks as (
    select * from {{ ref('stg_laptop_benchmarks') }}
    where is_active = 1
),

aggregated as (
    select
        laptop_model_id,
        round(avg(office_battery_result_minutes), 1) as avg_office_battery_minutes,
        round(avg(gaming_battery_result_minutes), 1) as avg_gaming_battery_minutes,
        round(avg(gb6_cpu_single_plugged_in), 0) as avg_gb6_cpu_single_plugged,
        round(avg(gb6_cpu_multi_plugged_in), 0) as avg_gb6_cpu_multi_plugged,
        round(avg(gb6_gpu_plugged_in), 0) as avg_gb6_gpu_plugged,
        round(avg(gb7_cpu_single_plugged_in), 0) as avg_gb7_cpu_single_plugged,
        round(avg(gb7_cpu_multi_plugged_in), 0) as avg_gb7_cpu_multi_plugged,
        round(avg(gb7_gpu_plugged_in), 0) as avg_gb7_gpu_plugged,
        count(benchmark_id) as total_benchmark_runs
    from benchmarks
    group by laptop_model_id
)

select * from aggregated