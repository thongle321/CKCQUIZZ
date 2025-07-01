<template>
    <a-page-header title="Tất cả đề thi của bạn" sub-title="Danh sách các bài kiểm tra từ tất cả các lớp học">
        <template #avatar>
            <a-avatar>
                <template #icon>
                    <Layers />
                </template>
            </a-avatar>
        </template>
    </a-page-header>

    <a-divider />

    <div class="p-3">
        <a-spin :spinning="loading" tip="Đang tải danh sách đề thi..." size="large">
            <a-empty v-if="!loading && exams.length === 0"
                description="Bạn chưa được giao đề thi nào từ bất kỳ lớp học nào." class="mt-5" />

            <a-list v-if="!loading && exams.length > 0"
                :grid="{ gutter: 24, xs: 1, sm: 1, md: 2, lg: 2, xl: 3, xxl: 3, column: 3 }" :data-source="exams" >
                <template #renderItem="{ item }">
                    <a-list-item>
                        <a-card hoverable class="h-100 d-flex flex-column">
                            <a-card-meta>
                                <template #title>
                                    <div class="d-flex align-items-center">
                                        <a-tooltip :title="item.tende">
                                            <span class="d-inline-block" style="max-width: 180px;">
                                                {{ item.tende }}
                                            </span>
                                        </a-tooltip>
                                        <a-tag :color="statusInfo(item.trangthaiThi).color" class="ms-2">
                                            {{ statusInfo(item.trangthaiThi).text }}
                                        </a-tag>
                                    </div>
                                </template>
                            </a-card-meta>

                            <div class="mt-4">
                                <a-space direction="vertical" :size="12">
                                    <p class="mb-0 d-flex align-items-center">
                                        <BookOpenCheck size="16" class="me-2 text-muted" />
                                        <span class="fw-bold me-2">Môn thi:</span> {{ item.tenMonHoc }}
                                    </p>
                                    <p class="mb-0 d-flex align-items-center">
                                        <ListOrdered size="16" class="me-2 text-muted" />
                                        <span class="fw-bold me-2">Số câu:</span> {{ item.tongSoCau }} câu
                                    </p>
                                    <p class="mb-0 d-flex align-items-center">
                                        <Clock size="16" class="me-2 text-muted" />
                                        <span class="fw-bold me-2">Thời gian:</span> {{ item.thoigianthi }} phút
                                    </p>
                                    <p class="mb-0 d-flex align-items-center">
                                        <CalendarRange size="16" class="me-2 text-muted" />
                                        <span class="fw-bold me-2">Bắt đầu:</span>
                                        {{ formatDateTime(item.thoigiantbatdau) }}
                                    </p>
                                    <p class="mb-0 d-flex align-items-center">
                                        <CalendarOff size="16" class="me-2 text-muted" />
                                        <span class="fw-bold me-2">Kết thúc:</span>
                                        {{ formatDateTime(item.thoigianketthuc) }}
                                    </p>
                                </a-space>
                            </div>

                            <template #actions>
                                <div class="w-100 text-center">
                                    <a-button v-if="item.trangthaiThi === 'DangDienRa' && !item.ketQuaId" type="primary"
                                        @click="startExam(item.made)">
                                        <template #icon>
                                            <PlayCircle size="16" />
                                        </template>
                                        {{ item.isResumable ? 'Tiếp tục vào thi' : 'Vào thi' }}
                                    </a-button>
                                    <a-button v-if="item.trangthaiThi === 'DaKetThuc' || item.ketQuaId"
                                        @click="reviewExam(item.made, item.ketQuaId)">
                                        <template #icon>
                                            <History size="16" />
                                        </template>
                                        Xem kết quả
                                    </a-button>
                                </div>
                            </template>
                        </a-card>
                    </a-list-item>
                </template>
            </a-list>
        </a-spin>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import { message } from 'ant-design-vue';
import { Layers, BookOpenCheck, ListOrdered, Clock, CalendarRange, CalendarOff, PlayCircle, History } from 'lucide-vue-next';
import dayjs from 'dayjs';
import signalRConnection from '@/services/signalrDeThiService';

const router = useRouter();
const exams = ref([]);
const loading = ref(true);

const fetchAllMyExams = async () => {
    loading.value = true;
    try {
        const response = await apiClient.get('/DeThi/my-exams');
        exams.value = response.data.map(exam => {
            const savedState = localStorage.getItem(`exam_state_${exam.made}`);
            return {
                ...exam,
                isResumable: savedState && exam.trangthaiThi === 'DangDienRa'
            };
        });
    } catch (error) {
        console.error("Lỗi khi tải tất cả đề thi:", error);
        const errorMessage = error.response?.data?.message || "Không thể tải danh sách đề thi.";
        message.error(errorMessage);
    } finally {
        loading.value = false;
    }
};

const formatDateTime = (dateTimeString) => {
    if (!dateTimeString) return 'N/A';
    return dayjs(dateTimeString).format('HH:mm DD/MM/YYYY');
};

const statusInfo = (status) => {
    switch (status) {
        case 'SapDienRa': return { text: 'Sắp diễn ra', color: 'blue' };
        case 'DangDienRa': return { text: 'Đang diễn ra', color: 'green' };
        case 'DaKetThuc': return { text: 'Đã kết thúc', color: 'red' };
        default: return { text: 'Không xác định', color: 'grey' };
    }
};

const startExam = (examId) => {
    router.push({ name: 'student-exam-taking', params: { id: examId } });
};

const reviewExam = (examId, resultId) => {
    // router.push({ name: 'student-exam-review', params: { examId, resultId } });
};

onMounted(async () => {
    await fetchAllMyExams();
    signalRConnection.on("ReceiveExam", (exam) => {
        console.log("Received de thi notification:", exam);
        // Check if the exam already exists to avoid duplicates, e.g., by 'made'
        const existingExamIndex = exams.value.findIndex(e => e.made === exam.made);
        if (existingExamIndex === -1) {
            exams.value.unshift(exam);
            message.success(`Có đề thi mới: ${exam.tende}`);
        } else {
            // Optionally update existing exam if needed, e.g., status change
            exams.value[existingExamIndex] = exam;
            message.info(`Cập nhật đề thi: ${exam.tende}`);
        }
    });

    signalRConnection.on("ReceiveExamStatusUpdate", (made, newStatus) => {
        console.log(`Received exam status update for exam ${made}: ${newStatus}`);
        const examIndex = exams.value.findIndex(e => e.made === made);
        if (examIndex !== -1) {
            exams.value[examIndex].trangthaiThi = newStatus;
            message.info(`Trạng thái đề thi ${exams.value[examIndex].tende} đã cập nhật thành ${statusInfo(newStatus).text}`);
        }
    });
});

onUnmounted(() => {
    signalRConnection.off("ReceiveExam");
    signalRConnection.off("ReceiveExamStatusUpdate");
});
</script>

<style scoped>
.ant-card {
    display: flex;
    flex-direction: column;
}

.ant-card-body {
    flex-grow: 1;
}
</style>