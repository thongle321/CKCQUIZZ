<template>
    <a-layout class="exam-layout">
        <a-layout-header class="exam-header-ant">
            <a-row type="flex" justify="space-between" align="middle" class="header-content">
                <a-col :span="12" class="header-info">
                    <h1 class="exam-title-ant">{{ examData?.tende || 'Đang tải đề thi...' }}</h1>
                    <p class="student-name-ant">Thí sinh: {{ studentName }}</p>
                </a-col>
                <a-col :span="12" style="text-align: right;">
                    <a-tag color="blue" class="timer-tag">
                        <template #icon><ClockCircleOutlined /></template>
                        Thời gian còn lại: <span class="timer-value-ant">{{ formattedTime }}</span>
                    </a-tag>
                </a-col>
            </a-row>
        </a-layout-header>

        <a-layout-content class="exam-main-content">
            <div v-if="loading" class="loading-overlay">
                <a-spin size="large" />
                <p>Đang tải đề thi...</p>
            </div>
            <a-alert v-if="error" message="Không thể tải được đề thi. Vui lòng thử lại." type="error" show-icon class="error-alert" />

            <a-layout v-if="examData" class="exam-body-layout">
                <a-layout-sider
                    breakpoint="lg"
                    collapsed-width="0"
                    @collapse="onCollapse"
                    @breakpoint="onBreakpoint"
                    width="250"
                    class="question-navigation-sider"
                >
                    <div class="navigation-grid-ant">
                        <a-button
                            v-for="(question, index) in examData.questions"
                            :key="question.macauhoi"
                            @click="scrollToQuestion(index)"
                            :type="currentQuestionIndex === index ? 'primary' : (userAnswers[question.macauhoi] ? 'dashed' : 'default')"
                            :class="{ 'answered-ant': userAnswers[question.macauhoi] }"
                            class="nav-button-ant"
                        >
                            {{ index + 1 }}
                        </a-button>
                    </div>
                    <a-button type="primary" @click="submitExam" block class="submit-btn-sidebar-ant">Nộp bài</a-button>
                </a-layout-sider>

                <a-layout-content class="exam-questions-content">
                    <div v-for="(question, index) in examData.questions" :key="question.macauhoi" :id="'question-' + index" class="question-item-ant">
                        <a-card :title="`Câu ${index + 1}: ${question.noidung}`" class="question-card">                            
                            <a-radio-group
                                :value="userAnswers[question.macauhoi]"
                                @change="e => selectAnswer(question.macauhoi, e.target.value)"
                                class="answer-options-ant"
                            >
                                <a-radio
                                    v-for="answer in question.answers"
                                    :key="answer.macautl"
                                    :value="answer.macautl"
                                    class="answer-radio"
                                >
                                    {{ answer.noidungtl }}
                                </a-radio>
                            </a-radio-group>
                        </a-card>
                    </div>
                    
                    <div class="submit-section-ant">
                        <a-button type="primary" size="large" @click="submitExam" class="submit-btn-bottom-ant">Nộp bài</a-button>
                    </div>
                </a-layout-content>
            </a-layout>
        </a-layout-content>
    </a-layout>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { examApi } from '@/services/examService.js';
import { ClockCircleOutlined } from '@ant-design/icons-vue';
import { useAuthStore } from '@/stores/authStore.js';


const route = useRoute();
const router = useRouter();
const examData = ref(null);
const loading = ref(true);
const error = ref(false);

const collapsed = ref(false);
const onCollapse = (c, type) => {
    console.log(c, type);
    collapsed.value = c;
};
const onBreakpoint = (broken) => {
    console.log(broken);
};

const authStore = useAuthStore();
const studentName = ref(authStore.fullName); 
const currentQuestionIndex = ref(0); 

const timeLeft = ref(0);
let timerInterval = null;

const userAnswers = ref({});

const selectAnswer = (questionId, answerId) => {
    userAnswers.value[questionId] = answerId;
};

const scrollToQuestion = (index) => {
    const element = document.getElementById(`question-${index}`);
    if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
        currentQuestionIndex.value = index; 
    }
};

const handleScroll = () => {
    const questions = examData.value?.questions;
    if (!questions) return;

    let foundIndex = -1;
    for (let i = 0; i < questions.length; i++) {
        const element = document.getElementById(`question-${i}`);
        if (element) {
            const rect = element.getBoundingClientRect();
            // Nếu phần trên của câu hỏi nằm trong viewport hoặc đã đi qua
            if (rect.top <= window.innerHeight / 2 && rect.bottom >= 0) {
                foundIndex = i;
                break;
            }
        }
    }
    if (foundIndex !== -1 && foundIndex !== currentQuestionIndex.value) {
        currentQuestionIndex.value = foundIndex;
    }
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
            // Giả định lấy tên sinh viên từ một service hoặc store
            // if (userService.currentUser) {
            //     studentName.value = userService.currentUser.fullName;
            // } else {
            //     // Hoặc fetch từ API nếu cần
            //     const userInfo = await userService.getUserInfo();
            //     studentName.value = userInfo.fullName;
            // }

            const response = await examApi.getExam(examId);
            examData.value = response;
            if (response.thoigianthi > 0) {
                startTimer(response.thoigianthi);
            }
            window.addEventListener('scroll', handleScroll);
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
    window.removeEventListener('scroll', handleScroll);
});
</script>

<style scoped>
/* General Layout */
.exam-layout {
    min-height: 100vh;
    background-color: #f0f2f5; /* Ant Design default background */
}

/* Header */
.exam-header-ant {
    background: #fff;
    padding: 0 24px;
    height: auto; /* Allow content to define height */
    line-height: normal; /* Reset line-height */
    border-bottom: 1px solid #f0f0f0;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
    position: sticky;
    top: 0;
    z-index: 1000;
}

