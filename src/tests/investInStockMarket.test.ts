import { describe, it, expect, vi } from 'vitest';
import { investInStockMarket } from '../services/trust_services';

// Mock fetch API
global.fetch = vi.fn();

describe('investInStockMarket', () => {
  it('should successfully invest in the stock market with valid details', async () => {
    // Arrange
    const clientId = 'client123';
    const investmentDetails = { amount: 1000, stockSymbol: 'AAPL' };
    const mockResponse = { ok: true };

    (fetch as jest.Mock).mockResolvedValueOnce(mockResponse);

    // Act
    const result = await investInStockMarket(clientId, investmentDetails);

    // Assert
    expect(result).toBe(
      `Investment of ${investmentDetails.amount} in ${investmentDetails.stockSymbol} completed successfully for client: ${clientId}`
    );
  });

  it('should throw an error for invalid investment details', async () => {
    // Arrange
    const clientId = '';
    const investmentDetails = { amount: 0, stockSymbol: '' };

    // Act & Assert
    await expect(investInStockMarket(clientId, investmentDetails)).rejects.toThrow(
      'Invalid investment details provided.'
    );
  });

  it('should throw an error if the API call fails', async () => {
    // Arrange
    const clientId = 'client123';
    const investmentDetails = { amount: 1000, stockSymbol: 'AAPL' };
    const mockResponse = { ok: false, status: 500 };

    (fetch as jest.Mock).mockResolvedValueOnce(mockResponse);

    // Act & Assert
    await expect(investInStockMarket(clientId, investmentDetails)).rejects.toThrow(
      'Investment failed with status: 500'
    );
  });
});
