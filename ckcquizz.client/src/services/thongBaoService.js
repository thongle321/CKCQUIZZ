import apiClient from './axiosServer';

export const thongBaoApi = {
  getAll: async (params) => {
    try {
      const response = await apiClient.get('/ThongBao/me', { params });
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  getDetail: async (matb) => {
    try {
      const response = await apiClient.get(`/ThongBao/detail/${matb}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  create: async (payload) => {
    try {
      const response = await apiClient.post('/ThongBao', payload);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  update: async (matb, payload) => {
    try {
      const response = await apiClient.put(`/ThongBao/${matb}`, payload);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  delete: async (matb) => {
    try {
      const response = await apiClient.delete(`/ThongBao/${matb}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  getAnnouncementsByClassId: async (classId) => {
    try {
      const response = await apiClient.get(`/ThongBao/byGroup/${classId}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
  getSubjectsWithGroups: async () => {
    try {
      const response = await apiClient.get('/Lop/subjects-with-groups?hienthi=true');
      return response.data;
    } catch (error) {
      throw error;
    }
  },
};