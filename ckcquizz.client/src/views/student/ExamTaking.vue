<template>
    <div>
        <div v-if="loading">Đang tải đề thi...</div>
        <div v-if="error">Không thể tải được đề thi. Vui lòng thử lại.</div>
        
        <div v-if="examData">
            <!-- Header của bài thi -->
            <div class="exam-header">
                <h1>{{ examData.tende }}</h1>
                <div class="timer">Thời gian còn lại: <span>{{ formattedTime }}</span></div>
            </div>

            <!-- Danh sách câu hỏi -->
            <div class="question-list">
                <div v-for="(question, index) in examData.questions" :key="question.macauhoi" class="question-item">
                    <p><strong>Câu {{ index + 1 }}:</strong> {{ question.noidung }}</p>
                    
                    <!-- Các lựa chọn trả lời -->
                    <div class="answer-options">
                        <div v-for="answer in question.answers" :key="answer.macautl" class="answer-option">
                            <input 
                                type="radio" 
                                :name="'question_' + question.macauhoi" 
                                :value="answer.macautl"
                                @change="selectAnswer(question.macauhoi, answer.macautl)"
                            />
                            <label>{{ answer.noidungtl }}</label>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Nút nộp bài -->
            <button @click="submitExam" class="submit-btn">Nộp bài</button>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { examApi } from '@/services/examService.js';

const route = useRoute();
const router = useRouter(); 
const examData = ref(null);
const loading = ref(true);
const error = ref(false);

const timeLeft = ref(0);
let timerInterval = null;

const userAnswers = ref({});

const selectAnswer = (questionId, answerId) => {
    userAnswers.value[questionId] = answerId;
};

const formatTime = (seconds) => {
    if (seconds < 0) return '00:00';
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(remainingSeconds).padStart(2, '0')}`;
};

const formattedTime = computed(() => formatTime(timeLeft.value));

const startTimer = (durationInMinutes) => {
    timeLeft.value = durationInMinutes * 60;
    timerInterval = setInterval(() => {
        timeLeft.value--;
        if (timeLeft.value <= 0) {
            clearInterval(timerInterval);
            alert("Hết giờ làm bài! Bài của bạn sẽ được tự động nộp.");
            submitExam();
        }
    }, 1000);
};

const submitExam = async () => {
    // Ngừng đồng hồ và vô hiệu hóa nút nộp bài để tránh click nhiều lần
    if (timerInterval) clearInterval(timerInterval);
    const submitButton = document.querySelector('.submit-btn');
    if (submitButton) submitButton.disabled = true;

    // Chuyển đổi object userAnswers sang định dạng mảng mà backend cần
    const formattedAnswers = Object.keys(userAnswers.value).map(questionId => ({
        questionId: parseInt(questionId),
        selectedAnswerId: userAnswers.value[questionId]
    }));

    const payload = {
        examId: parseInt(route.params.id),
        answers: formattedAnswers
    };

    try {
        const result = await examApi.submitExam(payload);
        console.log("Nộp bài thành công, kết quả:", result);
        
        // Hiển thị thông báo và chuyển hướng
        alert(`Nộp bài thành công!\nĐiểm của bạn là: ${result.diemThi.toFixed(2)}/10`);
        
        // TODO: Chuyển hướng đến trang kết quả chi tiết nếu có
        // Tạm thời chuyển về trang danh sách lớp học
        router.push({ name: 'student-class-list' });

    } catch (error) {
        // Xử lý lỗi từ server (ví dụ: đã nộp bài rồi)
        alert(`Lỗi khi nộp bài: ${error.response?.data || error.message}`);
        if (submitButton) submitButton.disabled = false; // Bật lại nút nếu có lỗi
    }
};

onMounted(async () => {
    const examId = route.params.id;
    if (examId) {
        try {
            loading.value = true;
            const response = await examApi.getExam(examId);
            examData.value = response;
            if (response.thoigianthi > 0) {
                startTimer(response.thoigianthi);
            }
        } catch (e) {
            error.value = true;
            console.error(e);
        } finally {
            loading.value = false;
        }
    }
});

onUnmounted(() => {
    if (timerInterval) {
        clearInterval(timerInterval);
    }
});
</script>

<style scoped>
/* Chúng ta sẽ thêm style sau để trang đẹp hơn */
.exam-header {
    margin-bottom: 2rem;
    text-align: center;
    position: relative;
}

.timer {
    font-size: 1.5rem;
    font-weight: bold;
    color: #d9534f;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 8px;
    display: inline-block;
    background-color: #f9f9f9;
}

.question-item {
    margin-bottom: 1.5rem;
    padding: 1rem;
    border: 1px solid #eee;
    border-radius: 8px;
}
.answer-options {
    margin-top: 1rem;
}
.answer-option {
    margin-bottom: 0.5rem;
}
.submit-btn {
    margin-top: 2rem;
    padding: 0.8rem 2rem;
    background-color: #4CAF50;
    color: white;
    border: none;
    cursor: pointer;
    font-size: 1rem;
    border-radius: 5px;
}
</style> 