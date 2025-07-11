import apiClient from './axiosServer';

export const dashboardApi = {
  getAll: async () => {
    try {
      const response = await apiClient.get('/Dashboard');
      return response.data;
    } catch (error) {
      console.error("Error fetching dashboard data:", error);
      throw error;
    }
  }
};
