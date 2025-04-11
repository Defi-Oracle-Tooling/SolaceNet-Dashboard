import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: {
    rejectUnauthorized: true,
  },
});

export const query = async (text: string, params?: any[]) => {
  const client = await pool.connect();
  try {
    const res = await client.query(text, params);
    return res;
  } finally {
    client.release();
  }
};

// Add a function to insert custody details into the database
export const insertCustodyDetails = async (custodyId: string, assetDetails: string, ownerId: string) => {
  const queryText = `INSERT INTO custody_details (custody_id, asset_details, owner_id, created_at) VALUES ($1, $2, $3, NOW())`;
  const params = [custodyId, assetDetails, ownerId];
  return query(queryText, params);
};

export const saveAssetToDatabase = async (asset: { id: string; name: string; value: number }) => {
  const queryText = 'INSERT INTO assets (id, name, value) VALUES ($1, $2, $3)';
  const params = [asset.id, asset.name, asset.value];
  return query(queryText, params);
};

export const validateAssetDetails = (asset: { id: string; name: string; value: number }) => {
  if (!asset.id || !asset.name || asset.value <= 0) {
    throw new Error('Invalid asset details');
  }
  return true;
};
