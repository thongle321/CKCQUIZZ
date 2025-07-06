<template>
    <a-card title="Tất cả phân công" style="width: 100%">
        <template #extra>
            <a-button type="primary" size="large" @click="showAddAssignmentModal = true"
                :disabled="!userStore.canCreate('PhanCong')">
                <template #icon>
                    <Plus />
                </template>
                Thêm phân công
            </a-button>
        </template>
        <div class="row mb-4">
            <div class="col-12">
                <a-input placeholder="Tìm kiếm phân công" allow-clear enter-button block>
                    <template #prefix>
                        <Search size="14" />
                    </template>
                </a-input>
            </div>
        </div>
        <a-table :columns="assignmentColumns" :data-source="assignments" :pagination="false" rowKey="id">
            <template #bodyCell="{ column, record, index }">
                <template v-if="column.key === 'id'">
                    {{ index + 1 }}
                </template>
                <template v-else-if="column.key === 'action'">
                    <a-button type="text" danger @click="deleteAssignment(record.mamonhoc, record.manguoidung)"
                        v-if="userStore.canDelete('PhanCong')">
                        <Trash2 />
                    </a-button>
                </template>
            </template>
        </a-table>
    </a-card>

    <a-modal v-model:open="showAddAssignmentModal" title="Thêm phân công mới" width="1000px" @ok="addAssignment"
        @cancel="showAddAssignmentModal = false">
        <a-tabs default-active-key="1">
            <a-tab-pane key="1" tab="Thêm thủ công">
                <a-form layout="vertical">
                    <a-form-item label="Giảng viên">
                        <a-select v-model:value="selectedLecturerId" placeholder="Chọn giảng viên cần phân công"
                            show-search>
                            <a-select-option v-for="lecturer in lecturers" :key="lecturer.id" :value="lecturer.id">
                                {{ lecturer.hoten }}
                            </a-select-option>
                        </a-select>
                        <a-button v-if="selectedLecturerId" danger
                            @click="deleteAllAssignmentsForLecturer(selectedLecturerId)" style="margin-top: 10px;">
                            Xóa tất cả phân công của giảng viên này
                        </a-button>
                    </a-form-item>

                    <a-form-item label="Tìm kiếm môn học">
                        <a-input-search v-model:value="subjectSearchTerm" placeholder="Tìm kiếm môn học..."
                            enter-button @search="handleSubjectSearch" />
                    </a-form-item>

                    <a-table :columns="subjectColumns" :data-source="subjects"
                        :row-selection="{ selectedRowKeys: selectedSubjectIds, onChange: onSelectChange }"
                        :pagination="false" rowKey="mamonhoc">
                        <template #bodyCell="{ column, record }">
                            <template v-if="column.key === 'mamonhoc'">
                                {{ record.mamonhoc }}
                            </template>
                            <template v-else-if="column.key === 'tenmonhoc'">
                                {{ record.tenmonhoc }}
                            </template>
                            <template v-else-if="column.key === 'sotinchi'">
                                {{ record.sotinchi }}
                            </template>
                            <template v-else-if="column.key === 'sotietlythuyet'">
                                {{ record.sotietlythuyet }}
                            </template>
                            <template v-else-if="column.key === 'sotietthuchanh'">
                                {{ record.sotietthuchanh }}
                            </template>
                        </template>
                    </a-table>
                </a-form>
            </a-tab-pane>
        </a-tabs>
        <template #footer>
            <a-button key="back" @click="showAddAssignmentModal = false">Hủy</a-button>
            <a-button key="submit" type="primary" :loading="loading" @click="addAssignment">Lưu phân công</a-button>
        </template>
    </a-modal>

    <div class="modal fade" id="modal-default-vcenter" tabindex="-1" role="dialog"
        aria-labelledby="modal-default-fadein" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Chỉnh sửa phân công</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body pb-1">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-sm btn-alt-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-sm btn-primary" data-bs-dismiss="modal">Done</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { phanCongApi } from '@/services/phanCongService'
import { Modal, message } from 'ant-design-vue'
import { Trash2, Search, Plus } from 'lucide-vue-next'
import { useUserStore } from '@/stores/userStore';

const userStore = useUserStore()
const assignments = ref([]);
const lecturers = ref([]);
const subjects = ref([]);
const subjectSearchTerm = ref('');
const selectedLecturerId = ref('');
const selectedSubjectIds = ref([]);
const showAddAssignmentModal = ref(false);
const loading = ref(false);

