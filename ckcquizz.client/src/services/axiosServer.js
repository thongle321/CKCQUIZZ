import axios from 'axios';
import { useAuthStore } from '@/stores/authStore';

const getAccessToken = () => {
    return localStorage.getItem('accessToken') || sessionStorage.getItem('accessToken');
}
const apiClient = axios.create({
  baseURL: 'https://34.31.64.0:7254/api',
  timeout: 10000,
});

apiClient.interceptors.request.use(
  (config) => {
    const accessToken = getAccessToken();
    if (accessToken) {
      config.headers['Authorization'] = `Bearer ${accessToken}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    if (error.response && error.response.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      const authStore = useAuthStore();
      
      const refreshToken = localStorage.getItem('refreshToken') || sessionStorage.getItem('refreshToken');

      if (!refreshToken) {
        await authStore.logout();
        return Promise.reject(error);
      }

      try {
        const response = await apiClient.post('/Auth/refresh-token', { refreshToken });
        const newTokens = response.data.tokenResponse; 
                                                       
        
        const storage = localStorage.getItem('rememberMe') === 'true' ? localStorage : sessionStorage;
        
        storage.setItem('accessToken', newTokens.accessToken);
        storage.setItem('refreshToken', newTokens.refreshToken);
        
        originalRequest.headers['Authorization'] = `Bearer ${newTokens.accessToken}`;
        return apiClient(originalRequest);

      } catch (refreshError) {
        await authStore.logout(); 
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);
export default apiClient;
