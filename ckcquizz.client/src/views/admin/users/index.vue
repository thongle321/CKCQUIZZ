<template>
  <div class="container-fluid">
    <div class="row mb-4">
      <div class="col">
        <h1 class="h2">Quản lý người dùng</h1>
      </div>
      <div class="col-auto">
        <a-button type="primary" @click="showCreateModal">
          <template #icon>
            <Plus />
          </template>
          Thêm người dùng
        </a-button>
      </div>
    </div>

    <div class="row mb-3">
      <div class="col-md-4">
        <a-input-search v-model:value="searchQuery" placeholder="Tìm kiếm người dùng..." @search="onSearch"
          enter-button />
      </div>
    </div>

    <a-table :columns="columns" :data-source="users" :pagination="pagination" :loading="loading"
      @change="handleTableChange">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'Status'">
          <a-tag :color="record.status ? 'green' : 'red'">
            {{ record.status ? 'Hoạt động' : 'Khóa' }}
          </a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-space>
            <a-button size="small" @click="showEditModal(record)">
              <template #icon>
                <Pen />
              </template>
            </a-button>
            <a-button size="small" @click="confirmDelete(record)">
              <template #icon>
                <Trash2 />
              </template>
            </a-button>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="createModalVisible" title="Thêm người dùng mới" @ok="handleCreate" @cancel="resetCreateForm"
      :ok-button-props="{ disabled: !createFormValid }">
      <a-form ref="createFormRef" layout="vertical">
        <a-form-item label="MSSV" name="mssv" required>
          <a-input v-model:value="newUser.mssv" placeholder="Nhập mã số sinh viên" />
        </a-form-item>
        <a-form-item label="Tên đăng nhập" name="userName" required>
          <a-input v-model:value="newUser.userName" placeholder="Nhập tên đăng nhập" />
        </a-form-item>
        <a-form-item label="Email" name="email" required>
          <a-input v-model:value="newUser.email" placeholder="Nhập email" />
        </a-form-item>
        <a-form-item label="Họ tên" name="fullName" required>
          <a-input v-model:value="newUser.fullName" placeholder="Nhập họ tên" />
        </a-form-item>
        <a-form-item label="Mật khẩu" name="password" required>
          <a-input-password v-model:value="newUser.password" placeholder="Nhập mật khẩu" />
        </a-form-item>
        <a-form-item label="Ngày sinh" name="dob" required>
          <a-date-picker v-model:value="newUser.dob" style="width: 100%" />
        </a-form-item>
        <a-form-item label="Số điện thoại" name="phoneNumber" required>
          <a-input v-model:value="newUser.phoneNumber" placeholder="Nhập số điện thoại" />
        </a-form-item>
        <a-form-item label="Quyền" name="role" required>
          <a-select v-model:value="newUser.role" placeholder="Chọn quyền">
            <a-select-option v-for="role in roles" :key="role" :value="role">
              {{ role }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="editModalVisible" :title="'Sửa thông tin: ' + currentUser.email" @ok="handleEditOk"
      @cancel="resetEditForm" :ok-button-props="{ disabled: !editFormValid }">
      <a-form ref="editFormRef" layout="vertical">
        <a-form-item label="Tên đăng nhập" name="userName">
          <a-input v-model:value="currentUser.userName" />
        </a-form-item>
        <a-form-item label="Email" name="email">
          <a-input v-model:value="currentUser.email" disabled />
        </a-form-item>
        <a-form-item label="Họ tên" name="fullName">
          <a-input v-model:value="currentUser.fullName" />
        </a-form-item>
        <a-form-item label="Ngày sinh" name="dob">
          <a-date-picker v-model:value="currentUser.dob" style="width: 100%" />
        </a-form-item>
        <a-form-item label="Số điện thoại" name="phoneNumber">
          <a-input v-model:value="currentUser.phoneNumber" />
        </a-form-item>
        <a-form-item label="Trạng thái">
          <a-switch v-model:checked="currentUser.status" />
        </a-form-item>
        <a-form-item label="Quyền" required>
          <a-select v-model:value="currentUser.role" placeholder="Chọn quyền">
            <a-select-option v-for="role in roles" :key="role" :value="role">
              {{ role }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { message, Modal } from 'ant-design-vue';
import dayjs from 'dayjs';
import {
  Plus,
  Pen,
  Trash2
} from 'lucide-vue-next';
import apiClient from '@/services/axiosServer';

const roles = ref([]);

const columns = [
  {
    title: 'MSSV',
    dataIndex: 'mssv',
    key: 'MSSV',
  },
  {
    title: 'Tên đăng nhập',
    dataIndex: 'userName',
    key: 'UserName',
  },
  {
    title: 'Email',
    dataIndex: 'email',
    key: 'Email',
  },
  {
    title: 'Họ tên',
    dataIndex: 'fullName',
    key: 'FullName',
  },
  {
    title: 'Ngày sinh',
    dataIndex: 'dob',
    key: 'Dob',
    customRender: ({ text }) => text ? dayjs(text).format('DD/MM/YYYY') : ''
  },
  {
    title: 'Điện thoại',
    dataIndex: 'phoneNumber',
    key: 'PhoneNumber',
  },
  {
    title: "Quyền ",
    dataIndex: "currentRole",
    key: 'CurrentRole',
  },
  {
    title: 'Trạng thái',
    dataIndex: "status",
    key: 'Status',
  },
  {
    title: 'Hành động',
    key: 'action',
    width: '120px',
  },
];
const userFormRules = {
  mssv: [{ required: true, message: 'MSSV không được để trống', trigger: 'blur' }],
  userName: [{ required: true, message: 'Tên đăng nhập không được để trống', trigger: 'blur' }],
  email: [
    { required: true, message: 'Email không được để trống', trigger: 'blur' },
    { type: 'email', message: 'Email không đúng định dạng', trigger: ['blur', 'change'] }
  ],
  fullName: [{ required: true, message: 'Họ tên không được để trống', trigger: 'blur' }],
  password: [{ required: true, message: 'Mật khẩu không được để trống', trigger: 'blur' }],
  dob: [{ required: true, message: 'Ngày sinh không được để trống', trigger: 'change', type: 'object' }],
  phoneNumber: [{ required: true, message: 'Số điện thoại không được để trống', trigger: 'blur' }],
  role: [{ required: true, message: 'Quyền không được để trống', trigger: 'change' }],
};

const userFormRulesEdit = {
  userName: [{ required: true, message: 'Tên đăng nhập không được để trống', trigger: 'blur' }],
  fullName: [{ required: true, message: 'Họ tên không được để trống', trigger: 'blur' }],
  dob: [{ required: true, message: 'Ngày sinh không được để trống', trigger: 'change', type: 'object' }],

  role: [{ required: true, message: 'Quyền không được để trống', trigger: 'change' }],
};
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50'],
});
const createFormRef = ref(null);
const editFormRef = ref(null);
const users = ref([]);
const loading = ref(false);
const searchQuery = ref('');
const createModalVisible = ref(false);
const editModalVisible = ref(false);
const currentUser = reactive({
  mssv: '',
  userName: '',
  email: '',
  fullName: '',
  dob: undefined,
  phoneNumber: '',
  status: true,
  role: '',
});
const newUser = reactive({
  mssv: '',
  userName: '',
  email: '',
  fullName: '',
  password: '',
  dob: undefined,
  phoneNumber: '',
  role: ''
});

