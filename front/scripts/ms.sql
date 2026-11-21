-- Измерение "Диапазоны" (единицы измерения)
select
	id,
	sizeid as name,
	portionrate as factor
from size
order by id;

select
	concat(
		'insert into dim_ranges(external_id, name, factor) values (',
		id, ', ''', replace(sizeid, '''', ''''''), ''', ', portionrate, ');'
	) as sql
from size
order by id;

-- Измерение "Категории"
select
	id,
	description as name,
	case when coalesce(ParentID, 0) = 0 then null else ParentID end as parent_id
from category
order by id;

select
	concat(
		'insert into dim_categories(external_id, name, parent_id) values (',
		id, ', ''', replace(description, '''', ''''''), ''', ',
		coalesce(cast(nullif(ParentID, 0) as varchar(20)), 'NULL'), ');'
	) as sql
from category
order by id;

-- Измерение "Поставщики"
select
	v.id,
	v.clientid as name,
	v.clientgroup as parent_id,
	g.description as parent_name
from vendors v
left join vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.id;

select
	concat(
		'insert into dim_vendors(external_id, name, parent_id, parent_name) values (',
		v.id, ', ''', replace(v.clientid, '''', ''''''), ''', ', v.clientgroup, ', ''',
		replace(coalesce(g.description, ''), '''', ''''''), ''');'
	) as sql
from vendors v
left join vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.id;

-- Измерение "Товары"
select
	id,
	description as name,
	CategoryID as category_id,
	vendorid as vendor_id,
	SizeID as range_id
from product
order by id;

select
	concat(
		'insert into dim_products(external_id, name, category_id, vendor_id, range_id) values (',
		id, ', ''', replace(description, '''', ''''''), ''', ', CategoryID, ', ', vendorid, ', ', SizeID, ');'
	) as sql
from product
order by id;

-- Измерение "Сотрудники"
select
	personid as id,
	lastname,
	firstname,
	securityaccess
from personnel
order by personid;

select
	concat(
		'insert into dim_personnel(external_id, lastname, firstname, securityaccess) values (',
		personid, ', ''', replace(lastname, '''', ''''''), ''', ''', replace(firstname, '''', ''''''), ''', ', securityaccess, ');'
	) as sql
from personnel
order by personid;

-- Измерение "Склады"
select
	id,
	description as name,
	Address as address
from storages
order by id;

select
	concat(
		'insert into dim_storages(external_id, name, address) values (',
		id, ', ''', replace(description, '''', ''''''), ''', ''', replace(coalesce(Address, ''), '''', ''''''), ''');'
	) as sql
from storages
order by id;

-- Измерение "Операции"
select
	id,
	Description as name,
	Factor as factor
from bm_StorageOperationsType
order by id;

select
	concat(
		'insert into dim_operations(external_id, name, factor) values (',
		id, ', ''', replace(Description, '''', ''''''), ''', ', Factor, ');'
	) as sql
from bm_StorageOperationsType
order by id;

-- Измерение "Уровни доступа"
select
	securityaccessid as id,
	description as name
from securityaccess
order by securityaccessid;

select
	concat(
		'insert into dim_securityaccess(external_id, name) values (',
		securityaccessid, ', ''', replace(description, '''', ''''''), ''');'
	) as sql
from securityaccess
order by securityaccessid;

-- Факт "Закупка продукции"
select
	format(DateAdd, 'yyyyMM') as time_code,
	ProductID as product_id,
	VendorID as vendor_id,
	count(distinct DocumentID) as documents,
	count(*) as operations,
	sum(Count) as qty,
	sum(Amount) as amount
from bm_StorageOperations
where OperationID = 1 and VendorID <> 0
group by format(DateAdd, 'yyyyMM'), ProductID, VendorID
order by time_code, product_id, vendor_id;

select
	concat(
		'insert into fact_purchase(time_code, product_id, vendor_id, documents, operations, qty, amount) values (',
		format(DateAdd, 'yyyyMM'), ', ',
		ProductID, ', ',
		VendorID, ', ',
		count(distinct DocumentID), ', ',
		count(*), ', ',
		sum(Count), ', ',
		sum(Amount), ');'
	) as sql
from bm_StorageOperations
where OperationID = 1 and VendorID <> 0
group by format(DateAdd, 'yyyyMM'), ProductID, VendorID
order by format(DateAdd, 'yyyyMM'), ProductID, VendorID;

-- Факт "Продажа товара"
select
	format(j.dater, 'yyyyMM') as time_code,
	p.id as product_id,
	count(*) as lines,
	count(distinct j.receiptn) as receipts,
	sum(j.quantity) as qty,
	sum(j.amount) as amount
from journal j
join product p on p.productid = j.id
where j.transtype = 101
group by format(j.dater, 'yyyyMM'), p.id
order by time_code, product_id;

select
	concat(
		'insert into fact_sales(time_code, product_id, lines, receipts, qty, amount) values (',
		format(j.dater, 'yyyyMM'), ', ',
		p.id, ', ',
		count(*), ', ',
		count(distinct j.receiptn), ', ',
		sum(j.quantity), ', ',
		sum(j.amount), ');'
	) as sql
from journal j
join product p on p.productid = j.id
where j.transtype = 101
group by format(j.dater, 'yyyyMM'), p.id
order by format(j.dater, 'yyyyMM'), p.id;

-- Факт "Работа персонала"
select
	format(DateAdd, 'yyyyMM') as time_code,
	PersonID as person_id,
	count(*) as sessions
from bm_JournalSessions
where PersonID <> 0
group by format(DateAdd, 'yyyyMM'), PersonID
order by time_code, person_id;

select
	concat(
		'insert into fact_personnel(time_code, person_id, sessions) values (',
		format(DateAdd, 'yyyyMM'), ', ',
		PersonID, ', ',
		count(*), ');'
	) as sql
from bm_JournalSessions
where PersonID <> 0
group by format(DateAdd, 'yyyyMM'), PersonID
order by format(DateAdd, 'yyyyMM'), PersonID;

-- Факт "Остатки"
select
	format(DateAdd, 'yyyyMM') as time_code,
	ProductID as product_id,
	StorageID as storage_id,
	OperationID as operation_id,
	count(*) as operations,
	sum(Count) as qty,
	sum(Amount) as amount
from bm_StorageOperations
group by format(DateAdd, 'yyyyMM'), ProductID, StorageID, OperationID
order by time_code, product_id, storage_id, operation_id;

select
	concat(
		'insert into fact_inventory(time_code, product_id, storage_id, operation_id, operations, qty, amount) values (',
		format(DateAdd, 'yyyyMM'), ', ',
		ProductID, ', ',
		StorageID, ', ',
		OperationID, ', ',
		count(*), ', ',
		sum(Count), ', ',
		sum(Amount), ');'
	) as sql
from bm_StorageOperations
group by format(DateAdd, 'yyyyMM'), ProductID, StorageID, OperationID
order by format(DateAdd, 'yyyyMM'), ProductID, StorageID, OperationID;