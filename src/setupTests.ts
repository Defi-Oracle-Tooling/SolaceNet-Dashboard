import '@testing-library/jest-dom';
import { expect } from 'vitest';

// Extend Vitest's expect with jest-dom matchers
expect.extend({
  ...require('@testing-library/jest-dom/matchers'),
});