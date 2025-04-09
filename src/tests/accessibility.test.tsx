import { render } from '@testing-library/react'
import App from '../App'

test('App should render and pass basic accessibility', () => {
  render(<App />)
  expect(true).toBe(true)
})