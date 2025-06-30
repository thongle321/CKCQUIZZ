import axios from 'axios';
import { useAuthStore } from '@/stores/authStore';

const getAccessToken = () => {
    return localStorage.getItem('accessToken') || sessionStorage.getItem('accessToken');
}
const apiClient = axios.create({
  baseURL: 'https://localhost:7254/api',
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
      
      // Đọc refreshToken từ cả hai nơi
      const refreshToken = localStorage.getItem('refreshToken') || sessionStorage.getItem('refreshToken');

      if (!refreshToken) {
        console.error("No refresh token available. Logging out.");
        await authStore.logout();
        return Promise.reject(error);
      }

      try {
        const response = await apiClient.post('/Auth/refresh-token', { refreshToken });
        const newTokens = response.data.tokenResponse; // Giả sử backend trả về { tokenResponse: { ... } }
                                                       // Sửa lại cho khớp API của bạn
        
        // Quyết định lưu vào đâu dựa trên lựa chọn ban đầu
        const storage = localStorage.getItem('rememberMe') === 'true' ? localStorage : sessionStorage;
        
        storage.setItem('accessToken', newTokens.accessToken);
        storage.setItem('refreshToken', newTokens.refreshToken);
        
        originalRequest.headers['Authorization'] = `Bearer ${newTokens.accessToken}`;
        return apiClient(originalRequest);

      } catch (refreshError) {
        console.error("Failed to refresh token. Logging out.", refreshError);
        await authStore.logout(); 
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);
export default apiClient;
