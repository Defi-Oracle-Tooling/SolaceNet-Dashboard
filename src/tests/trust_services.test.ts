import { describe, it, expect, vi } from 'vitest';

// Updated test file to use Vitest
import { manageTrustProperty } from '../services/trust_services';

describe('Trust Property Management', () => {
  it('should successfully manage trust property with valid details', async () => {
    const propertyDetails = { name: 'Property A', value: 100000 };
    const result = await manageTrustProperty(propertyDetails);
    expect(result).toEqual({ message: 'Trust property managed successfully', propertyDetails });
  });

  it('should throw an error for invalid property details', async () => {
    const invalidDetails = { name: '', value: -5000 };
    await expect(manageTrustProperty(invalidDetails)).rejects.toThrow('Invalid property details');
  });

  it('should handle unexpected errors gracefully', async () => {
    const propertyDetails = { name: 'Property B', value: 200000 };
    const mockFunction = vi.spyOn(global, 'fetch').mockImplementation(() => {
      throw new Error('Unexpected error');
    });

    await expect(manageTrustProperty(propertyDetails)).rejects.toThrow('Unexpected error');
    mockFunction.mockRestore();
  });
});