const createFormValid = computed(() => {
  return newUser.mssv &&
    newUser.userName &&
    newUser.email &&
    newUser.fullName &&
    newUser.password &&
    newUser.dob &&
    newUser.phoneNumber &&
    newUser.role;
});

const editFormValid = computed(() => {
  return currentUser.userName &&
    currentUser.email &&
    currentUser.fullName &&
    currentUser.phoneNumber &&
    currentUser.role;
});

const handleTableChange = (newPagination) => {
  pagination.current = newPagination.current;
  pagination.pageSize = newPagination.pageSize;
  getUsers();
};
const getUsers = async () => {
  try {
    loading.value = true;
    const response = await apiClient.get('/api/user', {
      params: {
        page: pagination.current,
        pageSize: pagination.pageSize
      }
    });
    users.value = response.data.items;
    pagination.total = response.data.totalCount;
  } catch (error) {
    message.error('Lỗi khi tải dữ liệu người dùng');
    console.error(error);
  } finally {
    loading.value = false;
  }
};
const getRoles = async () => {
  try {
    const response = await apiClient.get('/api/user/roles');
    roles.value = Array.isArray(response.data) ? response.data : [];
  } catch (error) {
    message.error('Không thể tải danh sách quyền');
    console.error(error);
  }
};

const showCreateModal = () => {
  resetCreateForm();
  createModalVisible.value = true;
  getRoles();
};

