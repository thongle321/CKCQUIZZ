<template>
    <a-page-header title="Kết quả bài thi" sub-title="Chi tiết kết quả và bài làm của bạn">
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
        <a-spin :spinning="loading" tip="Đang tải kết quả bài thi..." size="large">
            <a-empty v-if="!loading && !examResult" description="Không tìm thấy kết quả bài thi này." class="mt-5" />

            <div v-if="examResult">
                <a-card title="Thông tin kết quả" class="mb-4">
                    <a-descriptions bordered :column="{ xxl: 4, xl: 3, lg: 3, md: 3, sm: 2, xs: 1 }">
                        <a-descriptions-item label="Điểm thi">
                            <span v-if="examResult.diem !== null" class="fw-bold text-primary">{{ examResult.diem }} / 10</span>
                            <span v-else class="text-muted">Không hiển thị</span>
                        </a-descriptions-item>
                        <a-descriptions-item label="Số câu đúng">
                            <span v-if="examResult.soCauDung !== null" class="fw-bold text-success">{{ examResult.soCauDung }}</span>
                            <span v-else class="text-muted">Không hiển thị</span>
                        </a-descriptions-item>
                        <a-descriptions-item label="Tổng số câu">
                            <span v-if="examResult.tongSoCau !== null" class="fw-bold">{{ examResult.tongSoCau }}</span>
                            <span v-else class="text-muted">Không hiển thị</span>
                        </a-descriptions-item>
                    </a-descriptions>
                </a-card>

                <a-card v-if="questionsWithStudentAnswers && questionsWithStudentAnswers.length > 0" title="Chi tiết bài làm" class="mb-4">
                    <a-collapse v-model:activeKey="activeQuestions" :bordered="false">
                        <a-collapse-panel v-for="(question, index) in questionsWithStudentAnswers" :key="question.macauhoi"
                            :header="`Câu ${index + 1}: ${question.noidung}`">
                            <p><strong>Loại câu hỏi:</strong> {{ question.loaicauhoi }}</p>
                            <div v-if="question.hinhanhurl">
                                <img :src="question.hinhanhurl" alt="Question Image" style="max-width: 100%; height: auto;" />
                            </div>

                            <div v-if="question.loaicauhoi === 'essay'">
                                <p><strong>Câu trả lời của bạn:</strong></p>
                                <a-textarea :value="question.studentAnswerText" auto-size readonly />
                                <p v-if="examResult.correctAnswers && examResult.correctAnswers[question.macauhoi]" class="mt-2">
                                    <strong>Đáp án đúng:</strong> <span class="text-success fw-bold">{{ getCorrectEssayAnswer(question.macauhoi) }}</span>
                                </p>
                            </div>
                            <div v-else>
                                <a-radio-group v-if="question.loaicauhoi === 'single_choice'" :value="question.studentSelectedAnswerId" disabled
                                    class="answer-options-review">
                                    <a-radio v-for="answer in question.answers" :key="answer.macautl" :value="answer.macautl" disabled>
                                        <span :class="{
                                            'text-success fw-bold': isOptionCorrect(question.macauhoi, answer.macautl),
                                            'text-danger': isStudentWrongAnswer(question.macauhoi, answer.macautl)
                                        }">
                                            {{ answer.noidungtl }}
                                            <span v-if="isOptionCorrect(question.macauhoi, answer.macautl)" class="ms-2">(Đáp án đúng)</span>
                                        </span>
                                    </a-radio>
                                </a-radio-group>

                                <a-checkbox-group v-else-if="question.loaicauhoi === 'multiple_choice'" :value="question.studentSelectedAnswerIds" disabled
                                    class="answer-options-review">
                                    <a-checkbox v-for="answer in question.answers" :key="answer.macautl" :value="answer.macautl" disabled>
                                        <span :class="{
                                            'text-success fw-bold': isOptionCorrect(question.macauhoi, answer.macautl),
                                            'text-danger': isStudentWrongAnswer(question.macauhoi, answer.macautl)
                                        }">
                                            {{ answer.noidungtl }}
                                            <span v-if="isOptionCorrect(question.macauhoi, answer.macautl)" class="ms-2">(Đáp án đúng)</span>
                                        </span>
                                    </a-checkbox>
                                </a-checkbox-group>
                            </div>
                        </a-collapse-panel>
                    </a-collapse>
                </a-card>
                <a-empty v-else description="Không có chi tiết bài làm để hiển thị." class="mt-5" />
            </div>
        </a-spin>
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute } from 'vue-router';
import { examApi } from '@/services/examService.js';
import { message } from 'ant-design-vue';
import { History } from 'lucide-vue-next';

const route = useRoute();
const examResult = ref(null);
const loading = ref(true);
const activeQuestions = ref([]);

const examId = parseInt(route.params.examId);
const resultId = parseInt(route.params.resultId);

const fetchExamResult = async () => {
    loading.value = true;
    try {
        const response = await examApi.getExamResult(resultId);
        examResult.value = response;
        console.log("Exam Result:", examResult.value);


    } catch (error) {
        console.error("Lỗi khi tải kết quả bài thi:", error);
        const errorMessage = error.response?.data?.message || "Không thể tải kết quả bài thi.";
        message.error(errorMessage);
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
    } else if (typeof correctAnswerData === 'number') {
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


onMounted(() => {
    if (isNaN(examId) || isNaN(resultId)) {
        message.error("Thông tin bài thi hoặc kết quả không hợp lệ.");
        loading.value = false;
        return;
    }
    fetchExamResult();
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