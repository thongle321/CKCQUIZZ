<template>
    <div class="row mb-4">
        <div class="col-6 ">
            <a-input v-model:value="searchText" placeholder="Tìm kiếm sinh viên..." allow-clear style="width: 500px">
                <template #prefix>
                    <Search size="14" />
                </template>
            </a-input>
        </div>
        <div class="col-6 d-flex justify-content-end gap-3">
            <a-button type="primary" @click="handleExportExcel">
                <template #icon>
                    <span class="anticon">
                        <Sheet class="mb-1" size="17" />
                    </span>
                </template>
                Xuất danh sách SV
            </a-button>
            <a-button type="primary">
                <template #icon>
                    <span class="anticon">
                        <FileDown class="mb-1" size="17" />
                    </span>
                </template>
                Xuất bảng điểm
            </a-button>
            <a-button type="primary" @click="openAddStudentModal">
                <template #icon>
                    <span class="anticon">
                        <Plus class="mb-1" size="17" />
                    </span>
                </template>
                Thêm sinh viên
            </a-button>
            <a-button type="primary">
                <template #icon>

                    <Settings size="17" />
                </template>
            </a-button>
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
                                    <span v-if="record.email" class="opacity-50">{{ record.email }}

                                    </span>
                                </a-flex>
                            </a-flex>
                        </template>

                        <template v-if="column.key === 'gioitinh'">
                            <span>{{ record.gioitinh ? 'Nam' : 'Nữ' }}</span>
                        </template>

                        <template v-if="column.key === 'ngaysinh'">
                            <span>{{ formatDate(record.ngaysinh) }}</span>
                        </template>

                        <template v-if="column.key === 'action'">
                            <a-tooltip title="Xóa sinh viên">
                                <a-button type="text" danger @click="handleKick(record.id)" :icon="h(SquareX)">
                                </a-button>
                            </a-tooltip>
                        </template>
                    </template>
                </a-table>
            </a-card>
        </div>

        <a-result v-if="!loading && !group" status="404" title="Không tìm thấy lớp học"
            sub-title="Lớp học bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.">
            <template #extra>
                <router-link to="/admin/coursegroup">
                    <a-button type="primary">Quay lại danh sách</a-button>
                </router-link>
            </template>
        </a-result>

        <a-modal width="700px" v-model:open="isAddStudentModalVisible" title="Thêm sinh viên vào lớp"
            :footer="activeKey === '2' ? null : undefined" @ok="handleAddStudent" :confirm-loading="addStudentLoading">
            <a-tabs v-model:activeKey="activeKey">
                <a-tab-pane key="1" tab="Thêm sinh viên thủ công">
                    <a-form ref="addStudentFormRef" :model="addStudentFormState" layout="vertical">
                        <a-form-item label="Mã số sinh viên" name="manguoidungId">
                            <a-input v-model:value="addStudentFormState.manguoidungId"
                                placeholder="Nhập MSSV cần thêm" />
                        </a-form-item>
                    </a-form>
                </a-tab-pane>
                <a-tab-pane key="2" tab="Thêm sinh viên bằng mã mời">
                    <div class="d-flex justify-content-center align-items-center">
                        <span class="h1" @click="copyInviteCode">{{ group.mamoi }}</span>
                    </div>
                    <div class="row mt-5">
                        <div class="col-6">
                            <h6> {{ fullClassName }} </h6>
                        </div>
                        <div class="col-6 d-flex justify-content-end">
                            <a-button style="background-color: rgba(178, 198, 213, 0.5);" size="small"
                                @click="handleRefreshCode">
                                <template #icon>
                                    <RefreshCw class="mb-1 mx-1" size="17" />
                                </template>
                                <span>Tạo mã mời</span>
                            </a-button>
                        </div>
                    </div>
                </a-tab-pane>
            </a-tabs>

        </a-modal>
    </a-spin>
</template>


