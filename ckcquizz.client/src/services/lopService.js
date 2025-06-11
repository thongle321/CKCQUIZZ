import apiClient from "./axiosServer";
const lopApi = {
    getAll(params) {
        return apiClient.get('/api/Lop', { params });
    },
    getById(id) {
        return apiClient.get(`/api/Lop/${id}`);
    },
    create(data) {
        return apiClient.post('/api/Lop', data);
    },
    update(id, data) {
        return apiClient.put(`/api/Lop/${id}`, data);
    },
    delete(id) {
        return apiClient.delete(`/api/Lop/${id}`);
    },
    toggleStatus(id, status) {
        return apiClient.put(`/api/Lop/${id}/toggle-status`, status);
    },
    refreshInviteCode(id) {
        return apiClient.put(`/api/Lop/${id}/invite-code`);
    },

    getMonHocs: () => {
        return apiClient.get('/api/monhoc');
    },

    getStudentsInClass(lopId) { 
        return apiClient.get(`/api/Lop/${lopId}/students`);
    },

    addStudentToClass(lopId, payload) {
        return apiClient.post(`/api/Lop/${lopId}/students`, payload);
    },

    addToClass(lopId, studentId) {
        const payload = { manguoidungId: studentId };
        return apiClient.post(`/api/Lop/${lopId}/students`, payload);
    },
    kickStudentFromClass(lopId, studentId) { 
        return apiClient.delete(`/api/Lop/${lopId}/students/${studentId}`);
    },
    exportStudentsToExcel(lopId) { 
        return apiClient.get(`/api/Lop/${lopId}/students/export`, {
            responseType: 'blob',
        }).then(downloadFile);
    },
};

export { lopApi };