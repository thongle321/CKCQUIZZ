<template>
    <a-layout>
        <a-layout-header
            style="background: #fff; padding: 0 24px; height: auto; line-height: normal; border-bottom: 1px solid #f0f0f0; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06); position: sticky; top: 0; z-index: 1000;">
            <a-row type="flex" justify="space-between" align="middle" class="w-100 py-3">
                <a-col :span="12">
                    <h1 style="font-size: 24px; margin: 0; color: #262626; font-weight: 600;">{{ examData?.tende ||
                        'Đang tải đề thi...' }}</h1>
                    <p style="font-size: 14px; color: #595959; margin-top: 4px;">Thí sinh: {{ studentName }}</p>
                </a-col>
                <a-col :span="12" class="text-end">
                    <a-tag color="blue" class="d-inline-flex align-items-center p-2 rounded">
                        <template #icon>
                            <ClockCircleOutlined />
                        </template>
                        Thời gian còn lại: <span class="fw-bold text-danger">{{ formattedTime }}</span>
                    </a-tag>
                </a-col>
            </a-row>
        </a-layout-header>

        <a-layout-content class="p-4">
            <div v-if="loading"
                class="d-flex flex-column justify-content-center align-items-center min-vh-100 fs-5 text-secondary">
                <a-spin size="large" />
                <p>Đang tải đề thi...</p>
            </div>
            <a-alert v-if="error" message="Không thể tải được đề thi. Vui lòng thử lại." type="error" show-icon
                class="mb-4" />

            <a-layout v-if="examData" class="bg-light d-flex flex-grow-1">
                <a-layout-sider breakpoint="lg" collapsed-width="0" @collapse="onCollapse"
                    width="250"
                    style="background: #fff; padding: 24px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.09); margin-right: 24px; height: fit-content; max-height: calc(100vh - 48px - 64px); overflow-y: auto; position: sticky; top: calc(64px + 24px);">
                    <div
                        style="display: grid; grid-template-columns: repeat(auto-fill, minmax(50px, 1fr)); gap: 12px; margin-bottom: 24px;">
                        <a-button v-for="(question, index) in examData.questions" :key="question.macauhoi"
                            @click="scrollToQuestion(index)"
                            :type="currentQuestionIndex === index ? 'primary' : (userAnswers && userAnswers[question.macauhoi] ? 'dashed' : 'default')"
                            style="width: 100%; height: 50px; font-size: 16px; font-weight: 500; border-radius: 6px; display: flex; justify-content: center; align-items: center;">
                            {{ index + 1 }}
                        </a-button>     
                    </div>
                    <a-button type="primary" @click="submitExam" block
                        style="margin-top: 16px; height: 48px; font-size: 18px; font-weight: 600; border-radius: 6px;">Nộp
                        bài</a-button>
                </a-layout-sider>

                <a-layout-content class="bg-light">
                    <div v-for="(question, index) in examData.questions" :key="question.macauhoi"
                        :id="'question-' + index" class="mb-4" style="scroll-margin-top: 90px;">
                        <a-card :title="`Câu ${index + 1}: ${question.noidung}`"
                            style="border-radius: 8px; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.09);">
                            <div v-if="question.hinhanhurl" class="mb-3 text-center">
                                <img :src="question.hinhanhurl" :alt="`Hình ảnh câu hỏi ${index + 1}`"
                                    style="width: 600px; height: auto; border-radius: 4px;" />
                            </div>
                            <a-radio-group :value="userAnswers[question.macauhoi]"
                                @change="e => selectAnswer(question.macauhoi, e.target.value)"
                                class="answer-options-ant">
                                <a-radio v-for="answer in question.answers" :key="answer.macautl"
                                    :value="answer.macautl">
                                    {{ answer.noidungtl }}
                                </a-radio>
                            </a-radio-group>
                        </a-card>
                    </div>

                    <div class="text-center mt-5 pt-4 border-top">
                        <a-button type="primary" size="large" @click="submitExam"
                            style="height: 50px; font-size: 18px; font-weight: 600; border-radius: 6px;">Nộp
                            bài</a-button>
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
import { message } from 'ant-design-vue';


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

const authStore = useAuthStore();
const studentName = ref(authStore.fullName);
const currentQuestionIndex = ref(0);

const examId = computed(() => parseInt(route.params.id));

const timeLeft = ref(0);
const userAnswers = ref({});
let timer = null;
let startTime = null;

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

const submitExam = async () => {
    if (timer) clearInterval(timer);
    const submitButton = document.querySelector('.submit-btn');
    if (submitButton) submitButton.disabled = true;

    const formattedAnswers = Object.keys(userAnswers.value).map(questionId => ({
        questionId: parseInt(questionId),
        selectedAnswerId: userAnswers.value[questionId]
    }));

    const endTime = Date.now();
    let thoiGianSoLamBai = null;
    if (startTime) {
        thoiGianSoLamBai = Math.floor((endTime - startTime) / 1000);
    }

    const payload = {
        examId: parseInt(route.params.id),
        answers: formattedAnswers,
        ThoiGianSoLamBai: thoiGianSoLamBai
    };
    console.log("startTime:", startTime);
    console.log("endTime:", endTime);
    console.log("thoiGianSoLamBai (calculated):", thoiGianSoLamBai);
    console.log("Payload sent:", payload);

    try {
        const result = await examApi.submitExam(payload);
        console.log("Nộp bài thành công, kết quả:", result);

        message.success(`Nộp bài thành công!`);

        router.push({ name: 'student-class-exams' });

    } catch (error) {
        message.error(`Lỗi khi nộp bài: ${error.response?.data || error.message}`);
        if (submitButton) submitButton.disabled = false;
    }
};

onMounted(async () => {
    if (examId.value) {
        try {
            loading.value = true;

            const response = await examApi.getExam(examId.value);
            examData.value = response;

            if (response.thoigianthi > 0) {
                timeLeft.value = response.thoigianthi * 60;
                if (timer) clearInterval(timer);
                timer = setInterval(() => {
                    timeLeft.value--;
                    if (timeLeft.value <= 0) {
                        clearInterval(timer);
                        message.warning("Hết giờ làm bài! Bài của bạn sẽ được tự động nộp.");
                        submitExam();
                    }
                }, 1000);
            } else {
                timeLeft.value = 0;
            }

            startTime = Date.now();

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
    if (timer) clearInterval(timer);
    window.removeEventListener('scroll', handleScroll);
});
</script>

<style scoped>
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
    background-color: #e6f7ff;

}

.answer-options-ant .ant-radio {
    margin-top: 4px;

}

.answer-options-ant .ant-radio+span {
    font-size: 16px;
    color: #262626;
    line-height: 1.5;
    flex-grow: 1;
}


@media (max-width: 992px) {
    .ant-layout-sider {
        position: static !important;
        width: 100% !important;
        max-width: 100% !important;
        margin-right: 0 !important;
        margin-bottom: 24px;
        height: auto !important;
        max-height: none !important;
    }
}
</style>
