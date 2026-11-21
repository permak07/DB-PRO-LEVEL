-- Создание структуры OLAP-базы: измерения и факты
do $$
begin
	-- Удаление таблиц и счётчиков
	drop table if exists dim_ranges cascade;
	drop table if exists dim_categories cascade;
	drop table if exists dim_vendors cascade;
	drop table if exists dim_products cascade;
	drop table if exists dim_personnel cascade;
	drop table if exists dim_storages cascade;
	drop table if exists dim_operations cascade;
	drop table if exists dim_securityaccess cascade;
	drop table if exists fact_purchase cascade;
	drop table if exists fact_sales cascade;
	drop table if exists fact_personnel cascade;
	drop table if exists fact_inventory cascade;

	drop sequence if exists seq_dim_ranges cascade;
	drop sequence if exists seq_dim_categories cascade;
	drop sequence if exists seq_dim_vendors cascade;
	drop sequence if exists seq_dim_products cascade;
	drop sequence if exists seq_dim_personnel cascade;
	drop sequence if exists seq_dim_storages cascade;
	drop sequence if exists seq_dim_operations cascade;
	drop sequence if exists seq_dim_securityaccess cascade;
	drop sequence if exists seq_fact_purchase cascade;
	drop sequence if exists seq_fact_sales cascade;
	drop sequence if exists seq_fact_personnel cascade;
	drop sequence if exists seq_fact_inventory cascade;

	-- Измерение "Диапазоны" (единицы измерения)
	create table dim_ranges(
		id bigint not null,
		external_id bigint,
		name text,
		factor float,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_ranges;
	alter table dim_ranges alter column id set default nextval('seq_dim_ranges');
	alter table dim_ranges add primary key (id);
	comment on table dim_ranges is 'Справочник единиц измерения';

	-- Измерение "Категории"
	create table dim_categories(
		id bigint not null,
		external_id bigint,
		name text,
		parent_id bigint,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_categories;
	alter table dim_categories alter column id set default nextval('seq_dim_categories');
	alter table dim_categories add primary key (id);
	comment on table dim_categories is 'Справочник категорий продукции';

	-- Измерение "Поставщики"
	create table dim_vendors(
		id bigint not null,
		external_id bigint,
		name text,
		parent_id bigint,
		parent_name text,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_vendors;
	alter table dim_vendors alter column id set default nextval('seq_dim_vendors');
	alter table dim_vendors add primary key (id);
	comment on table dim_vendors is 'Справочник поставщиков';

	-- Измерение "Товары"
	create table dim_products(
		id bigint not null,
		external_id bigint,
		name text,
		category_id bigint,
		vendor_id bigint,
		range_id bigint,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_products;
	alter table dim_products alter column id set default nextval('seq_dim_products');
	alter table dim_products add primary key (id);
	comment on table dim_products is 'Справочник товаров (номенклатура)';

	-- Измерение "Сотрудники"
	create table dim_personnel(
		id bigint not null,
		external_id bigint,
		lastname text,
		firstname text,
		securityaccess integer,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_personnel;
	alter table dim_personnel alter column id set default nextval('seq_dim_personnel');
	alter table dim_personnel add primary key (id);
	comment on table dim_personnel is 'Справочник сотрудников';

	-- Измерение "Склады"
	create table dim_storages(
		id bigint not null,
		external_id bigint,
		name text,
		address text,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_storages;
	alter table dim_storages alter column id set default nextval('seq_dim_storages');
	alter table dim_storages add primary key (id);
	comment on table dim_storages is 'Справочник складов';

	-- Измерение "Операции"
	create table dim_operations(
		id bigint not null,
		external_id bigint,
		name text,
		factor integer,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_operations;
	alter table dim_operations alter column id set default nextval('seq_dim_operations');
	alter table dim_operations add primary key (id);
	comment on table dim_operations is 'Справочник видов складских операций';

	-- Измерение "Уровни доступа"
	create table dim_securityaccess(
		id bigint not null,
		external_id bigint,
		name text,
		date_add timestamp default current_timestamp
	);
	create sequence seq_dim_securityaccess;
	alter table dim_securityaccess alter column id set default nextval('seq_dim_securityaccess');
	alter table dim_securityaccess add primary key (id);
	comment on table dim_securityaccess is 'Справочник уровней доступа сотрудников';

	-- Факт "Закупка продукции"
	create table fact_purchase(
		id bigint not null,
		time_code integer not null,
		product_id bigint,
		vendor_id bigint,
		documents integer,
		operations integer,
		qty numeric(14,4),
		amount numeric(14,2),
		date_add timestamp default current_timestamp
	);
	create sequence seq_fact_purchase;
	alter table fact_purchase alter column id set default nextval('seq_fact_purchase');
	alter table fact_purchase add primary key (id);
	comment on table fact_purchase is 'Факт закупки продукции по месяцам';

	-- Факт "Продажа товара"
	create table fact_sales(
		id bigint not null,
		time_code integer not null,
		product_id bigint,
		lines integer,
		receipts integer,
		qty numeric(14,3),
		amount numeric(14,2),
		date_add timestamp default current_timestamp
	);
	create sequence seq_fact_sales;
	alter table fact_sales alter column id set default nextval('seq_fact_sales');
	alter table fact_sales add primary key (id);
	comment on table fact_sales is 'Факт продажи товара по месяцам';

	-- Факт "Работа персонала"
	create table fact_personnel(
		id bigint not null,
		time_code integer not null,
		person_id bigint,
		sessions integer,
		date_add timestamp default current_timestamp
	);
	create sequence seq_fact_personnel;
	alter table fact_personnel alter column id set default nextval('seq_fact_personnel');
	alter table fact_personnel add primary key (id);
	comment on table fact_personnel is 'Факт работы персонала по месяцам';

	-- Факт "Остатки"
	create table fact_inventory(
		id bigint not null,
		time_code integer not null,
		product_id bigint,
		storage_id bigint,
		operation_id bigint,
		operations integer,
		qty numeric(14,4),
		amount numeric(14,2),
		date_add timestamp default current_timestamp
	);
	create sequence seq_fact_inventory;
	alter table fact_inventory alter column id set default nextval('seq_fact_inventory');
	alter table fact_inventory add primary key (id);
	comment on table fact_inventory is 'Факт движения товара по складам';
end $$;