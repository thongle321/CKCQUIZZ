<template>
  <a-card class="mb-3" title="Tất cả thông báo" style="width: 100%">
    <div class="row">
      <div class="col-6">
        <a-input v-model:value="searchQuery" placeholder="Tìm kiếm theo nội dung thông báo..." @search="handleSearch"
          allow-clear enter-button>
          <template #prefix>
            <Search size="14" style="vertical-align: middle;" />
          </template>
        </a-input>
      </div>
      <div class="col-6 d-flex justify-content-end">
        <a-button type="primary" size="large" @click="showAddModal">
          <template #icon>
            <Plus />
          </template>
          Tạo thông báo
        </a-button>
      </div>
    </div>
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
              <a-tag color="#BDE6F1" class="text-black rounded-4" @click="showUpdateModal(announce.matb)">
                <template #icon>
                  <Wrench size="13" style="vertical-align: middle; margin-right: 1px; margin-bottom: 1px;" />

                </template>
                Chỉnh sửa
              </a-tag>
              <a-tag color="#FFCDB2" class="text-black rounded-4" @click="handleDelete(announce.matb)">
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
      <a-form-item label="Thông báo cho học phần" name="mamonhoc">
        <a-select v-model:value="announcementForm.mamonhoc" placeholder="Chọn học phần để xem danh sách nhóm"
          @change="onSubjectChange" :disabled="!!announcementForm.matb">
          <a-select-option v-for="subject in subjects" :key="subject.mamonhoc" :value="subject.mamonhoc">
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


const announcements = ref([]);
const subjects = ref([]);
const isLoading = ref(false);
const searchQuery = ref('');

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

const initialFormState = {
  matb: null,
  noidung: '',
  mamonhoc: undefined,
  nhomIds: [],
};
const announcementForm = reactive({ ...initialFormState });

const formRules = ref({
  noidung: [{ required: true, message: 'Nội dung thông báo không được để trống', trigger: 'blur' }],
  mamonhoc: [{ required: true, message: 'Vui lòng chọn học phần', trigger: 'change' }],
  nhomIds: [{ required: true, type: 'array', min: 1, message: 'Phải chọn ít nhất một nhóm để gửi', trigger: 'change' }],
});

const currentSubjectGroups = computed(() => {
  const selectedSubject = subjects.value.find(s => s.mamonhoc === announcementForm.mamonhoc);
  return selectedSubject?.nhomLop ?? [];
});

const fetchAnnouncements = async () => {
  isLoading.value = true;
  try {
    const response = await thongBaoApi.getAll({
      page: pagination.current, pageSize: pagination.pageSize, search: searchQuery.value,
    });
    if (response && Array.isArray(response.items)) {
      announcements.value = response.items;
      pagination.total = response.totalCount || 0;
    } else {
      announcements.value = [];
      pagination.total = 0;
    }
  } catch (error) {
    console.error('Lỗi khi tải thông báo:', error);
    message.error('Không thể tải danh sách thông báo.');
    announcements.value = [];
    pagination.total = 0;
  } finally {
    isLoading.value = false;
  }
};

const fetchSubjects = async () => {
  isLoading.value = true;
  try {
    const response = await thongBaoApi.getSubjectsWithGroups();
    if (Array.isArray(response)) {
      subjects.value = response;
    } else {
      subjects.value = [];
    }
  } catch (error) {
    console.error('Lỗi khi tải học phần:', error);
    message.error('Không thể tải danh sách học phần.');
  } finally {
    isLoading.value = false;
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
  Object.assign(announcementForm, initialFormState);
  modalTitle.value = 'Tạo và gửi thông báo';
  selectAllGroups.value = false;
  isModalVisible.value = true;
};

const showUpdateModal = async (matb) => {
  modalTitle.value = 'Cập nhật thông báo';
  isModalVisible.value = true;
  isModalLoading.value = true;
  try {
    const response = await thongBaoApi.getDetail(matb);
    Object.assign(announcementForm, {
      matb: response.matb,
      noidung: response.noidung,
      mamonhoc: response.mamonhoc,
      nhomIds: response.nhom ?? [],
    });
    selectAllGroups.value = currentSubjectGroups.value.length > 0 &&
      currentSubjectGroups.value.every(g => announcementForm.nhomIds.includes(g.manhom));
  } catch (error) {
    console.error('Lỗi khi tải chi tiết thông báo:', error);
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

    const payload = {
      noidung: announcementForm.noidung,
      nhomIds: announcementForm.nhomIds,
    };

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

const onSubjectChange = () => {
  announcementForm.nhomIds = [];
  selectAllGroups.value = false;
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

onMounted(() => {
  fetchAnnouncements();
  fetchSubjects();
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