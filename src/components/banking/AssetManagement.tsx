import React, { useState } from 'react';
import axios from 'axios';

const TrustPropertyManagement = () => {
  const [propertyDetails, setPropertyDetails] = useState({ name: '', value: '' });
  const [responseMessage, setResponseMessage] = useState('');

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setPropertyDetails({ ...propertyDetails, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('/api/trust-property', propertyDetails);
      setResponseMessage(response.data.message);
    } catch (error) {
      setResponseMessage(error.response?.data?.error || 'An error occurred');
    }
  };

  return (
    <div>
      <h2>Trust Property Management</h2>
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          name="name"
          placeholder="Property Name"
          value={propertyDetails.name}
          onChange={handleInputChange}
        />
        <input
          type="text"
          name="value"
          placeholder="Property Value"
          value={propertyDetails.value}
          onChange={handleInputChange}
        />
        <button type="submit">Manage Property</button>
      </form>
      {responseMessage && <p>{responseMessage}</p>}
    </div>
  );
};

export default TrustPropertyManagement;
