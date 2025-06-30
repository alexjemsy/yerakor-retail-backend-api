-- migrate:up

create table if not exists product
(
    id         text primary key,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists product_options
(
    id         text primary key,
    product_id text        not null references product (id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists product_options_values
(
    id         text primary key,
    option_id  text        not null references product_options (id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists product_variants
(
    id         text primary key,
    product_id text        not null references product (id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists product_variants_options_values
(
    variant_id text        not null references product_variants (id),
    value_id   text        not null references product_options_values (id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    primary key (value_id, variant_id)
);

create table if not exists product_meta_field
(
    id            text primary key,
    product_id    text        not null references product (id),
    meta_field_id text        not null references meta_field (id),
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    constraint unique_product_meta_field_identifier unique (product_id, meta_field_id)
);

create table if not exists product_variant_meta_field
(
    id            text primary key,
    variant_id    text        not null references product (id),
    meta_field_id text        not null references meta_field (id),
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    constraint unique_product_variant_meta_field_identifier unique (variant_id, meta_field_id)
);


-- migrate:down

