<template>
  <a-card title="Quản lý lớp học phần" style="width: 100%">
    <div class="row">
      <div class="col-6">
        <a-input-group compact>
          <a-select v-model:value="filterStatus" @change="fetchGroups">
            <a-select-option value="true">Đang giảng dạy</a-select-option>
            <a-select-option value="false">Đã ẩn</a-select-option>
          </a-select>
          <a-input v-model:value="searchText" placeholder="Tìm kiếm theo tên lớp..." allow-clear
            style="width: calc(100% - 150px);">
          </a-input>
        </a-input-group>
      </div>
      <div class="col-6 d-flex justify-content-end">
        <a-button v-if="userStore.canCreate('HocPhan')" type="primary" size="large" @click="CreateModal">
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
      <div v-for="(groupList, groupKey) in groupedGroups" :key="groupKey">
        <h5 class="text-lg font-bold my-4">
          {{ groupKey }}
        </h5>
        <a-row>
          <a-col v-for="group in groupList" :key="group.malop" :xs="24" :sm="12" :lg="6">
            <router-link :to="{ name: 'admin-classdetail', params: { id: group.malop } }">
              <a-card hoverable size="small" class="h-full flex flex-col mx-4 mb-4">
                <template #title>
                  <div class="font-bold text-base">{{ group.tenlop }}</div>
                </template>
                <template #extra>
                  <a-dropdown :trigger="['click']">
                    <a class="ant-dropdown-link" @click.prevent>
                      <Settings />
                    </a>
                    <template #overlay>
                      <a-menu>
                        <a-menu-item v-if="userStore.canUpdate('HocPhan')" @click="EditModal(group)">
                          Sửa thông tin
                        </a-menu-item>
                        <a-menu-item v-if="userStore.canUpdate('HocPhan')"
                          @click="handleToggleStatus(group, !group.hienthi)">
                          {{ group.hienthi ? 'Ẩn lớp' : 'Hiện lớp' }}
                        </a-menu-item>
                        <a-menu-item v-if="userStore.canDelete('HocPhan')">
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

        <a-form-item v-if="isAdmin" label="Giáo viên" name="giangvienId">
          <a-select v-model:value="formState.giangvienId" placeholder="Chọn giáo viên cho lớp này"
            :options="teacherOptions" :loading="teacherLoading" allow-clear />
        </a-form-item>

        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="Năm học" name="namhoc" :rules="[{ required: true, message: 'Vui lòng chọn năm học!' }]">
              <a-date-picker v-model:value="formState.namhoc" picker="year" format="YYYY" placeholder="Chọn năm học"
                style="width: 100%;">
              </a-date-picker>
            </a-form-item>
          </a-col>
          <a-col :span="12">
            <a-form-item label="Học kỳ" name="hocky" :rules="[{ required: true, message: 'Vui lòng chọn học kỳ!' }]">
              <a-select v-model:value="formState.hocky" placeholder="Chọn học kỳ">
                <a-select-option :value="1">Học kỳ 1</a-select-option>
                <a-select-option :value="2">Học kỳ 2</a-select-option>
                <a-select-option :value="3">Học kỳ 3</a-select-option>
                <a-select-option :value="4">Học kỳ 4</a-select-option>
                <a-select-option :value="5">Học kỳ 5</a-select-option>
                <a-select-option :value="6">Học kỳ 6</a-select-option>
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
import dayjs from 'dayjs';
import { useAuthStore } from '@/stores/authStore';
import { useUserStore } from '@/stores/userStore';

const userStore = useUserStore();
const groups = ref([]);
const loading = ref(true);
const filterStatus = ref('true');
const searchText = ref('');

const isModalVisible = ref(false);
const modalLoading = ref(false);
const modalDetailLoading = ref(false);
const isEditing = ref(false);
const editingId = ref(null);
const formRef = ref();

const monHocOptions = ref([]);
const monHocLoading = ref(false);

const teacherOptions = ref([]);
const teacherLoading = ref(false);

const authStore = useAuthStore();
const isAdmin = computed(() => authStore.userRoles?.includes('Admin'));
const initialFormState = {
  tenlop: '',
  ghichu: '',
  mamonhoc: null,
  giangvienId: null,
  namhoc: dayjs(),
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
    const tenmonhoc = group.monHocs && group.monHocs.length > 0
      ? group.monHocs[0]
      : 'Chưa có môn học';
    const namhoc = group.namhoc || 'N/A';
    const hocky = group.hocky || 'N/A';
    const groupKey = `${tenmonhoc} - NH ${namhoc} - HK${hocky}`;

    if (!grouped[groupKey]) {
      grouped[groupKey] = [];
    }
    grouped[groupKey].push(group);
  });
  return grouped;
});

