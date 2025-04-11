import React, { useState } from 'react';
import axios from 'axios';
import './AssetCustodyManagement.css';

const AssetCustodyManagement = () => {
  const [custodyId, setCustodyId] = useState('');
  const [assetDetails, setAssetDetails] = useState('');
  const [ownerId, setOwnerId] = useState('');
  const [message, setMessage] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('/api/asset-custody', {
        custodyId,
        assetDetails,
        ownerId,
      });
      setMessage(response.data.message);
    } catch (error) {
      setMessage('Error saving asset custody details.');
      console.error(error);
    }
  };

  return (
    <div className="asset-custody-management">
      <h2>Asset Custody Management</h2>
      <form onSubmit={handleSubmit}>
        <div>
          <label htmlFor="custodyId">Custody ID:</label>
          <input
            type="text"
            id="custodyId"
            value={custodyId}
            onChange={(e) => setCustodyId(e.target.value)}
            required
          />
        </div>
        <div>
          <label htmlFor="assetDetails">Asset Details:</label>
          <textarea
            id="assetDetails"
            value={assetDetails}
            onChange={(e) => setAssetDetails(e.target.value)}
            required
          ></textarea>
        </div>
        <div>
          <label htmlFor="ownerId">Owner ID:</label>
          <input
            type="text"
            id="ownerId"
            value={ownerId}
            onChange={(e) => setOwnerId(e.target.value)}
            required
          />
        </div>
        <button type="submit">Submit</button>
      </form>
      {message && <p>{message}</p>}
    </div>
  );
};

export default AssetCustodyManagement;
