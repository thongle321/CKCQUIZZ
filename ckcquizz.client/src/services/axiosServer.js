import axios from 'axios';
const apiClient = axios.create({
  baseURL: 'https://localhost:7254',
  timeout: 10000,
  withCredentials: true
});

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Check if error.response exists before accessing its properties
    if (error.response && error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      try {
        await apiClient.post('/api/Auth/refresh-token');
        return apiClient(originalRequest);
      } catch (refreshError) {
        await apiClient.post('/api/Auth/logout');
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default apiClient;