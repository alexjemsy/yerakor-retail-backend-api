-- migrate:up

create extension if not exists btree_gist;
create extension if not exists postgis;
create extension if not exists citext;
create extension if not exists pg_trgm;

create domain email as citext
    check ( value ~
            '^[a-zA-Z0-9.!#$%&''*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );

create domain decimaltext as text
    check ( value ~ '^-?[0-9]+(?:[\.][0-9]+)?$' );

create domain phonenumber as text
    check (value ~ '^\+[1-9]\d{6,14}$');

create table if not exists taxonomy_values
(
    handle      text primary key,
    name        citext                                      not null,
    shopify_id  text
        constraint unique_taxonomy_values_shopify_id unique not null,
    name_search tsvector generated always as (to_tsvector('simple', name)) stored,
    created_at  timestamptz                                 not null default now(),
    updated_at  timestamptz                                 not null default now()
);

create table if not exists taxonomy_attributes
(
    handle          text primary key,
    name            citext      not null,
    shopify_id      text
        constraint unique_taxonomy_attributes_shopify_id unique,
    description     citext,
    extended_handle text references taxonomy_attributes (handle),
    extended        boolean     not null generated always as (case when extended_handle is not null then true else false end) stored,
    name_search     tsvector generated always as (to_tsvector('simple', name)) stored,
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now(),
    constraint check_taxonomy_attributes_extended_valid check
        ((shopify_id is null and extended_handle is not null)
            or (shopify_id is not null and extended_handle is null))
);

create table if not exists taxonomy_attributes_values
(
    attribute_handle text        not null references taxonomy_attributes (handle),
    value_handle     text        not null references taxonomy_values (handle),
    created_at       timestamptz not null default now(),
    updated_at       timestamptz not null default now(),
    primary key (attribute_handle, value_handle)
);

create table if not exists taxonomy_categories
(
    handle           text primary key,
    name             citext                                     not null,
    full_name        citext                                     not null,
    level            int                                        not null,
    parent_handle    text references taxonomy_categories (handle),
    shopify_id       text
        constraint unique_taxonomy_categories_shopify_id unique not null,
    full_name_search tsvector generated always as (to_tsvector('simple', full_name)) stored,
    created_at       timestamptz                                not null default now(),
    updated_at       timestamptz                                not null default now()
);

create table if not exists taxonomy_categories_attributes
(
    category_handle  text        not null references taxonomy_categories (handle),
    attribute_handle text        not null references taxonomy_attributes (handle),
    created_at       timestamptz not null default now(),
    updated_at       timestamptz not null default now(),
    primary key (category_handle, attribute_handle)
);

-- migrate:down

