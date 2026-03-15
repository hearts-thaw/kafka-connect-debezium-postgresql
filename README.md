# Kafka CDC quick start

`./plugins` contains the Debezium PostgreSQL connector jars for Kafka Connect.

Install or refresh the pinned plugin version:

```bash
./scripts/install-debezium-postgres.sh
```

Start the stack:

```bash
docker compose up -d
```

Verify the plugin is visible:

```bash
curl http://localhost:8083/connector-plugins
```

Create a connector from `connectors/postgres-cdc.json` with:

```bash
curl -X POST http://localhost:8083/connectors \
  -H 'Content-Type: application/json' \
  -d @connectors/postgres-cdc.json
```
