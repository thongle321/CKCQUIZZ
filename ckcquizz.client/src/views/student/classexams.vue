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
                :grid="{ gutter: 24, xs: 1, sm: 1, md: 2, lg: 3, xl: 4, xxl: 4 }" :data-source="exams">
                <template #renderItem="{ item }">
                    <a-list-item>
                        <a-card hoverable class="h-100 d-flex flex-column" style="width: 300px">
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
                                        Vào thi
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
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import { message } from 'ant-design-vue';
import { Layers, BookOpenCheck, ListOrdered, Clock, CalendarRange, CalendarOff, PlayCircle, History } from 'lucide-vue-next';
import dayjs from 'dayjs';

const router = useRouter();
const exams = ref([]);
const loading = ref(true);

const fetchAllMyExams = async () => {
    loading.value = true;
    try {
        const response = await apiClient.get('/DeThi/my-exams');
        exams.value = response.data;
    } catch (error) {
        console.error("Lỗi khi tải tất cả đề thi:", error);
        const errorMessage = error.response?.data?.message || "Không thể tải danh sách đề thi.";
        message.error(errorMessage);
    } finally {
        loading.value = false;
    }
};

// SỬA HÀM NÀY LẠI CHO ĐÚNG CHUẨN VUE
const formatDateTime = (dateTimeString) => {
    if (!dateTimeString) return 'N/A';
    // Trả về một chuỗi bình thường, trên một dòng
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
    // router.push({ name: 'student-exam-do', params: { examId } });
};

const reviewExam = (examId, resultId) => {
    // router.push({ name: 'student-exam-review', params: { examId, resultId } });
};

onMounted(fetchAllMyExams);
</script>

<style scoped>
/* Giữ lại style này để đảm bảo card co giãn tốt và các card trong một hàng có chiều cao bằng nhau */
.ant-card {
    display: flex;
    flex-direction: column;
}

.ant-card-body {
    flex-grow: 1;
    /* Quan trọng để đẩy actions xuống dưới cùng */
}
</style>