import { ConnectionOptions } from "typeorm";

const config: ConnectionOptions = {
  type: "mssql",
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || "1433", 10),
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  synchronize: false,  // set to true in dev only
  logging: false,
  options: {
    encrypt: true,
    trustServerCertificate: false
  },
  entities: [
    "src/entities/*.ts"
  ],
  migrations: [
    "src/migrations/*.ts"
  ],
  cli: {
    entitiesDir: "src/entities",
    migrationsDir: "src/migrations"
  }
};

export default config;
