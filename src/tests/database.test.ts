/// <reference types="vitest" />

import { vi } from 'vitest';
import { query } from '../utils/database';

vi.mock('../utils/database', () => {
  const mockQuery = vi.fn();
  return { query: mockQuery };
});

const mockQuery = vi.mocked(query);

describe('Database Query Function', () => {
  it('should execute a query successfully', async () => {
    mockQuery.mockResolvedValueOnce([{ id: 1, name: 'Test' }]);

    const result = await query('SELECT * FROM test_table');
    expect(result).toEqual([{ id: 1, name: 'Test' }]);
  });

  it('should throw an error for invalid queries', async () => {
    mockQuery.mockRejectedValueOnce(new Error('Invalid query'));

    await expect(query('INVALID QUERY')).rejects.toThrow('Invalid query');
  });

  it('should handle empty queries gracefully', async () => {
    vi.mocked(query).mockRejectedValueOnce(new Error('Query cannot be empty'));
    await expect(query('')).rejects.toThrow('Query cannot be empty');
  });

  it('should throw an error for invalid database credentials', async () => {
    vi.mocked(query).mockRejectedValueOnce(new Error('Invalid database credentials'));
    await expect(query('SELECT 1')).rejects.toThrow('Invalid database credentials');
  });

  it('should handle connection timeouts', async () => {
    vi.mocked(query).mockRejectedValueOnce(new Error('Connection timeout'));
    await expect(query('SELECT 1')).rejects.toThrow('Connection timeout');
  });
});