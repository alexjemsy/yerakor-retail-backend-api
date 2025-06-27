# yerakor-retail-backend-api

yerakor retail app backend api

## Install postgres locally with minimum version 17

-- Take a look at [installation steps](https://www.postgresql.org/download/)
-- Example connection string `PG_CONNECTION_STRING=postgresql://alexjemsy:password@localhost:5932/yerakor_retail_dev?sslmode=disable`

## DB migrations postgres

- Using DBMate - https://github.com/amacneil/dbmate
- Create new migration file e.g. `new_file_name` - `npx dotenvx run --convention=nextjs -- npx dbmate -e PG_CONNECTION_STRING -d postgres_migrations new new_file_name`
- Run migration the first time e.g. for local development - `npm run postgres:migrate:dev`
- Drop existing database for local development - `npx dotenvx run --convention=nextjs -- npx dbmate -e PG_CONNECTION_STRING drop`

## Generate DB schema for generating SQL typescript types

- https://github.com/jawj/zapatos
- `npm run zapatos:schema`

## We run the development server for this repo locally:

```bash
nvm use
npm ci
npm run dev
```
