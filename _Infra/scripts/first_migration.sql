drop table if exists parameters;
drop table if exists packs;
drop table if exists users;
drop table if exists equipment;
drop table if exists post;

create table post(
	id_post INT PRIMARY KEY,
	name TEXT
);

create table users(
	id_users INT PRIMARY KEY,
	name TEXT,
	id_post INT
);

create table equipment(
	id_equipment INT PRIMARY KEY,
	name TEXT
);

create table parameters (
	id_pearmetrs INT PRIMARY KEY,
	name TEXT,
	value NEXT,
	id_packs INT
);