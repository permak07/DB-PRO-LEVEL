select 
    row_number() over (order by type_ru, name) as "№",
    name as "наименование",
    type_ru as "тип"
from (
    -- выборка таблиц с фильтрацией по бд и схеме
    select 
        table_name as name,
        case 
            when table_type = 'BASE TABLE' then 'таблица'
            when table_type = 'VIEW' then 'представление'
            else table_type 
        end as type_ru
    from information_schema.tables
    where table_catalog = current_database() 
      and table_schema = 'public'
    
    union all
	-- выборка счетчиков с фильтрацией по бд и схеме
    select 
        sequence_name as name, 
        'счетчик' as type_ru
    from information_schema.sequences
    where sequence_catalog = current_database()
      and sequence_schema = 'public'
) as metadata;