const showEditModal = (user) => {
  getRoles()
  Object.assign(currentUser, {
    mssv: user.mssv,
    userName: user.userName,
    email: user.email,
    fullName: user.fullName,
    dob: user.dob ? dayjs(user.dob) : undefined,
    phoneNumber: user.phoneNumber,
    status: user.status,
    role: user.currentRole || ''
  });
  editModalVisible.value = true;
};

const handleCreate = async () => {
  try {
    await createFormRef.value.validate()
    loading.value = true;
    await apiClient.post('/api/user', {
      MSSV: newUser.mssv,
      UserName: newUser.userName,
      Password: newUser.password,
      Email: newUser.email,
      FullName: newUser.fullName,
      Dob: newUser.dob ? newUser.dob.toISOString() : undefined,
      PhoneNumber: newUser.phoneNumber,
      Role: newUser.role
    });
    message.success('Thêm người dùng thành công');
    getUsers();
  } catch (error) {
    message.error('Lỗi khi thêm người dùng: ' + (error.response?.data || error.message));
    console.error(error);
  }
};

const handleEditOk = async () => {
  try {
    await apiClient.put(`/api/user/${currentUser.mssv}`, {
      UserName: currentUser.userName,
      Email: currentUser.email,
      FullName: currentUser.fullName,
      Dob: currentUser.dob ? currentUser.dob.toISOString() : undefined,
      PhoneNumber: currentUser.phoneNumber,
      Status: currentUser.status,
      Role: currentUser.role
    });
    message.success('Cập nhật thông tin thành công');
    getUsers();
  } catch (error) {
    message.error('Lỗi khi cập nhật thông tin: ' + (error.response?.data || error.message));
    console.error(error);
  }
};

const confirmDelete = (user) => {
  Modal.confirm({
    title: 'Xác nhận xóa người dùng',
    content: `Bạn có chắc chắn muốn xóa người dùng ${user.email}?`,
    okText: 'Xóa',
    okType: 'danger',
    cancelText: 'Hủy',
    onOk: async () => {
      try {
        await apiClient.delete(`/api/user/${user.mssv}`);
        message.success('Đã xóa người dùng thành công');
        getUsers();
      } catch (error) {
        message.error('Lỗi khi xóa người dùng: ' + (error.response?.data || error.message));
        console.error(error);
      }
    },
  });
};

const resetCreateForm = () => {
  Object.assign(newUser, {
    mssv: '',
    userName: '',
    email: '',
    fullName: '',
    password: '',
    dob: undefined,
    phoneNumber: ''
  });
  createModalVisible.value = false;
};

const resetEditForm = () => {
  Object.assign(currentUser, {
    id: '',
    userName: '',
    email: '',
    fullName: '',
    dob: undefined,
    phoneNumber: '',
    status: true,
  });
  editModalVisible.value = false;
};

onMounted(() => {
  getUsers();
});
</script>

<style scoped>
.container-fluid {
  padding: 20px;
}
</style>