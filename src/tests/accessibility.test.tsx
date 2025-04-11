import React from 'react';
import { render } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'vitest-axe';
import { describe, it, expect } from 'vitest';
import App from '../App';

// Updated test file to use Vitest
expect.extend(toHaveNoViolations);

describe('Accessibility tests', () => {
  it('should have no accessibility violations', async () => {
    const { container } = render(<App />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
});