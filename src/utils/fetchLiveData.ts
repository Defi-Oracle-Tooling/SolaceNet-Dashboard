import axios from 'axios';

export async function fetchLiveData() {
  try {
    const response = await axios.get('/api/live-data');
    return response.data;
  } catch (error) {
    console.error('Error fetching live data:', error);
    return null;
  }
}