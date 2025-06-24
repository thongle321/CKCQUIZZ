import apiClient from "./axiosServer";

const phanCongApi = {
    getAllAssignments: async () => {
        try {
            const response = await apiClient.get('/phancong');
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch danh sách phân công', error);
        }
    },

    getLecturers: async () => {
        try {
            const response = await apiClient.get('/phancong/lecturers');
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch giảng ', error);
        }
    },

    getSubjects: async (params) => {
        try {
            const response = await apiClient.get('/MonHoc', { params });
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch môn học', error);
        }
    },

    addAssignment: async (giangVienId, listMaMonHoc) => {
        try {
            const response = await apiClient.post('/phancong', {
                giangVienId,
                listMaMonHoc
            });
            return response.data;
        } catch (error) {
            console.error('Lỗi không thể thêm phân công:', error);
        }
    },

    deleteAssignment: async (maMonHoc, maNguoiDung) => {
        try {
            const response = await apiClient.delete(`/phancong/${maMonHoc}/${maNguoiDung}`);
            return response.data;
        } catch (error) {
            console.error('Lỗi xóa phân ', error);
        }
    },

    deleteAllAssignmentsByUser: async (maNguoiDung) => {
        try {
            const response = await apiClient.delete(`/phancong/delete-by-user/${maNguoiDung}`);
            return response.data;
        } catch (error) {
            console.error('Không thể xóa tất cả phân công người :', error);
        }
    },

    getAssignmentByUser: async (maNguoiDung) => {
        try {
            const response = await apiClient.get(`/phancong/by-user/${maNguoiDung}`);
            return response.data;
        } catch (error) {
            console.error('Lỗi fetch phân công người dùng', error);
        }
    },
};

export { phanCongApi };