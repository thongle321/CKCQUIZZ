<template>
    <a-page-header title="Chi tiết bài làm" sub-title="Chi tiết kết quả bài làm của sinh viên" @back="() => router.back()">
        <template #avatar>
            <a-avatar>
                <template #icon>
                    <History />
                </template>
            </a-avatar>
        </template>
    </a-page-header>

    <a-divider />

    <div class="p-3">
        <a-spin :spinning="loading" tip="Đang tải kết quả bài làm..." size="large">
            <a-empty v-if="!loading && !examResult" description="Không tìm thấy kết quả bài làm này." class="mt-5" />

            <div v-if="examResult">
                <a-card v-if="examResult.xemdiemthi" title="Thông tin kết quả" class="mb-4">
                    <a-descriptions bordered :column="{ xxl: 4, xl: 3, lg: 3, md: 3, sm: 2, xs: 1 }">
                        <a-descriptions-item label="Điểm thi">
                            <span class="fw-bold text-primary">{{ examResult.diem !== null ? examResult.diem.toFixed(2) : 'N/A' }} / 10</span>
                        </a-descriptions-item>
                        <a-descriptions-item label="Số câu đúng">
                            <span class="fw-bold text-success">{{ examResult.soCauDung !== null ? examResult.soCauDung : 'N/A' }}</span>
                        </a-descriptions-item>
                        <a-descriptions-item label="Tổng số câu">
                            <span class="fw-bold">{{ examResult.tongSoCau !== null ? examResult.tongSoCau : 'N/A' }}</span>
                        </a-descriptions-item>
                    </a-descriptions>
                </a-card>
                <a-empty v-else description="Không hiển thị điểm thi." class="mt-5" />

                <a-card v-if="examResult.hienthibailam && questionsWithStudentAnswers && questionsWithStudentAnswers.length > 0" title="Chi tiết bài làm" class="mb-4">
                    <div v-for="(question, index) in questionsWithStudentAnswers" :key="question.macauhoi" class="mb-4 p-3 border rounded">
                        <h6 class="fw-bold">Câu {{ index + 1 }}: {{ question.noidung }}</h6>
                        <p><strong>Loại câu hỏi:</strong> {{ questionType(question.loaicauhoi) }}</p>
                        <div v-if="question.hinhanhurl">
                            <img :src="question.hinhanhurl" alt="Question Image" style="max-width: 100%; height: auto;" />
                        </div>

                        <div v-if="question.loaicauhoi === 'essay'">
                            <p><strong>Bài làm của sinh viên:</strong></p>
                            <a-textarea :value="question.studentAnswerText" auto-size readonly />
                            <p v-if="examResult.xemdapan && examResult.correctAnswers && examResult.correctAnswers[question.macauhoi]" class="mt-2">
                                <strong>Đáp án đúng:</strong> <span class="text-success fw-bold">{{ getCorrectEssayAnswer(question.macauhoi) }}</span>
                            </p>
                        </div>
                        <div v-else>
                            <a-radio-group v-if="question.loaicauhoi === 'single_choice'" :value="question.studentSelectedAnswerId" disabled
                                class="answer-options-review">
                                <a-radio v-for="answer in question.answers" :key="answer.macautl" :value="answer.macautl" disabled>
                                    <span :class="{
                                        'text-success fw-bold': examResult.xemdapan && isOptionCorrect(question.macauhoi, answer.macautl),
                                        'text-danger': examResult.hienthibailam && isStudentWrongAnswer(question.macauhoi, answer.macautl)
                                    }">
                                        {{ answer.noidungtl }}
                                        <span v-if="examResult.xemdapan && isOptionCorrect(question.macauhoi, answer.macautl)" class="ms-2">(Đáp án đúng)</span>
                                    </span>
                                </a-radio>
                            </a-radio-group>

                            <a-checkbox-group v-else-if="question.loaicauhoi === 'multiple_choice'" :value="question.studentSelectedAnswerIds" disabled
                                class="answer-options-review">
                                <a-checkbox v-for="answer in question.answers" :key="answer.macautl" :value="answer.macautl" disabled>
                                    <span :class="{
                                        'text-success fw-bold': examResult.xemdapan && isOptionCorrect(question.macauhoi, answer.macautl),
                                        'text-danger': examResult.hienthibailam && isStudentWrongAnswer(question.macauhoi, answer.macautl)
                                    }">
                                        {{ answer.noidungtl }}
                                        <span v-if="examResult.xemdapan && isOptionCorrect(question.macauhoi, answer.macautl)" class="ms-2">(Đáp án đúng)</span>
                                    </span>
                                </a-checkbox>
                            </a-checkbox-group>
                        </div>
                    </div>
                </a-card>
                <a-empty v-else description="Không hiển thị bài làm." class="mt-5" />
            </div>
        </a-spin>
    </div>
