import React, { useState } from 'react';
import './StockMarketInvestment.css';
import { investInStockMarket } from '../../services/trust_services';

const StockMarketInvestment = () => {
  const [clientId, setClientId] = useState('');
  const [stockSymbol, setStockSymbol] = useState('');
  const [amount, setAmount] = useState('');
  const [message, setMessage] = useState('');

  const handleInvestment = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage('');

    if (!clientId || !stockSymbol || !amount || Number(amount) <= 0) {
      setMessage('Please provide valid input for all fields.');
      return;
    }

    try {
      const result = await investInStockMarket(clientId, { amount: Number(amount), stockSymbol });
      setMessage(result);
    } catch (error: any) {
      setMessage(error.message || 'An error occurred while processing your investment.');
    }
  };

  return (
    <div className="stock-market-investment">
      <h2>Stock Market Investment</h2>
      <form onSubmit={handleInvestment}>
        <div className="form-group">
          <label htmlFor="clientId">Client ID:</label>
          <input
            type="text"
            id="clientId"
            value={clientId}
            onChange={(e) => setClientId(e.target.value)}
          />
        </div>
        <div className="form-group">
          <label htmlFor="stockSymbol">Stock Symbol:</label>
          <input
            type="text"
            id="stockSymbol"
            value={stockSymbol}
            onChange={(e) => setStockSymbol(e.target.value)}
          />
        </div>
        <div className="form-group">
          <label htmlFor="amount">Investment Amount:</label>
          <input
            type="number"
            id="amount"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
        </div>
        <button type="submit">Invest</button>
      </form>
      {message && <p className="message">{message}</p>}
    </div>
  );
};

export default StockMarketInvestment;
