# Shop Schema SQL

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-DDL%2BDML-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

Modelo de **e-commerce** profesional: clientes, categorías, productos, órdenes e ítems.

## Archivos
| Archivo | Contenido |
|---------|-----------|
| `schema.sql` | DDL + constraints + índices + seed |
| `queries.sql` | Analytics: top productos, ticket promedio, stock bajo, JSON agg |

## Cómo probar (PostgreSQL)
```bash
psql -U postgres -c "CREATE DATABASE shop_demo;"
psql -U postgres -d shop_demo -f schema.sql
psql -U postgres -d shop_demo -f queries.sql
```

## Decisiones de diseño
- Precios en **centavos** (evita float)
- `CHECK` en status / stock / qty
- Índices en filtros frecuentes
- `ON DELETE CASCADE` en ítems de orden

## Autora
**Juliana Chantre Astudillo** · [GitHub](https://github.com/jchantre-jpg)
