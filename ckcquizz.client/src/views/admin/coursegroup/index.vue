<template>
  <a-card title="Quản lý lớp học phần" style="width: 100%">
    <div class="row">
      <div class="col-6">
        <a-input-group compact>
          <a-select v-model:value="filterStatus" @change="fetchGroups">
            <a-select-option :value="true">Đang giảng dạy</a-select-option>
            <a-select-option :value="false">Đã ẩn</a-select-option>
          </a-select>
          <a-input v-model:value="searchText" placeholder="Tìm kiếm theo tên lớp..." allow-clear
            style="width: calc(100% - 150px);">
          </a-input>
        </a-input-group>
      </div>
      <div class="col-6 d-flex justify-content-end">
        <a-button type="primary" size="large" @click="openAddModal">
          <template #icon>
            <Plus />
          </template>
          Thêm lớp mới
        </a-button>
      </div>

    </div>
  </a-card>
  <a-spin :spinning="loading" tip="Đang tải dữ liệu...">
    <div v-if="Object.keys(groupedGroups).length === 0 && !loading" class="text-center p-10 bg-gray-50 rounded-lg">
      <a-empty description="Không có lớp học nào phù hợp." />
    </div>
    <div v-else>
      <div v-for="(subjectGroup, subjectName) in groupedGroups" :key="subjectName">
        <h5 class="text-lg font-bold my-4">
          {{ subjectName }} - NH {{ subjectGroup[0].namhoc }} - HK{{ subjectGroup[0].hocky }}
        </h5>
        <a-row>
          <a-col v-for="group in subjectGroup" :key="group.malop" :xs="24" :sm="12" :lg="6">
            <router-link :to="{ name: 'admin-classdetail', params: { id: group.malop } }">
              <a-card hoverable size="small" class="h-full flex flex-col mx-4 mb-4">
                <template #title>
                  <div class="font-bold text-base1">{{ group.tenlop }}</div>
                </template>
                <template #extra>
                  <a-dropdown :trigger="['click']">
                    <a class="ant-dropdown-link" @click.prevent>
                      <Settings />
                    </a>
                    <template #overlay>
                      <a-menu>
                        <a-menu-item @click="openEditModal(group)">
                          Sửa thông tin
                        </a-menu-item>
                        <a-menu-item @click="handleToggleStatus(group, !group.hienthi)">
                          {{ group.hienthi ? 'Ẩn lớp' : 'Hiện lớp' }}
                        </a-menu-item>
                        <a-menu-item>
                          <a-popconfirm title="Bạn chắc chắn muốn xóa lớp này?" ok-text="Xóa" ok-type="danger"
                            cancel-text="Hủy" @confirm="handleDelete(group.malop)">
                            <span class="text-red-500">Xóa lớp</span>
                          </a-popconfirm>
                        </a-menu-item>
                      </a-menu>
                    </template>
                  </a-dropdown>
                </template>
                <div class="flex-grow">
                  <p v-if="group.ghichu"><strong>Ghi chú:</strong> {{ group.ghichu }}</p>
                  <p><strong>Sĩ số:</strong> {{ group.siso }}</p>
                </div>
              </a-card>
            </router-link>

          </a-col>
        </a-row>
      </div>
    </div>
  </a-spin>

  <a-modal v-model:open="isModalVisible" :title="modalTitle" @ok="handleOk" :confirm-loading="modalLoading"
    :destroyOnClose="true" ok-text="Lưu" cancel-text="Hủy">
    <a-spin :spinning="modalDetailLoading" tip="Đang tải chi tiết...">
      <a-form ref="formRef" :model="formState" layout="vertical" class="mt-4">
        <a-form-item label="Tên lớp học" name="tenlop" :rules="[{ required: true, message: 'Vui lòng nhập tên lớp!' }]">
          <a-input v-model:value="formState.tenlop" placeholder="VD: Lập trình Web - Nhóm 1" />
        </a-form-item>

        <a-form-item label="Môn học" name="mamonhoc"
          :rules="[{ required: true, message: 'Vui lòng chọn một môn học!' }]">
          <a-select v-model:value="formState.mamonhoc" placeholder="Chọn môn học cho lớp này" :options="monHocOptions"
            :loading="monHocLoading" />
        </a-form-item>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="Năm học" name="namhoc" :rules="[{ required: true, message: 'Vui lòng chọn năm học!' }]">
              <a-select v-model:value="formState.namhoc" placeholder="Chọn năm học">
                <a-select-option :value="2024">2023-2024</a-select-option>
                <a-select-option :value="2023">2022-2023</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="Học kỳ" name="hocky" :rules="[{ required: true, message: 'Vui lòng chọn học kỳ!' }]">
              <a-select v-model:value="formState.hocky" placeholder="Chọn học kỳ">
                <a-select-option :value="1">Học kỳ 1</a-select-option>
                <a-select-option :value="2">Học kỳ 2</a-select-option>
                <a-select-option :value="3">Học kỳ Hè</a-select-option>
              </a-select>
            </a-form-item>
          </a-col>
        </a-row>

        <a-form-item label="Ghi chú" name="ghichu">
          <a-textarea v-model:value="formState.ghichu" placeholder="Nhập ghi chú (nếu có)" :rows="2" />
        </a-form-item>
      </a-form>
    </a-spin>
  </a-modal>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { message } from 'ant-design-vue';
