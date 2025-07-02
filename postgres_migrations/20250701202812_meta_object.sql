-- migrate:up

create table if not exists meta_object_definition
(
    id               text primary key,
    name             citext
        constraint unique_meta_object_definition_name unique not null,
    type             citext
        constraint unique_meta_object_definition_type unique not null,
    description      citext,
    display_name_key citext,
    created_at       timestamptz                             not null default now(),
    updated_at       timestamptz                             not null default now(),
    constraint meta_object_definition_type_valid check (type ~ '^[A-Za-z0-9_-]{1,255}$')
);

create table if not exists meta_object_field_definition
(
    id                   text primary key,
    object_definition_id text                 not null references meta_object_definition (id),
    key                  citext               not null,
    is_required          boolean              not null default false,
    description          citext,
    data_type            meta_field_data_type not null,
    position             smallint             not null,
    created_at           timestamptz          not null default now(),
    updated_at           timestamptz          not null default now(),
    constraint meta_object_field_definition_key_valid check (key ~ '^[A-Za-z0-9_-]{1,64}$'),
    constraint unique_meta_object_field_definition_id_key unique (object_definition_id, key)
);

create table if not exists meta_object_field
(
    id              text primary key,
    definition_id   text        not null references meta_object_field_definition (id),
    custom_field_id text        not null references custom_field (id),
    created_at      timestamptz not null default now(),
    updated_at      timestamptz not null default now()
);

-- migrate:down
