import { DataSource } from 'typeorm';
import config from '../../ormconfig.js';

export const AppDataSource = new DataSource({
  ...config
});
