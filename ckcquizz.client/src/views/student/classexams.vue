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
                                    <a-button v-if="item.isResumable" type="primary" @click="startExam(item.made)" block>
                                        <template #icon>
                                            <PlayCircle size="16" />
                                        </template>
                                        Tiếp tục vào thi
                                    </a-button>
                                    <a-button class="bg-success text-white" v-else-if="item.ketQuaId && item.trangthaiThi === 'DaKetThuc' && (item.xemdapan || item.hienthibailam || item.xemdiemthi)" @click="examResult(item.made, item.ketQuaId)" block>
                                        <template #icon>
                                            <History size="16" />
                                        </template>
                                        Xem kết quả
                                    </a-button>
                                    <a-button type="primary" v-else-if="item.ketQuaId && (item.trangthaiThi !== 'DaKetThuc' || (item.trangthaiThi === 'DaKetThuc' && !(item.xemdapan || item.hienthibailam || item.xemdiemthi)))" danger block>
                                        Đã nộp bài
                                    </a-button>
                                    <a-button type="primary"  v-else-if="item.trangthaiThi === 'DangDienRa'" @click="startExam(item.made)" block>
                                        <template #icon>
                                            <PlayCircle size="16" />
                                        </template>
                                        Vào thi
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
import { ref, onMounted, onUnmounted, onActivated } from 'vue';
import { useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import { message } from 'ant-design-vue';
import { Layers, BookOpenCheck, ListOrdered, Clock, CalendarRange, CalendarOff, PlayCircle, History } from 'lucide-vue-next';
import dayjs from 'dayjs';
import utc from 'dayjs/plugin/utc';
import timezone from 'dayjs/plugin/timezone';
import signalRConnection, {startConnection} from '@/services/signalrDeThiService';

dayjs.extend(utc);
dayjs.extend(timezone);

const router = useRouter();
const exams = ref([]);
const loading = ref(true);

const fetchAllMyExams = async () => {
    loading.value = true;
    try {
        const response = await apiClient.get('/DeThi/my-exams');
        exams.value = response.data.map(exam => {
            const storedKetQuaId = sessionStorage.getItem(`exam-${exam.made}-ketQuaId`);
            return {
                ...exam,
                isResumable: storedKetQuaId && exam.trangthaiThi === 'DangDienRa'
            };
        });
    } catch (error) {
        const errorMessage = error.response?.data?.message || "Không thể tải danh sách đề thi.";
        message.error(errorMessage);
    } finally {
        loading.value = false;
    }
};

const formatDateTime = (dateTimeString) => {
    if (!dateTimeString) return 'N/A';
    return dayjs.utc(dateTimeString).tz('Asia/Ho_Chi_Minh').format('HH:mm DD/MM/YYYY');
};

const statusInfo = (status) => {
    switch (status) {
        case 'SapDienRa': return { text: 'Sắp diễn ra', color: 'blue' };
        case 'DangDienRa': return { text: 'Đang diễn ra', color: 'green' };
        case 'DaKetThuc': return { text: 'Đã đóng', color: 'red' };
        default: return { text: 'Không xác định', color: 'grey' };
    }
};

const startExam = (examId) => {
    router.push({ name: 'student-exam-taking', params: { id: examId } });
};

const examResult = (examId, resultId) => {
    router.push({ name: 'student-exam-result', params: { examId, resultId } });
};

onMounted(async () => {
    await fetchAllMyExams();
    startConnection();
    signalRConnection.on("ReceiveExam", (exam) => {
        const storedKetQuaId = sessionStorage.getItem(`exam-${exam.made}-ketQuaId`);
        const updatedExam = {
            ...exam,
            isResumable: storedKetQuaId && exam.trangthaiThi === 'DangDienRa'
        };

        const existingExamIndex = exams.value.findIndex(e => e.made === exam.made);
        if (existingExamIndex === -1) {
            exams.value.unshift(updatedExam);
            message.success(`Có đề thi mới: ${exam.tende}`);
        } else {
            exams.value[existingExamIndex] = updatedExam;
        }
    });

    signalRConnection.on("ReceiveExamStatusUpdate", (made, newStatus) => {
        const examIndex = exams.value.findIndex(e => e.made === made);
        if (examIndex !== -1) {
            const storedKetQuaId = sessionStorage.getItem(`exam-${made}-ketQuaId`);
            exams.value[examIndex].trangthaiThi = newStatus;
            exams.value[examIndex].isResumable = storedKetQuaId && newStatus === 'DangDienRa';
        }
    });
});

onActivated(async () => {
    await fetchAllMyExams();
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