</template>

<script setup>
import { ref, onMounted, computed, defineProps } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { message } from 'ant-design-vue';
import { History } from 'lucide-vue-next';
import apiClient from "@/services/axiosServer";

const props = defineProps({
  ketQuaId: {
    type: [String, Number],
    required: true
  }
});

const route = useRoute();
const router = useRouter();
const ketQuaId = ref(props.ketQuaId);
const examResult = ref(null);
const loading = ref(true);

const fetchExamResult = async () => {
    loading.value = true;
    try {
        const response = await apiClient.get(`/Exam/teacher-exam-result/${ketQuaId.value}`);
        examResult.value = response.data;
        console.log("Exam Result:", examResult.value);
    } catch (error) {
        console.error("Lỗi khi tải chi tiết bài làm:", error);
        const errorMessage = error.response?.data?.message || "Không thể tải chi tiết bài làm.";
        message.error(errorMessage);
        examResult.value = null;
    } finally {
        loading.value = false;
    }
};

const questionsWithStudentAnswers = computed(() => {
    return examResult.value?.questions || [];
});

const isOptionCorrect = (questionId, answerId) => {
    if (!examResult.value?.correctAnswers) return false;

    const correctAnswerData = examResult.value.correctAnswers[questionId];

    if (Array.isArray(correctAnswerData)) {
        return correctAnswerData.includes(answerId);
    } else if (typeof correctAnswerData === 'number' || typeof correctAnswerData === 'string') {
        return correctAnswerData === answerId;
    }
    return false;
};

const isStudentWrongAnswer = (questionId, answerId) => {
    const question = questionsWithStudentAnswers.value.find(q => q.macauhoi === questionId);
    if (!question) return false;

    if (question.loaicauhoi === 'single_choice') {
        return question.studentSelectedAnswerId === answerId && !isOptionCorrect(questionId, answerId);
    } else if (question.loaicauhoi === 'multiple_choice') {
        return question.studentSelectedAnswerIds.includes(answerId) && !isOptionCorrect(questionId, answerId);
    }
    return false;
};

const getCorrectEssayAnswer = (questionId) => {
    if (!examResult.value?.correctAnswers) return 'N/A';
    const correctText = examResult.value.correctAnswers[questionId];
    return typeof correctText === 'string' ? correctText : 'N/A';
};

const questionType = (type) => {
    switch (type) {
        case 'single_choice':
            return 'Một đáp án';
        case 'multiple_choice':
            return 'Nhiều đáp án';
        case 'essay':
            return 'Tự luận';
        default:
            return type;
    }
};

onMounted(() => {
    if (ketQuaId.value) {
        fetchExamResult();
    } else {
        message.error("Không tìm thấy ID kết quả bài làm.");
        loading.value = false;
    }
});
</script>

<style scoped>
.ant-descriptions-item-label {
    font-weight: bold;
}
.answer-options-review .ant-checkbox-wrapper,
.answer-options-review .ant-radio-wrapper {
   display: flex;
   align-items: flex-start;
   margin-bottom: 12px;
   padding: 12px 16px;
   border: 1px solid #f0f0f0;
   border-radius: 6px;
   transition: all 0.3s;
}

.answer-options-review .ant-checkbox-wrapper-checked,
.answer-options-review .ant-radio-wrapper-checked {
   border-color: #1890ff;
   background-color: #e6f7ff;
}

.answer-options-review .ant-checkbox,
.answer-options-review .ant-radio {
   margin-top: 4px;
}

.answer-options-review .ant-checkbox+span,
.answer-options-review .ant-radio+span {
   font-size: 16px;
   color: #262626;
   line-height: 1.5;
   flex-grow: 1;
}
</style>