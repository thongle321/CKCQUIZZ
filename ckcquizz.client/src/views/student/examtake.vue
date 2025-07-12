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
                <a-layout-sider breakpoint="lg" collapsed-width="0" @collapse="onCollapse" width="250"
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
                    <a-button type="primary" @click="confirmSubmit" :loading="isSubmitting" :disabled="isSubmitting" block
                        style="margin-top: 16px; height: 48px; font-size: 18px; font-weight: 600; border-radius: 6px;">
                        {{ isSubmitting ? 'Đang nộp bài...' : 'Nộp bài' }}
                    </a-button>
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


                            <a-radio-group v-if="question.loaicauhoi === 'single_choice'"
                                v-model:value="userAnswers[question.macauhoi]"
                                @change="e => handleSingleChoiceChange(question.macauhoi, e.target.value)"
                                class="answer-options-ant">
                                <a-radio v-for="answer in question.answers" :key="answer.macautl"
                                    :value="answer.macautl">
                                    {{ answer.noidungtl }}
                                </a-radio>
                            </a-radio-group>

                            <a-checkbox-group v-else-if="question.loaicauhoi === 'multiple_choice'"
                                v-model:value="userAnswers[question.macauhoi]"
                                @change="selectedValues => handleMultipleChoiceChange(question.macauhoi, selectedValues)"
                                class="answer-options-ant">
                                <a-checkbox v-for="answer in question.answers" :key="answer.macautl"
                                    :value="answer.macautl">
                                    {{ answer.noidungtl }}
                                </a-checkbox>
                            </a-checkbox-group>

                            <a-textarea v-else-if="question.loaicauhoi === 'essay'"
                                v-model:value="userAnswers[question.macauhoi]"
                                @change="e => handleEssayChange(question.macauhoi, e.target.value)"
                                placeholder="Nhập câu trả lời của bạn..." :rows="4" />

                        </a-card>
                    </div>

                    <div class="text-center mt-5 pt-4 border-top">
                        <a-button type="primary" size="large" @click="confirmSubmit" :loading="isSubmitting" :disabled="isSubmitting"
                            style="height: 50px; font-size: 18px; font-weight: 600; border-radius: 6px;">
                            {{ isSubmitting ? 'Đang nộp bài...' : 'Nộp bài' }}
                        </a-button>
                    </div>
                </a-layout-content>
            </a-layout>
        </a-layout-content>
    </a-layout>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed, watch, createVNode } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { examApi } from '@/services/examService.js';
import { ClockCircleOutlined, ExclamationCircleOutlined } from '@ant-design/icons-vue';
import { useAuthStore } from '@/stores/authStore.js';
import { message, Modal } from 'ant-design-vue';
import signalRConnection from '@/services/signalrDeThiService.js';


const route = useRoute();
const router = useRouter();
const examData = ref(null);
const loading = ref(true);
const error = ref(false);

const collapsed = ref(false);
const onCollapse = (c, type) => {
    collapsed.value = c;
};

const authStore = useAuthStore();
const studentName = ref(authStore.fullName);
const currentQuestionIndex = ref(0);

const examId = computed(() => parseInt(route.params.id));

const timeLeft = ref(0);
const userAnswers = ref({});
let essayUpdateTimers = {};
const ketQuaId = ref(null);
let timer = null;
let startTime = null;
let isSubmitting = ref(false);
let backupTimer = null;

const soLanTab = ref(0);
const isExamActive = ref(false);
let lastVisibilityChange = 0;
const debounceDelay = 1000;

const selectAnswer = async (questionId, answerId) => {
    userAnswers.value[questionId] = answerId;

    if (!ketQuaId.value) {
        message.error('Không tìm thấy mã bài làm. Không thể lưu đáp án.');
        return;
    }

    const payload = {
        ketQuaId: ketQuaId.value,
        macauhoi: questionId,
        macautl: answerId,
        dapansv: 1
    };

    try {
        await examApi.updateAnswer(payload);
    } catch (err) {
        message.error('Lỗi: Không thể lưu câu trả lời của bạn. Vui lòng kiểm tra kết nối.');
    }
};