const assignmentColumns = [
    { title: 'ID', key: 'id', width: 100, align: 'center' },
    { title: 'Tên giảng viên', dataIndex: 'hoten', key: 'hoten' },
    { title: 'Mã môn', dataIndex: 'mamonhoc', key: 'mamonhoc', align: 'center' },
    { title: 'Môn học', dataIndex: 'tenmonhoc', key: 'tenmonhoc' },
    { title: 'Hành động', key: 'action', align: 'center', width: 100 },
];

const subjectColumns = [
    { title: 'Mã môn học', dataIndex: 'mamonhoc', key: 'mamonhoc', align: 'center' },
    { title: 'Tên môn học', dataIndex: 'tenmonhoc', key: 'tenmonhoc' },
    { title: 'Số tín chỉ', dataIndex: 'sotinchi', key: 'sotinchi', align: 'center' },
    { title: 'Số tiết lý thuyết', dataIndex: 'sotietlythuyet', key: 'sotietlythuyet', align: 'center' },
    { title: 'Số tiết thực hành', dataIndex: 'sotietthuchanh', key: 'sotietthuchanh', align: 'center' },
];

const fetchAssignments = async () => {
    try {
        if (!userStore.canView('PhanCong')) {
            fetchAssignments.value = []
            pagination.total = 0
        }
        assignments.value = await phanCongApi.getAllAssignments();
    } catch (error) {
        console.error('Failed to fetch assignments:', error);
    }
};

const fetchLecturers = async () => {
    try {
        lecturers.value = await phanCongApi.getLecturers();
    } catch (error) {
        console.error('Failed to fetch lecturers:', error);
    }
};

const fetchSubjects = async (searchTerm = '') => {
    try {
        subjects.value = await phanCongApi.getSubjects({ searchTerm });
    } catch (error) {
        console.error('Failed to fetch subjects:', error);
    }
};

const handleSubjectSearch = (value) => {
    fetchSubjects(value);
};

const onSelectChange = (selectedRowKeys) => {
    selectedSubjectIds.value = selectedRowKeys;
};

const addAssignment = async () => {
    if (!selectedLecturerId.value || selectedSubjectIds.value.length === 0) {
        Modal.warning({
            title: 'Thông báo',
            content: 'Vui lòng chọn giảng viên và ít nhất một môn học.',
        });
        return;
    }
    loading.value = true;
    try {
        const response = await phanCongApi.addAssignment(selectedLecturerId.value, selectedSubjectIds.value);

        if (response && response.failedSubjects && response.failedSubjects.length > 0) {
            message.error(response.message || "Một số môn học đã được phân công trước đó.");
        } else if (response && response.addedSubjects && response.addedSubjects.length > 0) {
            message.success(response.message || "Phân công thành công!");
        } else if (response && response.message) {
            message.error(response.message);
        } else {
            message.error("Phân công thất bại! Không có môn học nào được thêm.");
        }

        showAddAssignmentModal.value = false;
        selectedLecturerId.value = '';
        selectedSubjectIds.value = [];
        fetchAssignments();
    } catch (error) {
        if (error.response && error.response.data && error.response.data.message) {
            message.error(error.response.data.message);
        } else {
            message.error("Phân công thất bại! Đã có lỗi xảy ra.");
            console.error('Error adding assignment:', error);
        }
    } finally {
        loading.value = false;
    }
};

const deleteAssignment = async (maMonHoc, maNguoiDung) => {
    Modal.confirm({
        title: 'Xác nhận xóa',
        content: 'Bạn có chắc chắn muốn xóa phân công này?',
        okText: 'Xóa',
        okType: 'danger',
        cancelText: 'Hủy',
        onOk: async () => {
            try {
                await phanCongApi.deleteAssignment(maMonHoc, maNguoiDung);
                message.success("Xóa phân công thành công!")
                fetchAssignments()
            } catch (error) {
                message.error("Xóa phân công thất bại!")
                console.error('Error deleting assignment:', error);
            }
        },
    });
};
const deleteAllAssignmentsForLecturer = async (maNguoiDung) => {
    Modal.confirm({
        title: 'Xác nhận xóa tất cả phân công',
        content: 'Bạn có chắc chắn muốn xóa TẤT CẢ phân công của giảng viên này?',
        okText: 'Xóa tất cả',
        okType: 'danger',
        cancelText: 'Hủy',
        onOk: async () => {
            try {
                await phanCongApi.deleteAllAssignmentsByUser(maNguoiDung);
                message.success("Xóa tất cả phân công của giảng viên thành công!");
                fetchAssignments();
            } catch (error) {
                message.error("Xóa tất cả phân công thất bại!");
                console.error('Error deleting all assignments for lecturer:', error);
            }
        },
    });
};
onMounted(async () => {
    await userStore.fetchUserPermissions();
    Promise.all([fetchAssignments(),
    fetchLecturers(),
    fetchSubjects()])
});
</script>