const fetchGroups = async () => {
  loading.value = true;
  try {
    if (!userStore.canView('HocPhan')) {
      groups.value = []
      return
    }
    const params = { hienthi: filterStatus.value === 'true' };
    const responseData = await lopApi.getAll(params);
    if (responseData) {
      groups.value = responseData;
    } else {
      message.error('Không thể tải danh sách lớp. Vui lòng thử lại.');
    }
  } catch (error) {
    message.error('Lỗi khi tải danh sách lớp!');
  } finally {
    loading.value = false;
  }
};

const fetchMonHocs = async () => {
  monHocLoading.value = true;
  try {
    let responseData;
    if (isAdmin.value) {
      responseData = await lopApi.getMonHocs();
    } else {
      responseData = await lopApi.getMyAssignment();
    }
    if (responseData) {
      monHocOptions.value = responseData.map(mh => ({
        label: mh.tenmonhoc,
        value: mh.mamonhoc,
      }));
    } else {
      message.error('Không thể tải danh sách môn học. Vui lòng thử lại.');
    }
  } catch (error) {
    message.error('Lỗi khi tải danh sách môn học!');
  } finally {
    monHocLoading.value = false;
  }
};

const fetchTeachers = async () => {
  teacherLoading.value = true;
  try {
    const responseData = await lopApi.getTeachers();
    if (responseData && responseData.items) {
      teacherOptions.value = responseData.items.map(teacher => ({
        label: teacher.hoten,
        value: teacher.mssv,
      }));
    } else {
      message.error('Không thể tải danh sách giáo viên. Vui lòng thử lại.');
    }
  } catch (error) {
    message.error('Lỗi khi tải danh sách giáo viên!');
  } finally {
    teacherLoading.value = false;
  }
};

const handleToggleStatus = async (group, hienthi) => {
  const originalStatus = group.hienthi;
  group.hienthi = hienthi;
  try {
    const responseData = await lopApi.toggleStatus(group.malop, hienthi);
    if (responseData) {
      message.success(`Đã ${hienthi ? 'hiển thị' : 'ẩn'} lớp học.`);
      fetchGroups();
    } else {
      group.hienthi = originalStatus;
      message.error('Cập nhật trạng thái thất bại. Vui lòng thử lại.');
    }
  } catch (error) {
    group.hienthi = originalStatus;
    message.error('Cập nhật trạng thái thất bại!');
  }
};

const handleDelete = async (id) => {
  try {
    const response = await lopApi.delete(id);
    if (response && response.status === 204) {
      message.success('Xóa lớp thành công!');
      fetchGroups();
    } else {
      message.error('Xóa lớp thất bại. Vui lòng thử lại.');
    }
  } catch (error) {
    console.error('Error deleting class:', error);
    const errorMessage = error.response?.data?.message || error.message;
    message.error(`Xóa lớp thất bại: ${errorMessage}`);
  }
};

const CreateModal = () => {
  isEditing.value = false;
  formState.value = { ...initialFormState };
  isModalVisible.value = true;
};

const EditModal = async (group) => {
  isEditing.value = true;
  editingId.value = group.malop;
  isModalVisible.value = true;
  modalDetailLoading.value = true;

  try {
    formState.value = {
      ...group,
      mamonhoc: group.monHocs && group.monHocs.length > 0 ? parseInt(group.monHocs[0].split(' - ')[0]) : null,
      giangvienId: group.giangvien,
      namhoc: group.namhoc ? dayjs(group.namhoc.toString()) : null,
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

    const payload = { ...formState.value };
    if (payload.namhoc && typeof payload.namhoc !== 'number') {
      payload.namhoc = payload.namhoc.year();
    }

    let responseData;
    if (isEditing.value) {
      responseData = await lopApi.update(editingId.value, payload);
    } else {
      responseData = await lopApi.create(payload);
    }

    if (responseData) {
      message.success(isEditing.value ? 'Cập nhật lớp thành công!' : 'Thêm lớp mới thành công!');
      isModalVisible.value = false;
      fetchGroups();
    } else {
      message.error('Thao tác thất bại. Vui lòng thử lại.');
    }
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

onMounted(async () => {
  await userStore.fetchUserPermissions();
  Promise.all([fetchGroups(), fetchMonHocs(), fetchTeachers()]);
});
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