const handleSingleChoiceChange = async (questionId, answerId) => {
    userAnswers.value[questionId] = answerId;
    
    const payload = {
        ketQuaId: ketQuaId.value,
        macauhoi: questionId,
        macautl: answerId,
    };
    await updateAnswerInDb(payload);
};
const handleMultipleChoiceChange = async (questionId, selectedValues) => {
    
    userAnswers.value[questionId] = selectedValues;
    
    const question = examData.value.questions.find(q => q.macauhoi === questionId);
    if (!question) return;
    
    for (const answer of question.answers) {
        const isSelected = selectedValues.includes(answer.macautl);
        const payload = {
            ketQuaId: ketQuaId.value,
            macauhoi: questionId,
            macautl: answer.macautl,
            dapansv: isSelected ? 1 : 0
        };
        await updateAnswerInDb(payload);
    }
};
const handleEssayChange = (questionId, text) => {
    userAnswers.value[questionId] = text;
    
    clearTimeout(essayUpdateTimers[questionId]);
    essayUpdateTimers[questionId] = setTimeout(async () => {
        const payload = {
            ketQuaId: ketQuaId.value,
            macauhoi: questionId,
            dapantuluansv: text,
        };
        await updateAnswerInDb(payload);
    }, 1500);
};
const updateAnswerInDb = async (payload) => {
    if (!ketQuaId.value) {
        message.error('Lỗi: Không tìm thấy mã bài làm.');
        return;
    }
    try {
        await examApi.updateAnswer(payload);
    } catch (err) {
        message.error('Lỗi: Không thể lưu câu trả lời.');
    }
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

const confirmSubmit = () => {
    if (isSubmitting.value) {
        message.warning("Đang trong quá trình nộp bài, vui lòng đợi...");
        return;
    }

    Modal.confirm({
        title: 'Bạn chắc chắn muốn nộp bài?',
        icon: createVNode(ExclamationCircleOutlined),
        content: 'Một khi đã nộp, bạn sẽ không thể thay đổi câu trả lời.',
        okText: 'Nộp bài',
        cancelText: 'Hủy',
        onOk() {
            submitExam(false);
        },
    });
};


const submitExam = async (isAutoSubmit = false) => {
    if (isSubmitting.value) {
        message.warning("Đang trong quá trình nộp bài, vui lòng đợi...");
        return;
    }

    isSubmitting.value = true;

    if (timer) {
        clearInterval(timer);
        timer = null;
    }
    if (backupTimer) {
        clearTimeout(backupTimer);
        backupTimer = null;
    }

    const endTime = Date.now();
    let thoiGianLamBai = null;
    if (startTime) {
        thoiGianLamBai = Math.floor((endTime - startTime) / 1000);
    }

    const payload = {
        KetQuaId: ketQuaId.value,
        ExamId: parseInt(route.params.id),
        thoiGianLamBai: thoiGianLamBai
    };
    try {
        isExamActive.value = false;

        const result = await examApi.submitExam(payload);

        if (isAutoSubmit) {
            message.success(`Hết thời gian! Bài thi đã được tự động nộp thành công!`);
        } else {
            message.success(`Nộp bài thành công!`);
        }

        router.push({ name: 'student-class-exams' });
        sessionStorage.removeItem(`exam-${examId.value}-ketQuaId`);
        sessionStorage.removeItem(`exam-${examId.value}-startTime`);

    } catch (error) {
        message.error(`Lỗi khi nộp bài: ${error.response?.data || error.message}`);

        isSubmitting.value = false;
        isExamActive.value = true;

        if (isAutoSubmit) {
            setTimeout(() => {
                if (isExamActive.value && !isSubmitting.value) {
                    submitExam(true);
                }
            }, 5000);
        }
    }
};

const handleVisibilityChange = () => {
    if (!isExamActive.value || !ketQuaId.value) return;

    const now = Date.now();

    if (now - lastVisibilityChange < debounceDelay) {
        return;
    }
    lastVisibilityChange = now;

    if (document.visibilityState === 'hidden') {
        canhBaoChuyenTab();
    }
};

const canhBaoChuyenTab = async () => {
    if (!ketQuaId.value || !signalRConnection) return;

    try {
        await signalRConnection.invoke('canhBaoChuyenTab', {
            KetQuaId: parseInt(ketQuaId.value)
        });
    } catch (error) {
        message.error('Lỗi khi báo cáo chuyển tab');
    }
};

const handleCanhBaoChuyenTab = (response) => {
    soLanTab.value = response.soLanHienTai;

    Modal.warning({
        title: 'Cảnh báo chuyển tab',
        content: response.thongBao,
        okText: 'Đã hiểu',
        centered: true,
        maskClosable: false,
    });
};

const handleAutoSubmitCommand = (message) => {
    Modal.error({
        title: 'Tự động nộp bài',
        content: message,
        okText: 'Đã hiểu',
        centered: true,
        maskClosable: false,
        onOk: () => {
            submitExam();
        }
    });
};

const setupSignalRListeners = () => {
    if (!signalRConnection) return;

    signalRConnection.on('ReceiveTabSwitchWarning', handleCanhBaoChuyenTab);
    signalRConnection.on('ReceiveAutoSubmitCommand', handleAutoSubmitCommand);
};

const cleanupSignalRListeners = () => {
    if (!signalRConnection) return;

    signalRConnection.off('ReceiveTabSwitchWarning', handleCanhBaoChuyenTab);
    signalRConnection.off('ReceiveAutoSubmitCommand', handleAutoSubmitCommand);
};

onMounted(async () => {
    if (examId.value) {
        try {
            loading.value = true;
            error.value = false;

            const storedKetQuaId = sessionStorage.getItem(`exam-${examId.value}-ketQuaId`);
            const storedStartTime = sessionStorage.getItem(`exam-${examId.value}-startTime`);

            let examDetailsResponse;

            if (storedKetQuaId && storedStartTime) {
                ketQuaId.value = storedKetQuaId;
                startTime = parseInt(storedStartTime);

                examDetailsResponse = await examApi.getExam(examId.value);
                if (!examDetailsResponse) {
                    throw new Error('Không nhận được phản hồi từ server khi lấy chi tiết đề thi để tiếp tục.');
                }
                examData.value = examDetailsResponse;

                const existingAnswers = await examApi.getExamResult(ketQuaId.value);
                if (existingAnswers && existingAnswers.dapAnSinhViens) {
                    existingAnswers.dapAnSinhViens.forEach(answer => {
                        const question = examData.value.questions.find(q => q.macauhoi === answer.macauhoi);
                        if (question) {
                            if (question.loaicauhoi === 'multiple_choice') {
                                if (!userAnswers.value[question.macauhoi]) {
                                    userAnswers.value[question.macauhoi] = [];
                                }
                                if (answer.dapansv === 1) {
                                    userAnswers.value[question.macauhoi].push(answer.macautl);
                                }
                            } else if (question.loaicauhoi === 'essay') {
                                userAnswers.value[question.macauhoi] = answer.dapantuluansv || '';
                            } else {
                                userAnswers.value[question.macauhoi] = answer.macautl;
                            }
                        }
                    });
                }
            } else {
                const startExamResponse = await examApi.startExam({ ExamId: examId.value });

                if (!startExamResponse) {
                    throw new Error('Không nhận được phản hồi từ server khi bắt đầu bài thi');
                }

                ketQuaId.value = startExamResponse.ketQuaId;
                startTime = new Date(startExamResponse.thoigianbatdau).getTime();

                sessionStorage.setItem(`exam-${examId.value}-ketQuaId`, ketQuaId.value);
                sessionStorage.setItem(`exam-${examId.value}-startTime`, startTime.toString());

                examDetailsResponse = await examApi.getExam(examId.value);

                if (!examDetailsResponse) {
                    throw new Error('Không nhận được phản hồi từ server khi lấy chi tiết đề thi');
                }

                examData.value = examDetailsResponse;

                if (examData.value.questions && examData.value.questions.length > 0) {
                    examData.value.questions.forEach(q => {
                        if (q.loaicauhoi === 'multiple_choice') {
                            userAnswers.value[q.macauhoi] = [];
                        } else if (q.loaicauhoi === 'essay') {
                            userAnswers.value[q.macauhoi] = '';
                        } else {
                            userAnswers.value[q.macauhoi] = null;
                        }
                    });
                }
            }

            if (examData.value.thoigianthi > 0) {
                const totalExamDurationSeconds = examData.value.thoigianthi * 60;
                const elapsedTimeSeconds = Math.floor((Date.now() - startTime) / 1000);
                timeLeft.value = Math.max(0, totalExamDurationSeconds - elapsedTimeSeconds);


                if (timeLeft.value <= 0) {
                    message.warning("Hết giờ làm bài! Bài của bạn sẽ được tự động nộp.");
                    submitExam(true);
                    return;
                }

                if (timer) clearInterval(timer);
                if (backupTimer) clearTimeout(backupTimer);

                timer = setInterval(() => {
                    try {
                        timeLeft.value--;

                        if (timeLeft.value === 300) {
                            message.warning("Còn 5 phút nữa sẽ hết thời gian làm bài!");
                        }

                        if (timeLeft.value === 60) {
                            message.warning("Còn 1 phút nữa sẽ hết thời gian làm bài!");
                        }

                        if (timeLeft.value <= 0) {
                            clearInterval(timer);
                            timer = null;

                            if (!isSubmitting.value && isExamActive.value) {
                                message.warning("Hết giờ làm bài! Bài của bạn sẽ được tự động nộp.");
                                submitExam(true);
                            }
                        }
                    } catch (error) {
                        console.error("Error in timer:", error);
                        if (timeLeft.value <= 0 && !isSubmitting.value && isExamActive.value) {
                            submitExam(true);
                        }
                    }
                }, 1000);

                const backupTimeMs = timeLeft.value * 1000 + 2000;
                backupTimer = setTimeout(() => {
                    if (!isSubmitting.value && isExamActive.value) {
                        message.warning("Hết thời gian làm bài! Tự động nộp bài.");
                        submitExam(true);
                    }
                }, backupTimeMs);

            }
            window.addEventListener('scroll', handleScroll);

            document.addEventListener('visibilitychange', handleVisibilityChange);
            setupSignalRListeners();
            isExamActive.value = true;

        } catch (e) {
            error.value = true;
            console.error('Lỗi chi tiết:', e);
            const errorMessage = e.response?.data || e.message || 'Có lỗi xảy ra khi tải đề thi.';
            message.error(errorMessage);
        } finally {
            loading.value = false;
        }
    }
});

onUnmounted(() => {
    if (timer) {
        clearInterval(timer);
        timer = null;
    }
    if (backupTimer) {
        clearTimeout(backupTimer);
        backupTimer = null;
    }
    window.removeEventListener('scroll', handleScroll);

    document.removeEventListener('visibilitychange', handleVisibilityChange);
    cleanupSignalRListeners();
    isExamActive.value = false;
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