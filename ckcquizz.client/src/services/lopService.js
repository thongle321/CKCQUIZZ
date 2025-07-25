import apiClient from "./axiosServer";
const lopApi = {
    getAll: async (params) => {
        try {
            const response = await apiClient.get('/Lop', { params });
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch danh sách lớp:', error);
        }
    },
    getById: async (id) => {
        try {
            const response = await apiClient.get(`/Lop/${id}`);
            return response.data;
        } catch (error) {
            console.error(`Lỗi fetch lớp với ID ${id}:`, error);
        }
    },
    create: async (data) => {
        try {
            const response = await apiClient.post('/Lop', data);
            return response.data;
        } catch (error) {
            console.error('Lỗi tạo lớp mới:', error);
        }
    },
    update: async (id, data) => {
        try {
            const response = await apiClient.put(`/Lop/${id}`, data);
            return response.data;
        } catch (error) {
            console.error(`Lỗi cập nhật lớp với ID ${id}:`, error);
        }
    },
    delete: async (id) => {
        try {
            const response = await apiClient.delete(`/Lop/${id}`);
            return response;
        } catch (error) {
            console.error(`Lỗi xóa lớp với ID ${id}:`, error);
            throw error;
        }
    },
    softDelete: async (id) => {
        try {
            const response = await apiClient.put(`/Lop/${id}/soft-delete`);
            return response;
        } catch (error) {
            console.error(`Lỗi xóa mềm lớp với ID ${id}:`, error);
            throw error;
        }
    },
    toggleStatus: async (id, hienthi) => {
        try {
            const response = await apiClient.put(`/Lop/${id}/toggle-status?hienthi=${hienthi}`, null);
            return response.data;
        } catch (error) {
            console.error(`Lỗi chuyển đổi trạng thái lớp với ID ${id}:`, error);
        }
    },
    refreshInviteCode: async (id) => {
        try {
            const response = await apiClient.put(`/Lop/${id}/invite-code`);
            return response.data;
        } catch (error) {
            console.error(`Lỗi làm mới mã mời cho lớp với ID ${id}:`, error);
        }
    },

    getMonHocs: async () => {
        try {
            const response = await apiClient.get('/monhoc');
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch danh sách môn học:', error);
        }
    },

    getMyAssignment: async () => {
        try {
            const response = await apiClient.get('/phancong/my-assignments');
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch môn học', error);
        }
    },

    getStudentsInClass: async (lopId, params) => {
        try {
            const response = await apiClient.get(`/Lop/${lopId}/students`, { params });
            return response.data;
        } catch (error) {
            console.error(`Lỗi fetch sinh viên trong lớp ${lopId}:`, error);
        }
    },

    addStudentToClass: async (lopId, payload) => {
        try {
            const response = await apiClient.post(`/Lop/${lopId}/students`, payload);
            return response.data;
        } catch (error) {
            console.error(`Lỗi thêm sinh viên vào lớp ${lopId}:`, error);
            throw error;
        }
    },

    addToClass: async (lopId, studentId) => {
        try {
            const payload = { manguoidungId: studentId };
            const response = await apiClient.post(`/Lop/${lopId}/students`, payload);
            return response.data;
        } catch (error) {
            console.error(`Lỗi thêm sinh viên ${studentId} vào lớp ${lopId}:`, error);
        }
    },
    kickStudentFromClass: async (lopId, studentId) => {
        try {
            await apiClient.delete(`/Lop/${lopId}/students/${studentId}`);
            return true;
        } catch (error) {
            console.error(`Lỗi đuổi sinh viên ${studentId} khỏi lớp ${lopId}:`, error);
        }
    },
    getTeachers: async () => {
        try {
            const response = await apiClient.get('/NguoiDung', { params: { role: 'Teacher' } });
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch danh sách giáo viên:', error);
        }
    },
    getTeachersInClass: async (lopId) => {
        try {
            const response = await apiClient.get(`/Lop/${lopId}/teachers`);
            return response.data;
        } catch (error) {
            console.error(`Lỗi fetch giáo viên trong lớp ${lopId}:`, error);
        }
    },

    importStudentsExcel: async (lopId, file) => {
        try {
            const formData = new FormData();
            formData.append('file', file);
            const response = await apiClient.post(`/Lop/${lopId}/import-students`, formData, {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            });
            return response.data;
        } catch (error) {
            console.error(`Lỗi nhập sinh viên từ Excel vào lớp ${lopId}:`, error);
            throw error;
        }
    }
};

export { lopApi };