import { Plus, Settings } from 'lucide-vue-next';
import { lopApi } from '@/services/lopService';

const groups = ref([]);
const loading = ref(true);
const filterStatus = ref(true);
const searchText = ref('');

const isModalVisible = ref(false);
const modalLoading = ref(false);
const modalDetailLoading = ref(false);
const isEditing = ref(false);
const editingId = ref(null);
const formRef = ref();

const monHocOptions = ref([]);
const monHocLoading = ref(false);

const initialFormState = {
  tenlop: '',
  ghichu: '',
  mamonhoc: null,
  namhoc: new Date().getFullYear(),
  hocky: 1,
  hienthi: true,
  trangthai: true,
};
const formState = ref({ ...initialFormState });

const modalTitle = computed(() => (isEditing.value ? 'Cập nhật thông tin lớp' : 'Thêm lớp mới'));
const groupedGroups = computed(() => {
  const grouped = {};
  const filtered = searchText.value
    ? groups.value.filter(group =>
      group.tenlop.toLowerCase().includes(searchText.value.toLowerCase())
    )
    : groups.value;

  filtered.forEach(group => {
    const subjectName = group.monHocs && group.monHocs.length > 0
      ? group.monHocs[0]
      : 'Chưa có môn học';

    if (!grouped[subjectName]) {
      grouped[subjectName] = [];
    }
    grouped[subjectName].push(group);
  });
  return grouped;
});

const fetchGroups = async () => {
  loading.value = true;
  try {
    const params = { hienthi: filterStatus.value };
    const response = await lopApi.getAll(params);
    groups.value = response.data;
  } catch (error) {
    message.error('Lỗi khi tải danh sách lớp!');
  } finally {
    loading.value = false;
  }
};

const fetchMonHocs = async () => {
  monHocLoading.value = true;
  try {
    const response = await lopApi.getMonHocs();
    monHocOptions.value = response.data.map(mh => ({
      label: mh.tenmonhoc,
      value: mh.mamonhoc,
    }));
  } catch (error) {
    message.error('Lỗi khi tải danh sách môn học!');
  } finally {
    monHocLoading.value = false;
  }
};

onMounted(() => {
  Promise.all([fetchGroups(), fetchMonHocs()]);
});

const handleToggleStatus = async (group, status) => {
  const originalStatus = group.hienthi;
  group.hienthi = status;
  try {
    await lopApi.toggleStatus(group.malop, { status: status });
    message.success(`Đã ${status ? 'hiển thị' : 'ẩn'} lớp học.`);
    fetchGroups();
  } catch (error) {
    group.hienthi = originalStatus;
    message.error('Cập nhật trạng thái thất bại!');
  }
};

const handleDelete = async (id) => {
  try {
    await lopApi.delete(id);
    message.success('Xóa lớp thành công!');
    fetchGroups();
  } catch (error) {
    console.error('Error deleting class:', error);
    message.error(`Xóa lớp thất bại: ${error.response?.data?.message || error.message}`);
  }
};

const openAddModal = () => {
  isEditing.value = false;
  formState.value = { ...initialFormState };
  isModalVisible.value = true;
};

const openEditModal = async (group) => {
  isEditing.value = true;
  editingId.value = group.malop;
  isModalVisible.value = true;
  modalDetailLoading.value = true;

  try {
    formState.value = {
      ...group,
      mamonhoc: group.danhSachLops && group.danhSachLops.length > 0 ? group.danhSachLops[0].mamonhoc : null,
    };
  } catch (error) {
    message.error("Không thể tải chi tiết lớp học để sửa!");
    isModalVisible.value = false;
  } finally {
    modalDetailLoading.value = false;
  }
};

const handleOk = async () => {
  try {
    await formRef.value.validate();
    modalLoading.value = true;

    if (isEditing.value) {
      await lopApi.update(editingId.value, formState.value);
      message.success('Cập nhật lớp thành công!');
    } else {
      await lopApi.create(formState.value);
      message.success('Thêm lớp mới thành công!');
    }
    isModalVisible.value = false;
    fetchGroups();
  } catch (errorInfo) {
    if (errorInfo.response) {
      message.error('Thao tác thất bại. Vui lòng thử lại.');
    } else {
      message.warning('Vui lòng điền đầy đủ các thông tin bắt buộc.');
    }
  } finally {
    modalLoading.value = false;
  }
};
</script>

<style scoped>
.h-full {
  height: 100%;
}

.flex-col {
  flex-direction: column;
}

.flex-grow {
  flex-grow: 1;
}
</style>