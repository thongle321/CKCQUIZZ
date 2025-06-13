import axios from 'axios';
const apiClient = axios.create({
  baseURL: 'https://localhost:7254/api',
  timeout: 10000,
  withCredentials: true
});

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response && error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      try {
        await apiClient.post('/Auth/refresh-token');
        return apiClient(originalRequest);
      } catch (refreshError) {
        await apiClient.post('/Auth/logout');
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default apiClient;