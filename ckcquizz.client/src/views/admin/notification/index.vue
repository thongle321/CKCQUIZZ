<template>
  <a-card class="mb-3" title="Tất cả thông báo" style="width: 100%">
    <template #extra>
      <a-button type="primary" size="large" @click="showAddModal" v-if="userStore.canCreate('ThongBao')">
        <template #icon>
          <Plus />
        </template>
        Tạo thông báo
      </a-button>
    </template>
    <a-row class="mb-3">
      <a-col :span="24">
        <a-input v-model:value="searchQuery" placeholder="Tìm kiếm theo nội dung thông báo..." @search="handleSearch"
          allow-clear enter-button>
          <template #prefix>
            <Search size="14" style="vertical-align: middle;" />
          </template>
        </a-input>
      </a-col>
    </a-row>
  </a-card>

  <a-spin class="d-flex justify-content-center align-items-center" :spinning="isLoading" tip="Đang tải dữ liệu...">
    <div v-if="announcements.length > 0" class="list-announces">
      <a-card v-for="announce in announcements" :key="announce.matb"
        class="mb-3 shadow-sm border-start border-3 border-success" :bodyStyle="{ padding: 0 }">
        <a-row align="middle">
          <a-col :xs="24" :md="16" class="p-3">
            <h4 class="fw-bold mb-2">{{ announce.noidung }}</h4>
            <p class="fs-sm text-muted mb-0">
              <Layers size="14" color="black" />
              Gửi cho học phần
              <a-tooltip>
                <strong class="text-primary" style="cursor: pointer">
                  {{ announce.tenmonhoc }} - NH{{ announce.namhoc }} - HK{{ announce.hocky }}
                </strong>
              </a-tooltip>
            </p>
          </a-col>
          <a-col :xs="24" :md="8"
            class="p-3 text-md-end bg-light-subtle bg-md-transparent d-flex flex-md-column align-items-md-end justify-content-md-center">
            <div class="d-flex align-items-center justify-content-center">
              <a-tag color="#E7EFC7" class="text-black rounded-4">
                <template #icon>
                  <Clock size="13" style="vertical-align: middle; margin-right: 1px; margin-bottom: 1px;" />
                </template>
                {{ formatDate(announce.thoigiantao) }}
              </a-tag>
              <a-tag color="#BDE6F1" class="text-black rounded-4" @click="showUpdateModal(announce.matb)"
                v-if="userStore.canUpdate('ThongBao')">
                <template #icon>
                  <Wrench size="13" style="vertical-align: middle; margin-right: 1px; margin-bottom: 1px;" />

                </template>
                Chỉnh sửa
              </a-tag>
              <a-tag color="#FFCDB2" class="text-black rounded-4" @click="handleDelete(announce.matb)"
                v-if="userStore.canDelete('ThongBao')">
                <template #icon>
                  <X size="13" style="vertical-align: middle; margin-right: 1px; margin-bottom: 1px;" />

                </template>
                Xoá thông báo
              </a-tag>
            </div>
          </a-col>
        </a-row>
      </a-card>
    </div>
    <a-empty v-else-if="!isLoading" description="Không có thông báo nào được tìm thấy." />
  </a-spin>

  <div class="d-flex justify-content-center mt-4" v-if="!isLoading && pagination.total > 0">
    <a-pagination v-model:current="pagination.current" v-model:page-size="pagination.pageSize" :total="pagination.total"
      show-less-items @change="handlePageChange" />
  </div>

  <a-modal :open="isModalVisible" :title="modalTitle" :confirm-loading="isModalLoading" width="800px"
    @ok="handleModalOk" @cancel="handleModalCancel" :destroyOnClose="true">
    <a-form ref="announcementFormRef" :model="announcementForm" :rules="formRules" layout="vertical" class="mt-4">
      <a-form-item label="Nội dung thông báo" name="noidung">
        <a-textarea v-model:value="announcementForm.noidung" :rows="4" placeholder="Nhập nội dung thông báo cần gửi" />
      </a-form-item>
      <!-- SỬA: Thay đổi v-model và name của Form Item -->
      <a-form-item label="Thông báo cho học phần" name="subject_unique_key">
        <!-- SỬA: v-model giờ đây trỏ tới subject_unique_key -->
        <a-select v-model:value="announcementForm.subject_unique_key" placeholder="Chọn học phần để xem danh sách nhóm"
          @change="onSubjectChange" :disabled="!!announcementForm.matb">
          <!-- SỬA: Sử dụng một hàm để tạo key và value duy nhất cho mỗi option -->
          <a-select-option v-for="subject in subjects" :key="createSubjectUniqueKey(subject)" :value="createSubjectUniqueKey(subject)">
            {{ subject.mamonhoc }} - {{ subject.tenmonhoc }} - NH{{ subject.namhoc }} - HK{{ subject.hocky }}
          </a-select-option>
        </a-select>
      </a-form-item>

      <div>
        <label class="ant-form-item-label">Gửi đến các nhóm</label>
        <div class="border p-3 bg-light rounded">
          <div v-if="currentSubjectGroups.length > 0">
            <a-checkbox v-model:checked="selectAllGroups" @change="onSelectAllGroupsChange" class="mb-3">
              <strong>Chọn tất cả các nhóm</strong>
            </a-checkbox>
            <hr class="my-2" />
            <a-form-item name="nhomIds" :rules="formRules.nhomIds" no-style>
              <a-checkbox-group v-model:value="announcementForm.nhomIds" style="width: 100%;">
                <a-row :gutter="[8, 8]">
                  <a-col :span="8" v-for="group in currentSubjectGroups" :key="group.manhom">
                    <a-checkbox :value="group.manhom">{{ group.tennhom }}</a-checkbox>
                  </a-col>
                </a-row>
              </a-checkbox-group>
            </a-form-item>
          </div>
          <div v-else class="text-center fs-sm">
            <p class="mb-0">Vui lòng chọn một học phần để hiển thị các nhóm.</p>
          </div>
        </div>
      </div>
    </a-form>
  </a-modal>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { Modal, message } from 'ant-design-vue';
