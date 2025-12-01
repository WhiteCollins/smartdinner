-- SmartDinner initial DB setup (mínimo para evitar fallos en el arranque)
-- Este archivo se monta como /docker-entrypoint-initdb.d/init.sql en el contenedor de Postgres
-- Puedes ampliar con tu esquema real o migraciones; por defecto, habilitamos extensiones comunes.

BEGIN;

-- Extensiones útiles (opcionales pero comunes)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Punto para incluir DDL inicial (si lo deseas)
-- Ejemplo:
-- CREATE SCHEMA IF NOT EXISTS smartdinner;
-- SET search_path TO smartdinner, public;

COMMIT;