<script setup>
import { ref, onMounted, h, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { message, Modal } from 'ant-design-vue';
import { Search, Plus, Settings, FileDown, Sheet, RefreshCw, SquareX, CircleUserRound } from 'lucide-vue-next';
import { lopApi } from '@/services/lopService';
import debounce from 'lodash/debounce';

const props = defineProps({
    id: {
        type: [String, Number],
        required: true,
    },
});

const router = useRouter();
const group = ref(null);
const students = ref([]);
const loading = ref(true);
const studentLoading = ref(false);
const searchText = ref('');
const codeLoading = ref(false);
const isAddStudentModalVisible = ref(false);
const addStudentLoading = ref(false);
const addStudentFormRef = ref();
const addStudentFormState = ref({ manguoidungId: '' });
const activeKey = ref('1');
const pagination = ref({
    current: 1,
    pageSize: 10,
    total: 0,
});


const columns = [
    { title: 'STT', key: 'stt', width: 60, align: 'center' },
    { title: 'Họ tên', dataIndex: 'hoten', key: 'hoTen', width: 100, sorter: true },
    { title: 'MSSV', dataIndex: 'mssv', key: 'mssv', width: 100, sorter: true },
    { title: 'Giới tính', dataIndex: 'gioitinh', key: 'gioitinh', width: 100 },
    { title: 'Ngày sinh', dataIndex: 'ngaysinh', key: 'ngaysinh', width: 120 },
    { title: 'Hành động', key: 'action', align: 'center', width: 100 },
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
        const response = await lopApi.getById(props.id);
        group.value = response.data;
    } catch (error) {
        message.error('Không tải được thông tin lớp.');
        router.push('/');
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
        const res = await lopApi.getStudentsInClass(props.id, params)

        students.value = res.data.items
        pagination.value.total = res.data.totalCount

        console.log(students.value)

    } catch (error) {
        message.error('Không tải được danh sách sinh viên.')
        students.value = []
        pagination.value.total = 0
    } finally {
        studentLoading.value = false;
    }
}
watch(searchText, debounce(() => {
    pagination.value.current = 1;
    fetchStudents();
}, 500))
const handleTableChange = (pager) => {
    pagination.value.current = pager.current;
    pagination.value.pageSize = pager.pageSize;
    fetchStudents();
};

const copyInviteCode = async () => {
    try {
        if (group.value && group.value.mamoi) {
            await navigator.clipboard.writeText(group.value.mamoi);
            message.success('Đã sao chép mã mời!');
        } else {
            message.warn('Không có mã mời để sao chép.');
        }
    } catch (err) {
        message.error('Không thể sao chép mã mời.');
    }
};

const handleRefreshCode = async () => {
    codeLoading.value = true;
    try {
        const response = await lopApi.refreshInviteCode(props.id);
        group.value.mamoi = response.data.inviteCode;
        message.success('Đã tạo mã mời mới!');
    } catch (error) {
        message.error('Tạo mã mời mới thất bại!');
    } finally {
        codeLoading.value = false;
    }
};

const openAddStudentModal = () => {
    addStudentFormState.value.manguoidungId = '';
    isAddStudentModalVisible.value = true;
};

const handleAddStudent = async () => {
    try {
        await addStudentFormRef.value.validate();
        addStudentLoading.value = true;

        await lopApi.addStudentToClass(props.id, addStudentFormState.value);

        message.success(`Đã thêm SV ${addStudentFormState.value.manguoidungId} vào lớp.`);
        isAddStudentModalVisible.value = false;
        fetchStudents();
        fetchGroupDetails();
    } catch (error) {
        const errorMessage = error.response?.data?.message || error.response?.data || 'Thêm sinh viên thất bại!';
        message.error(errorMessage);
    } finally {
        addStudentLoading.value = false;
    }
};

// const handleKick = async (studentId) => {
//     try {
//         await lopApi.kickStudentFromClass(props.id, studentId);
//         message.success(`Đã xóa SV ${studentId} khỏi lớp.`);
//         fetchStudents();
//         fetchGroupDetails();
//     } catch (error) {
//         message.error('Xóa sinh viên thất bại!');
//     }
// };
const handleKick = async (studentId) => {
    Modal.confirm({
        title: 'Xác nhận xóa sinh viên',
        content: `Bạn có chắc chắn muốn xóa sinh viên ${studentId}?`,
        okText: 'Có',
        okType: 'danger',
        cancelText: 'Không',
        onOk: async () => {
            try {
                await lopApi.kickStudentFromClass(props.id, studentId);
                message.success(`Đã xóa sinh viên ${studentId} ra khỏi lớp`);
                fetchStudents();
                fetchGroupDetails();
            } catch (error) {
                message.error('Lỗi khi xóa sinh viên: ' + (error.response?.data || error.message));
                console.error(error);
            }
        },
    });
};
const formatDate = (dateString) => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('vi-VN');
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