import { Search, Plus, Clock, Wrench, X, Layers } from 'lucide-vue-next'
import { thongBaoApi } from '@/services/thongBaoService';
import { useAuthStore } from '@/stores/authStore';
import { useUserStore } from '@/stores/userStore';

const userStore = useUserStore();
const announcements = ref([]);
const subjects = ref([]);
const isLoading = ref(false);
const searchQuery = ref('');

const authStore = useAuthStore();
const isAdmin = computed(() => authStore.userRoles.includes('Admin'));

const pagination = reactive({
  current: 1,
  pageSize: 5,
  total: 0,
});

const isModalVisible = ref(false);
const isModalLoading = ref(false);
const modalTitle = ref('');
const announcementFormRef = ref(null);
const selectAllGroups = ref(false);

// SỬA: Cập nhật trạng thái ban đầu của form
const initialFormState = {
  matb: null,
  noidung: '',
  subject_unique_key: undefined, // Dùng để binding với a-select
  mamonhoc: undefined, // Vẫn giữ mamonhoc gốc nếu API cần
  nhomIds: [],
};
const announcementForm = reactive({ ...initialFormState });

// SỬA: Cập nhật form rules để validate trường mới
const formRules = ref({
  noidung: [{ required: true, message: 'Nội dung thông báo không được để trống', trigger: 'blur' }],
  subject_unique_key: [{ required: true, message: 'Vui lòng chọn học phần', trigger: 'change' }],
  nhomIds: [{ required: true, type: 'array', min: 1, message: 'Phải chọn ít nhất một nhóm để gửi', trigger: 'change' }],
});

// MỚI: Hàm tiện ích để tạo khóa duy nhất cho môn học
const createSubjectUniqueKey = (subject) => {
  if (!subject) return null;
  return `${subject.mamonhoc}-${subject.namhoc}-${subject.hocky}`;
};

// SỬA: Cập nhật computed property để tìm nhóm dựa trên khóa duy nhất
const currentSubjectGroups = computed(() => {
  if (!announcementForm.subject_unique_key) {
    return [];
  }
  const selectedSubject = subjects.value.find(s => createSubjectUniqueKey(s) === announcementForm.subject_unique_key);
  return selectedSubject?.nhomLop ?? [];
});

const fetchAnnouncements = async () => {
  isLoading.value = true;
  try {
    if (!userStore.canView('ThongBao')) {
      announcements.value = []
      pagination.total = 0
      return
    }
    let response;
    if (isAdmin.value) {
      response = await thongBaoApi.getAllAdmin({
        page: pagination.current, pageSize: pagination.pageSize, search: searchQuery.value,
      });
    } else {
      response = await thongBaoApi.getAll({
        page: pagination.current, pageSize: pagination.pageSize, search: searchQuery.value,
      });
    }

    if (response && Array.isArray(response.items)) {
      announcements.value = response.items;
      pagination.total = response.totalCount || 0;
    } else {
      announcements.value = [];
      pagination.total = 0;
    }
  } catch (error) {
    announcements.value = [];
    pagination.total = 0;
  } finally {
    isLoading.value = false;
  }
};

const fetchSubjects = async () => {
  try {
    let response
    if (isAdmin.value) {
      response = await thongBaoApi.getSubjectsWithGroupsAdmin();
    }
    else {
      response = await thongBaoApi.getSubjectsWithGroups();
    }
    if (Array.isArray(response)) {
      subjects.value = response;
    } else {
      subjects.value = [];
    }
  } catch (error) {
    message.error('Không thể tải danh sách học phần.');
  }
};

