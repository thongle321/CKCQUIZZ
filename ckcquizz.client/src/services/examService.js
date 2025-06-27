import apiClient from "./axiosServer";

const examApi = {
    getExam: async (examId) => {
        try {
            // Dựa trên controller mới, route sẽ là /api/StudentExam/{id}
            const response = await apiClient.get(`/StudentExam/${examId}`);
            return response.data;
        } catch (error) {
            console.error(`Error fetching exam with ID ${examId}:`, error);
            throw error; // Ném lỗi ra để component có thể xử lý
        }
    },

    submitExam: async (payload) => {
        try {
            const response = await apiClient.post('/StudentExam/submit', payload);
            return response.data;
        } catch (error) {
            console.error('Lỗi khi nộp bài:', error);
            throw error;
        }
    },
};

export { examApi }; 