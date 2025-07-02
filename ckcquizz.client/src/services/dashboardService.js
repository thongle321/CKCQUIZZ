import apiClient from '../services/axiosServer';

const dashboardApi = {
  getAll: async () => {
    try {
      const response = await apiClient.get('/dashboard');
      return response.data;
    } catch (error) {
      console.error('Lỗi khi lấy dữ liệu dashboard:', error);
    }
  }
}
export { dashboardApi}
