with source as (
    select * from {{ source('sqlserver_raw', 'raw_user_event_tracking') }}
),

renamed as (
    select
        cast(id as bigint) as event_id,
        cast(user_id as bigint) as user_id,
        cast(session_id as nvarchar(255)) as session_id,
        cast(user_psuedo_id as nvarchar(255)) as user_pseudo_id,
        trim(cast(event_name as nvarchar(100))) as event_name,
        cast(event_data as nvarchar(max)) as event_data_raw,
        trim(cast(device as nvarchar(100))) as device_type,
        trim(cast(app_version as nvarchar(50))) as app_version,
        dateadd(second, event_local_timestamp / 1000, cast('1970-01-01 00:00:00' as datetime2)) as event_local_at,
        dateadd(second, event_received_on_server_timestamp / 1000, cast('1970-01-01 00:00:00' as datetime2)) as event_received_at
    from source
)

select * from renamed