const handleSearch = () => {
  pagination.current = 1;
  fetchAnnouncements();
};

const handlePageChange = (page, pageSize) => {
  pagination.current = page;
  pagination.pageSize = pageSize;
  fetchAnnouncements();
};

const showAddModal = () => {
  Object.assign(announcementForm, { ...initialFormState });
  modalTitle.value = 'Tạo và gửi thông báo';
  selectAllGroups.value = false;
  isModalVisible.value = true;
};

const showUpdateModal = async (matb) => {
  modalTitle.value = 'Cập nhật thông báo';
  isModalVisible.value = true;
  isModalLoading.value = true;
  try {
    // QUAN TRỌNG: API getDetail cần trả về mamonhoc, namhoc, và hocky
    const response = await thongBaoApi.getDetail(matb);

    // SỬA: Xây dựng lại khóa duy nhất từ dữ liệu API
    Object.assign(announcementForm, {
      matb: response.matb,
      noidung: response.noidung,
      subject_unique_key: createSubjectUniqueKey(response), // Tạo khóa duy nhất
      mamonhoc: response.mamonhoc, // Lưu mã môn học gốc
      nhomIds: response.nhom ?? [],
    });

    selectAllGroups.value = currentSubjectGroups.value.length > 0 &&
      currentSubjectGroups.value.every(g => announcementForm.nhomIds.includes(g.manhom));
  } catch (error) {
    message.error('Không thể tải chi tiết thông báo.');
    isModalVisible.value = false;
  } finally {
    isModalLoading.value = false;
  }
};

const handleDelete = (matb) => {
  Modal.confirm({
    title: 'Bạn có chắc chắn muốn xoá?',
    content: 'Thông báo này sẽ bị xoá vĩnh viễn và không thể khôi phục.',
    okText: 'Ok',
    okType: 'danger',
    cancelText: 'Huỷ',
    async onOk() {
      try {
        await thongBaoApi.delete(matb);
        message.success('Xoá thông báo thành công!');
        if (announcements.value.length === 1 && pagination.current > 1) {
          pagination.current--;
        }
        fetchAnnouncements();
      } catch (error) {
        console.error('Lỗi khi xoá thông báo:', error);
        message.error('Xoá thông báo không thành công.');
      }
    },
  });
};

const handleModalOk = async () => {
  try {
    await announcementFormRef.value.validate();
    isModalLoading.value = true;

    // Payload không thay đổi vì server có thể suy ra từ nhomIds
    const payload = {
      noidung: announcementForm.noidung,
      nhomIds: announcementForm.nhomIds,
    };
    
    // Nếu API create yêu cầu mamonhoc, bạn cần thêm nó vào đây
    // if (!announcementForm.matb) {
    //   payload.mamonhoc = announcementForm.mamonhoc;
    // }

    if (announcementForm.matb) {
      await thongBaoApi.update(announcementForm.matb, payload);
      message.success('Cập nhật thông báo thành công!');
    } else {
      await thongBaoApi.create(payload);
      message.success('Gửi thông báo thành công!');
    }
    isModalVisible.value = false;
    await fetchAnnouncements();
  } catch (validationError) {
    console.log('Lỗi validation:', validationError);
  } finally {
    isModalLoading.value = false;
  }
};

const handleModalCancel = () => {
  isModalVisible.value = false;
};

// SỬA: Cập nhật hàm onSubjectChange
const onSubjectChange = (uniqueKey) => {
  announcementForm.nhomIds = [];
  selectAllGroups.value = false;
  // Lấy mamonhoc gốc từ khóa duy nhất nếu cần
  if (uniqueKey) {
    announcementForm.mamonhoc = uniqueKey.split('-')[0];
  } else {
    announcementForm.mamonhoc = undefined;
  }
};

const onSelectAllGroupsChange = (e) => {
  const isChecked = e.target.checked;
  announcementForm.nhomIds = isChecked ? currentSubjectGroups.value.map(g => g.manhom) : [];
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleString('vi-VN', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
};

onMounted(async () => {
  isLoading.value = true;
  await userStore.fetchUserPermissions();
  await Promise.all([
    fetchAnnouncements(),
    fetchSubjects()
  ]);
  isLoading.value = false;
});
</script>

<style scoped>
.ant-btn .fa {
  vertical-align: middle;
}

@media (max-width: 767.98px) {
  .bg-md-transparent {
    background-color: #f8f9fa !important;
    border-top: 1px solid #dee2e6;
    margin-top: 1rem;
    padding-top: 1rem !important;
  }
}
</style>