.header-content {
    width: 100%;
    padding: 16px 0; /* Add vertical padding */
}

.exam-title-ant {
    font-size: 24px;
    margin: 0;
    color: #262626;
    font-weight: 600;
}

.student-name-ant {
    font-size: 14px;
    color: #595959;
    margin-top: 4px;
}

.timer-tag {
    font-size: 16px;
    padding: 8px 12px;
    height: auto;
    border-radius: 6px;
    display: inline-flex;
    align-items: center;
}

.timer-tag .anticon {
    margin-right: 8px;
}

.timer-value-ant {
    font-weight: bold;
    color: #ff4d4f; /* Red color for urgency */
    font-variant-numeric: tabular-nums;
}

/* Main Content Area */
.exam-main-content {
    padding: 24px;
    display: flex;
    flex-direction: column;
    flex-grow: 1;
}

.loading-overlay {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    min-height: calc(100vh - 64px); /* Adjust for header height */
    font-size: 18px;
    color: #595959;
}

.error-alert {
    margin-bottom: 24px;
}

.exam-body-layout {
    background: #f0f2f5;
    display: flex;
    flex-grow: 1;
}

/* Sidebar Navigation */
.question-navigation-sider {
    background: #fff;
    padding: 24px;
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.09);
    margin-right: 24px;
    height: fit-content;
    max-height: calc(100vh - 48px - 64px); /* Total viewport - main content padding - header height */
    overflow-y: auto;
    position: sticky;
    top: calc(64px + 24px); /* Header height + main content padding */
}

.navigation-grid-ant {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(50px, 1fr));
    gap: 12px;
    margin-bottom: 24px;
}

.nav-button-ant {
    width: 100%;
    height: 50px;
    font-size: 16px;
    font-weight: 500;
    border-radius: 6px;
    display: flex;
    justify-content: center;
    align-items: center;
}

.nav-button-ant.answered-ant {
    background-color: #f6ffed; /* Ant Design success background */
    border-color: #b7eb8f; /* Ant Design success border */
    color: #52c41a; /* Ant Design success text */
}

.nav-button-ant.answered-ant.ant-btn-primary {
    background-color: #52c41a;
    border-color: #52c41a;
    color: #fff;
}

.submit-btn-sidebar-ant {
    margin-top: 16px;
    height: 48px;
    font-size: 18px;
    font-weight: 600;
    border-radius: 6px;
}

/* Main Questions Content */
.exam-questions-content {
    background: #f0f2f5;
    padding: 0; /* Reset padding as cards will have their own */
}

.question-item-ant {
    margin-bottom: 24px;
    scroll-margin-top: 90px; /* Offset for sticky header */
}

.question-card {
    border-radius: 8px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.09);
}

.question-text-ant {
    font-size: 16px;
    line-height: 1.8;
    color: #262626;
    margin-bottom: 24px;
}

.answer-options-ant .ant-radio-wrapper {
    display: flex;
    align-items: flex-start;
    margin-bottom: 12px;
    padding: 12px 16px;
    border: 1px solid #f0f0f0;
    border-radius: 6px;
    transition: all 0.3s;
}

.answer-options-ant .ant-radio-wrapper:hover {
    border-color: #1890ff;
    box-shadow: 0 0 0 2px rgba(24, 144, 255, 0.2);
}

.answer-options-ant .ant-radio-wrapper-checked {
    border-color: #1890ff;
    background-color: #e6f7ff; /* Light blue background for checked */
}

.answer-options-ant .ant-radio {
    margin-top: 4px; /* Align radio button with text */
}

.answer-options-ant .ant-radio + span {
    font-size: 16px;
    color: #262626;
    line-height: 1.5;
    flex-grow: 1;
}

.submit-section-ant {
    text-align: center;
    margin-top: 32px;
    padding-top: 24px;
    border-top: 1px solid #f0f0f0;
}

.submit-btn-bottom-ant {
    height: 50px;
    font-size: 18px;
    font-weight: 600;
    border-radius: 6px;
}

/* Responsive Adjustments for Ant Design */
@media (max-width: 992px) {
    .exam-body-layout {
        flex-direction: column;
    }

    .question-navigation-sider {
        position: static;
        width: 100% !important; /* Override Ant Design's default width */
        max-width: 100% !important;
        margin-right: 0;
        margin-bottom: 24px;
        height: auto;
        max-height: none;
    }

    .exam-header-ant {
        padding: 0 16px;
    }

    .header-content {
        flex-direction: column;
        align-items: flex-start;
        padding: 12px 0;
    }

    .timer-tag {
        margin-top: 12px;
        width: 100%;
        justify-content: center;
    }

    .exam-main-content {
        padding: 16px;
    }
}

@media (max-width: 576px) {
    .exam-title-ant {
        font-size: 20px;
    }

    .student-name-ant {
        font-size: 13px;
    }

    .timer-tag {
        font-size: 14px;
        padding: 6px 10px;
    }

    .question-navigation-sider {
        padding: 16px;
    }

    .navigation-grid-ant {
        grid-template-columns: repeat(auto-fill, minmax(45px, 1fr));
        gap: 8px;
    }

    .nav-button-ant {
        height: 45px;
        font-size: 14px;
    }

    .question-card {
        padding: 16px;
    }

    .question-text-ant {
        font-size: 15px;
    }

    .answer-options-ant .ant-radio-wrapper {
        padding: 10px 14px;
    }

    .answer-options-ant .ant-radio + span {
        font-size: 15px;
    }

    .submit-btn-sidebar-ant, .submit-btn-bottom-ant {
        height: 45px;
        font-size: 16px;
    }
}
</style>