import { vi } from 'vitest';
import { query } from '../utils/database';

describe('Database Query Function', () => {
  it('should execute a query successfully', async () => {
    const result = await query('SELECT 1 AS number');
    expect(result).toEqual([{ number: 1 }]);
  });

  it('should throw an error for invalid queries', async () => {
    await expect(query('INVALID QUERY')).rejects.toThrow();
  });

  it('should handle empty queries gracefully', async () => {
    await expect(query('')).rejects.toThrow('Query cannot be empty');
  });

  it('should throw an error for invalid database credentials', async () => {
    // Mock the database connection to simulate invalid credentials
    vi.mock('../utils/database', () => ({
      query: vi.fn(() => {
        throw new Error('Invalid database credentials');
      }),
    }));

    await expect(query('SELECT 1')).rejects.toThrow('Invalid database credentials');
  });

  it('should handle connection timeouts', async () => {
    // Mock the database connection to simulate a timeout
    vi.mock('../utils/database', () => ({
      query: vi.fn(() => {
        throw new Error('Connection timeout');
      }),
    }));

    await expect(query('SELECT 1')).rejects.toThrow('Connection timeout');
  });
});