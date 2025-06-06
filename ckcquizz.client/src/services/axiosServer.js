import axios from 'axios';

const apiClient = axios.create({
  baseURL: 'https://localhost:7254',
  withCredentials: true 
});

export default apiClient;