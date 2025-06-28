import apiClient from "./axiosServer";

export const examApi = {
    startExam: async (payload) => {
        try {
            const response = await apiClient.post('/Exam/start', payload);
            return response.data;
        } catch (error) {
            console.error('Lỗi khi bắt đầu bài thi:', error);
        }
    },

    getExam: async (examId) => {
        try {
            const response = await apiClient.get(`/Exam/${examId}`);
            return response.data;
        } catch (error) {
            console.error(`Lỗi lấy bài thi với id ${examId}:`, error);
        }
    },

    updateAnswer: async (payload) => {
        try {
            const response = await apiClient.post('/Exam/update-answer', payload);
            return response.data
        } catch (error) {
            console.error(`Lỗi cập nhật bài thi`, error);
        }
    },


    submitExam: async (payload) => {
        try {
            const response = await apiClient.post('/Exam/submit', payload);
            return response.data;
        } catch (error) {
            console.error(`Lỗi khi nộp bài`, error);
        }
    },

    getExamResult: async (ketQuaId) => {
        try {
            const response = await apiClient.get(`/Exam/exam-result/${ketQuaId}`)
            return response.data
        } catch (error) {
            console.error('Lỗi khi lấy kết quả:', error);
        }
    }

};
