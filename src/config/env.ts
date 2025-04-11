import * as dotenv from 'dotenv';
dotenv.config();

import { DefaultAzureCredential } from '@azure/identity';
import { SecretClient } from '@azure/keyvault-secrets';

export const {
  NODE_ENV,
  PORT,
  DB_HOST,
  DB_PORT,
  DB_NAME,
  DB_USER,
  DB_PASS,
  KEY_VAULT_NAME,
  KEY_VAULT_SECRET_NAME,
  LOG_LEVEL,
  JWT_SECRET
} = process.env;

/**
 * Attempt to fetch secrets from Azure Key Vault,
 * if KEY_VAULT_NAME + KEY_VAULT_SECRET_NAME are set.
 */
async function fetchKeyVaultSecret(vaultName: string, secretName: string): Promise<string | undefined> {
  try {
    const credential = new DefaultAzureCredential();
    const url = `https://${vaultName}.vault.azure.net`;
    const client = new SecretClient(url, credential);
    const secret = await client.getSecret(secretName);
    return secret.value;
  } catch (err) {
    console.error(`Key Vault Error: ${err}`);
    return undefined;
  }
}

/**
 * loadSecrets: tries to override DB_PASS with Key Vault secret if configured.
 * You can expand this logic for more secrets as needed.
 */
export const loadSecrets = async (): Promise<void> => {
  const credential = new DefaultAzureCredential();
  const vaultName = process.env.KEY_VAULT_NAME;
  const url = `https://${vaultName}.vault.azure.net`;
  const client = new SecretClient(url, credential);

  const secretName = process.env.KEY_VAULT_SECRET_NAME;
  const secret = await client.getSecret(secretName!);

  process.env.JWT_SECRET = secret.value;
};
