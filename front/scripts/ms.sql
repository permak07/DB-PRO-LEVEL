-- Измерение "Базовые единицы измерения"
select
	ID as external_id,
	GroupID as group_id,
	ShortName as short_name,
	Description as name
from [Front].[dbo].[bm_classifierSizes]
order by ID;

select
	concat(
		'insert into dim_base_units(external_id, group_id, short_name, name) values (',
		ID, ', ', GroupID, ', ''', replace(ShortName, '''', ''''''), ''', ''',
		replace(Description, '''', ''''''), ''');'
	) as sql
from [Front].[dbo].[bm_classifierSizes]
order by ID;

-- Измерение "Категории"
select
	id as external_id,
	description as name,
	case when coalesce(ParentID, 0) = 0 then null else ParentID end as parent_id
from [Front].[dbo].[category]
order by id;

select
	concat(
		'insert into dim_categories(external_id, name, parent_id) values (',
		id, ', ''', replace(description, '''', ''''''), ''', ',
		coalesce(cast(nullif(ParentID, 0) as varchar(20)), 'NULL'), ');'
	) as sql
from [Front].[dbo].[category]
order by id;

-- Измерение "Поставщики"
select
	v.id as external_id,
	v.clientid as name,
	v.clientgroup as parent_id,
	g.description as parent_name
from [Front].[dbo].[vendors] v
left join [Front].[dbo].[vendorgroup] g on g.vendorgroupid = v.clientgroup
order by v.id;

select
	concat(
		'insert into dim_vendors(external_id, name, parent_id, parent_name) values (',
		v.id, ', ''', replace(v.clientid, '''', ''''''), ''', ', v.clientgroup, ', ''',
		replace(coalesce(g.description, ''), '''', ''''''), ''');'
	) as sql
from [Front].[dbo].[vendors] v
left join [Front].[dbo].[vendorgroup] g on g.vendorgroupid = v.clientgroup
order by v.id;

-- Измерение "Товары"
select
	id as external_id,
	description as name
from [Front].[dbo].[product]
order by id;

select
	concat(
		'insert into dim_products(external_id, name) values (',
		id, ', ''', replace(description, '''', ''''''), ''');'
	) as sql
from [Front].[dbo].[product]
order by id;

-- Измерение "Сотрудники"
select
	personid as external_id,
	lastname,
	firstname,
	securityaccess
from [Front].[dbo].[personnel]
order by personid;

select
	concat(
		'insert into dim_personnel(external_id, lastname, firstname, securityaccess) values (',
		personid, ', ''', replace(lastname, '''', ''''''), ''', ''', replace(firstname, '''', ''''''), ''', ', securityaccess, ');'
	) as sql
from [Front].[dbo].[personnel]
order by personid;

-- Измерение "Склады"
select
	id as external_id,
	description as name,
	Address as address
from [Front].[dbo].[storages]
order by id;

select
	concat(
		'insert into dim_storages(external_id, name, address) values (',
		id, ', ''', replace(description, '''', ''''''), ''', ''', replace(coalesce(Address, ''), '''', ''''''), ''');'
	) as sql
from [Front].[dbo].[storages]
order by id;

-- Измерение "Операции"
select
	id as external_id,
	Description as name,
	Factor as factor
from [Front].[dbo].[bm_StorageOperationsType]
order by id;

select
	concat(
		'insert into dim_operations(external_id, name, factor) values (',
		id, ', ''', replace(Description, '''', ''''''), ''', ', Factor, ');'
	) as sql
from [Front].[dbo].[bm_StorageOperationsType]
order by id;

-- Измерение "Уровни доступа"
select
	securityaccessid as external_id,
	description as name
from [Front].[dbo].[securityaccess]
order by securityaccessid;

select
	concat(
		'insert into dim_securityaccess(external_id, name) values (',
		securityaccessid, ', ''', replace(description, '''', ''''''), ''');'
	) as sql
from [Front].[dbo].[securityaccess]
order by securityaccessid;
