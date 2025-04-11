import { describe, it, expect, vi } from 'vitest';

// Updated test file to use Vitest
import { investInStockMarket } from '../services/trust_services';

global.fetch = vi.fn();

describe('investInStockMarket', () => {
  it('should successfully invest in the stock market with valid details', async () => {
    const clientId = 'client123';
    const investmentDetails = { amount: 1000, stockSymbol: 'AAPL' };
    const mockResponse = { ok: true };

    (fetch as unknown as vi.Mock).mockResolvedValueOnce(mockResponse);

    const result = await investInStockMarket(clientId, investmentDetails);

    expect(result).toBe(
      `Investment of ${investmentDetails.amount} in ${investmentDetails.stockSymbol} completed successfully for client: ${clientId}`
    );
  });

  it('should throw an error for invalid investment details', async () => {
    const clientId = '';
    const investmentDetails = { amount: 0, stockSymbol: '' };

    await expect(investInStockMarket(clientId, investmentDetails)).rejects.toThrow(
      'Invalid investment details provided.'
    );
  });

  it('should throw an error if the API call fails', async () => {
    const clientId = 'client123';
    const investmentDetails = { amount: 1000, stockSymbol: 'AAPL' };
    const mockResponse = { ok: false, status: 500 };

    (fetch as unknown as vi.Mock).mockResolvedValueOnce(mockResponse);

    await expect(investInStockMarket(clientId, investmentDetails)).rejects.toThrow(
      'Investment failed with status: 500'
    );
  });
});
