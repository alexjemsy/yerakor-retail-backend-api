-- migrate:up

create type meta_field_owner_type as enum ('PRODUCT', 'PRODUCT_VARIANT');

create type meta_field_data_type as enum (
    'BOOLEAN',
    'DIMENSION',
    'DATE',
    'DATE_TIME',
    'MONEY',
    'MULTI_LINE_TEXT',
    'SINGLE_LINE_TEXT',
    'VOLUME',
    'WEIGHT',
    'META_OBJECT_REFERENCE',
    'PRODUCT_REFERENCE',
    'TAXONOMY_VALUE_REFERENCE',
    'PRODUCT_VARIANT_REFERENCE'
    );

create table if not exists dimension_units
(
    id            text primary key,
    short_label   citext   not null,
    long_label    citext   not null,
    sort_order    smallint not null,
    is_inch       boolean  not null generated always as (case when id = 'inch' then true else false end) stored,
    is_feet       boolean  not null generated always as (case when id = 'feet' then true else false end) stored,
    is_yard       boolean  not null generated always as (case when id = 'yard' then true else false end) stored,
    is_millimeter boolean  not null generated always as (case when id = 'millimeter' then true else false end) stored,
    is_centimeter boolean  not null generated always as (case when id = 'centimeter' then true else false end) stored,
    is_meter      boolean  not null generated always as (case when id = 'meter' then true else false end) stored
);

insert into dimension_units (id, short_label, long_label, sort_order)
values ('inch', 'in', 'Inch', 1),
       ('feet', 'ft', 'Feet', 2),
       ('yard', 'yd', 'Yard', 3),
       ('millimeter', 'mm', 'Millimeter', 4),
       ('centimeter', 'cm', 'Centimeter', 5),
       ('meter', 'm', 'Meter', 6);

create table if not exists volume_units
(
    id                text primary key,
    short_label       citext   not null,
    long_label        citext   not null,
    sort_order        smallint not null,
    is_milliliter     boolean  not null generated always as (case when id = 'milliliter' then true else false end) stored,
    is_centiliter     boolean  not null generated always as (case when id = 'centiliter' then true else false end) stored,
    is_liter          boolean  not null generated always as (case when id = 'liter' then true else false end) stored,
    is_cubic_meter    boolean  not null generated always as (case when id = 'cubic_meter' then true else false end) stored,
    is_us_fluid_ounce boolean  not null generated always as (case when id = 'us_fluid_ounce' then true else false end) stored,
    is_us_pint        boolean  not null generated always as (case when id = 'us_pint' then true else false end) stored,
    is_us_quart       boolean  not null generated always as (case when id = 'us_quart' then true else false end) stored,
    is_us_gallon      boolean  not null generated always as (case when id = 'us_gallon' then true else false end) stored,
    is_uk_fluid_ounce boolean  not null generated always as (case when id = 'uk_fluid_ounce' then true else false end) stored,
    is_uk_pint        boolean  not null generated always as (case when id = 'uk_pint' then true else false end) stored,
    is_uk_quart       boolean  not null generated always as (case when id = 'uk_quart' then true else false end) stored,
    is_uk_gallon      boolean  not null generated always as (case when id = 'uk_gallon' then true else false end) stored
);

insert into volume_units (id, short_label, long_label, sort_order)
values ('milliliter', 'ml', 'Milliliter', 1),
       ('centiliter', 'cl', 'Centiliter', 2),
       ('liter', 'l', 'Liter', 3),
       ('cubic_meter', 'm3', 'Cubic Meter', 4),
       ('us_fluid_ounce', 'fl_oz (us)', 'Fluid Ounce (US)', 5),
       ('us_pint', 'pint (us)', 'Pint (US)', 6),
       ('us_quart', 'quart (us)', 'Quart (US)', 7),
       ('us_gallon', 'gallon (us)', 'Gallon (US)', 8),
       ('uk_fluid_ounce', 'fl_oz (uk)', 'Fluid Ounce (UK)', 9),
       ('uk_pint', 'pint (uk)', 'Pint (UK)', 10),
       ('uk_quart', 'quart (uk)', 'Quart (UK)', 11),
       ('uk_gallon', 'gallon (uk)', 'Gallon (UK)', 12);

create table if not exists weight_units
(
    id          text primary key,
    short_label citext   not null,
    long_label  citext   not null,
    sort_order  smallint not null,
    is_kilogram boolean  not null generated always as (case when id = 'kilogram' then true else false end) stored,
    is_gram     boolean  not null generated always as (case when id = 'gram' then true else false end) stored,
    is_tonne    boolean  not null generated always as (case when id = 'tonne' then true else false end) stored,
    is_pound    boolean  not null generated always as (case when id = 'pound' then true else false end) stored,
    is_ounce    boolean  not null generated always as (case when id = 'ounce' then true else false end) stored
);

insert into weight_units (id, short_label, long_label, sort_order)
values ('ounce', 'oz', 'Ounce', 1),
       ('pound', 'lb', 'Pound', 2),
       ('gram', 'g', 'Gram', 3),
       ('kilogram', 'kg', 'Kilogram', 4),
       ('tonne', 't', 'Tonne', 5);


create table if not exists meta_field_definition
(
    id          text primary key,
    name        citext
        constraint unique_meta_field_definition_name unique not null,
    description citext,
    namespace   citext                                      not null,
    key         citext                                      not null,
    owner_type  meta_field_owner_type                       not null,
    data_type   meta_field_data_type                        not null,
    constraint unique_meta_field_definition_identifier unique (namespace, key)
);

create table if not exists meta_field
(
    id            text primary key,
    definition_id text        not null references meta_field_definition (id),
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);

create table if not exists meta_field_boolean
(
    meta_field_id text        not null references meta_field (id),
    value         boolean     not null,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    primary key (meta_field_id)
);

create table if not exists meta_field_single_line_text
(
    meta_field_id text        not null references meta_field (id),
    value         citext      not null default '',
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    primary key (meta_field_id)
);

create table if not exists meta_field_multi_line_text
(
    meta_field_id text        not null references meta_field (id),
    value         citext      not null default '',
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    primary key (meta_field_id)
);

create table if not exists meta_field_date
(
    meta_field_id text        not null references meta_field (id),
    value         date        not null,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    primary key (meta_field_id)
);

create table if not exists meta_field_date_time
(
    meta_field_id text         not null references meta_field (id),
    value         timestamp(0) not null,
    created_at    timestamptz  not null default now(),
    updated_at    timestamptz  not null default now(),
    primary key (meta_field_id)
);

create table if not exists meta_field_money
(
    meta_field_id text        not null references meta_field (id),
    amount        decimaltext not null,
    currency_code citext      not null,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    primary key (meta_field_id)
);

create table if not exists meta_field_dimension
(
    meta_field_id text        not null references meta_field (id),
    unit_id       text        not null references dimension_units (id),
    value         decimaltext not null,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    primary key (meta_field_id)
);

create table if not exists meta_field_volume
(
    meta_field_id text        not null references meta_field (id),
    unit_id       text        not null references volume_units (id),
    value         decimaltext not null,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    primary key (meta_field_id)
);

create table if not exists meta_field_weight
(
    meta_field_id text        not null references meta_field (id),
    unit_id       text        not null references weight_units (id),
    value         decimaltext not null,
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    primary key (meta_field_id)
);

-- migrate:down

