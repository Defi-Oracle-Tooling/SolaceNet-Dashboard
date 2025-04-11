import React, { useState } from 'react';
import './StockMarketInvestment.css';

const StockMarketInvestment: React.FC = () => {
  const [clientId, setClientId] = useState('');
  const [investmentDetails, setInvestmentDetails] = useState('');
  const [responseMessage, setResponseMessage] = useState('');

  const handleInvestment = async () => {
    try {
      const response = await fetch('/api/investment/stock-market', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ clientId, investmentDetails }),
      });

      const data = await response.json();
      if (response.ok) {
        setResponseMessage(data.message);
      } else {
        setResponseMessage(data.error || 'Failed to process investment');
      }
    } catch (error) {
      console.error('Error:', error);
      setResponseMessage('An error occurred while processing the investment.');
    }
  };

  return (
    <div className="stock-market-investment">
      <h2>Stock Market Investment</h2>
      <div>
        <label>Client ID:</label>
        <input
          type="text"
          value={clientId}
          onChange={(e) => setClientId(e.target.value)}
          placeholder="Enter Client ID"
          title="Client ID"
        />
      </div>
      <div>
        <label>Investment Details:</label>
        <textarea
          value={investmentDetails}
          onChange={(e) => setInvestmentDetails(e.target.value)}
          placeholder="Enter Investment Details"
          title="Investment Details"
        />
      </div>
      <button onClick={handleInvestment}>Submit Investment</button>
      {responseMessage && <p>{responseMessage}</p>}
    </div>
  );
};

export default StockMarketInvestment;
