import apiClient from "./axiosServer";
const lopApi = {
    getAll: async (params) => {
        try {
            const response = await apiClient.get('/api/Lop', { params });
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch danh sách lớp:', error);
        }
    },
    getById: async (id) => {
        try {
            const response = await apiClient.get(`/api/Lop/${id}`);
            return response.data;
        } catch (error) {
            console.error(`Lỗi fetch lớp với ID ${id}:`, error);
        }
    },
    create: async (data) => {
        try {
            const response = await apiClient.post('/api/Lop', data);
            return response.data;
        } catch (error) {
            console.error('Lỗi tạo lớp mới:', error);
        }
    },
    update: async (id, data) => {
        try {
            const response = await apiClient.put(`/api/Lop/${id}`, data);
            return response.data;
        } catch (error) {
            console.error(`Lỗi cập nhật lớp với ID ${id}:`, error);
        }
    },
    delete: async (id) => {
        try {
            const response = await apiClient.delete(`/api/Lop/${id}`);
            return response.data;
        } catch (error) {
            console.error(`Lỗi xóa lớp với ID ${id}:`, error);
        }
    },
    toggleStatus: async (id, hienthi) => {
        try {
            const response = await apiClient.put(`/api/Lop/${id}/toggle-status?hienthi=${hienthi}`, null);
            return response.data;
        } catch (error) {
            console.error(`Lỗi chuyển đổi trạng thái lớp với ID ${id}:`, error);
        }
    },
    refreshInviteCode: async (id) => {
        try {
            const response = await apiClient.put(`/api/Lop/${id}/invite-code`);
            return response.data;
        } catch (error) {
            console.error(`Lỗi làm mới mã mời cho lớp với ID ${id}:`, error);
        }
    },

    getMonHocs: async () => {
        try {
            const response = await apiClient.get('/api/monhoc');
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch danh sách môn học:', error);
        }
    },

    getStudentsInClass: async (lopId, params) => {
        try {
            const response = await apiClient.get(`/api/Lop/${lopId}/students`, { params });
            return response.data;
        } catch (error) {
            console.error(`Lỗi fetch sinh viên trong lớp ${lopId}:`, error);
        }
    },

    addStudentToClass: async (lopId, payload) => {
        try {
            const response = await apiClient.post(`/api/Lop/${lopId}/students`, payload);
            return response.data;
        } catch (error) {
            console.error(`Lỗi thêm sinh viên vào lớp ${lopId}:`, error);
        }
    },

    addToClass: async (lopId, studentId) => {
        try {
            const payload = { manguoidungId: studentId };
            const response = await apiClient.post(`/api/Lop/${lopId}/students`, payload);
            return response.data;
        } catch (error) {
            console.error(`Lỗi thêm sinh viên ${studentId} vào lớp ${lopId}:`, error);
        }
    },
    kickStudentFromClass: async (lopId, studentId) => {
        try {
            const response = await apiClient.delete(`/api/Lop/${lopId}/students/${studentId}`);
            return response.data;
        } catch (error) {
            console.error(`Lỗi đuổi sinh viên ${studentId} khỏi lớp ${lopId}:`, error);
        }
    },
};

export { lopApi };