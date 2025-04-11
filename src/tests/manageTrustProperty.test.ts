import { describe, it, expect, vi } from 'vitest';

// Updated test file to use Vitest
import { manageTrustProperty } from '../services/trust_services';

describe('manageTrustProperty', () => {
    it('should successfully manage trust property with valid inputs', () => {
        const propertyDetails = {
            propertyId: 'prop123',
            action: 'update',
            details: {
                value: 1000000,
                location: 'New York',
            },
        };
        const userId = 'user123';

        const result = manageTrustProperty(propertyDetails, userId);

        expect(result).toMatchObject({
            ...propertyDetails,
            userId,
        });
        expect(result).toHaveProperty('transactionId');
        expect(result).toHaveProperty('timestamp');
    });

    it('should throw an error if property details are missing', () => {
        const userId = 'user123';

        expect(() => manageTrustProperty(null, userId)).toThrow('Invalid property details or user ID');
    });

    it('should throw an error if user ID is missing', () => {
        const propertyDetails = {
            propertyId: 'prop123',
            action: 'update',
            details: {
                value: 1000000,
                location: 'New York',
            },
        };

        expect(() => manageTrustProperty(propertyDetails, null)).toThrow('Invalid property details or user ID');
    });
});
