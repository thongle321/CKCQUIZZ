<template>
    <div class="row mb-4">
        <div class="col-6 ">
            <a-input v-model:value="searchText" placeholder="Tìm kiếm sinh viên..." allow-clear style="width: 500px">
                <template #prefix>
                    <Search size="14" />
                </template>
            </a-input>
        </div>
    </div>
    <a-spin :spinning="loading" tip="Đang tải chi tiết lớp..." size="large">
        <div v-if="!loading && group" class="class-detail-container">
            <a-card class="opacity-75">
                <div class="row">
                    <div class="col-6">
                        <h2 class="class-title">{{ fullClassName }}</h2>
                    </div>
                    <div class="col-6 d-flex justify-content-end">
                        <span class="class-size">Sĩ số: {{ group.siso }}</span>
                    </div>
                </div>
            </a-card>
            <a-card>
                <a-table :columns="columns" :data-source="students" :loading="studentLoading" rowKey="mssv"
                    :pagination="pagination" @change="handleTableChange">
                    <template #bodyCell="{ column, record, index }">
                        <template v-if="column.key === 'stt'">
                            <span>{{ (pagination.current - 1) * pagination.pageSize + index + 1 }} </span>
                        </template>

                        <template v-if="column.key === 'hoTen'">
                            <a-flex align="center" gap="middle">
                                <a-avatar :src="record.avatar">
                                    <template #icon>
                                        <CircleUserRound />
                                    </template>
                                </a-avatar>
                                <a-flex vertical>
                                    <span class="text-primary fw-bold">{{ record.hoten }}</span>
                              </a-flex>
                            </a-flex>
                        </template>
                    </template>
                </a-table>
            </a-card>
        </div>

        <a-result v-if="!loading && !group" status="404" title="Không tìm thấy lớp học"
            sub-title="Lớp học bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.">
            <template #extra>
                <router-link to="/student/classes">
                    <a-button type="primary">Quay lại danh sách</a-button>
                </router-link>
            </template>
        </a-result>
    </a-spin>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute } from 'vue-router';
import { message } from 'ant-design-vue';
import { Search, CircleUserRound } from 'lucide-vue-next';
import { lopApi } from '@/services/lopService';
import debounce from 'lodash/debounce';

const route = useRoute();
const classId = route.params.id;

const group = ref(null);
const students = ref([]);
const loading = ref(true);
const studentLoading = ref(false);
const searchText = ref('');
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
});

const columns = [
    { title: 'STT', key: 'stt', width: 60, align: 'center' },
    { title: 'Họ tên', dataIndex: 'hoten', key: 'hoTen', width: 250 },
    { title: 'MSSV', dataIndex: 'mssv', key: 'mssv', width: 150 },
];

const subjectName = computed(() => {
    if (group.value && group.value.monHocs && group.value.monHocs.length > 0) {
        return group.value.monHocs[0];
    }
    return 'Chưa có môn học';
});

const fullClassName = computed(() => {
    if (!group.value) {
        return 'Thông tin lớp học';
    }
    const className = group.value.tenlop || '';
    const academicYear = group.value.namhoc || '';
    const semester = group.value.hocky || '';

    return `${subjectName.value} - NH ${academicYear} - HK${semester} - ${className}`;
});

const fetchGroupDetails = async () => {
    try {
        const responseData = await lopApi.getById(classId);
        if (responseData) {
            group.value = responseData;
        } else {
            message.error('Không tải được thông tin lớp. Vui lòng thử lại.');
        }
    } catch (error) {
        message.error('Không tải được thông tin lớp.');
    }
};

const fetchStudents = async () => {
    studentLoading.value = true;
    try {
        const params = {
            searchQuery: searchText.value,
            page: pagination.value.current,
            pageSize: pagination.value.pageSize,
        };
        const res = await lopApi.getStudentsInClass(classId, params);

        if (res && res.items) {
            students.value = res.items;
            pagination.value.total = res.totalCount;
        } else {
            message.error('Không tải được danh sách sinh viên. Vui lòng thử lại.');
            students.value = [];
            pagination.value.total = 0;
        }
    } catch (error) {
        message.error('Không tải được danh sách sinh viên.');
        students.value = [];
        pagination.value.total = 0;
    } finally {
        studentLoading.value = false;
    }
};

watch(searchText, debounce(() => {
    pagination.value.current = 1;
    fetchStudents();
}, 500));

const handleTableChange = (pager) => {
    pagination.value.current = pager.current;
    pagination.value.pageSize = pager.pageSize;
    fetchStudents();
};

onMounted(async () => {
    loading.value = true;
    await Promise.all([fetchGroupDetails(), fetchStudents()]);
    loading.value = false;
});
</script>
<style scoped>
.class-title {
    margin: 0;
    font-size: 20px;
    font-weight: bold;
    color: black;
}

.class-size {
    font-size: 16px;
    color: #e84118;
    font-weight: bold;
}

.class-detail-container .ant-card:first-of-type {
    margin-bottom: 0;
    border-bottom-left-radius: 0;
    border-bottom-right-radius: 0;
}

.class-detail-container .ant-card:last-of-type {
    margin-top: -16px;
    border-top-left-radius: 0;
    border-top-right-radius: 0;
}
</style>