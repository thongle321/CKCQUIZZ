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
        <a-input-search 
          v-model:value="searchQuery"
          placeholder="Tìm kiếm người dùng..."
          @search="fetchUsers"
          enter-button
        />
      </div>
    </div>

    <a-table 
      :columns="columns" 
      :data-source="users" 
      :pagination="pagination"
      :loading="loading"
      @change="handleTableChange"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'trangthai'">
          <a-tag :color="record.trangthai ? 'green' : 'red'">
            {{ record.trangthai ? 'Hoạt động' : 'Khóa' }}
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

    <!-- Create User Modal -->
    <a-modal 
      v-model:open="createModalVisible" 
      title="Thêm người dùng mới" 
      @ok="handleCreateOk"
      @cancel="resetCreateForm"
      :ok-button-props="{ disabled: !createFormValid }"
    >
      <a-form layout="vertical">
        <a-form-item label="MSSV" required>
          <a-input v-model:value="newUser.mssv" placeholder="Nhập mã số sinh viên" />
        </a-form-item>
        <a-form-item label="Tên đăng nhập" required>
          <a-input v-model:value="newUser.userName" placeholder="Nhập tên đăng nhập" />
        </a-form-item>
        <a-form-item label="Email" required>
          <a-input v-model:value="newUser.email" placeholder="Nhập email" />
        </a-form-item>
        <a-form-item label="Họ tên" required>
          <a-input v-model:value="newUser.fullName" placeholder="Nhập họ tên" />
        </a-form-item>
        <a-form-item label="Mật khẩu" required>
          <a-input-password v-model:value="newUser.password" placeholder="Nhập mật khẩu" />
        </a-form-item>
        <a-form-item label="Ngày sinh" required>
          <a-date-picker v-model:value="newUser.dob" style="width: 100%" />
        </a-form-item>
        <a-form-item label="Số điện thoại" required>
          <a-input v-model:value="newUser.phoneNumber" placeholder="Nhập số điện thoại" />
        </a-form-item>
        <a-form-item label="Quyền" required>
          <a-select v-model:value="newUser.role" placeholder="Chọn quyền">
            <a-select-option v-for="role in roles" :key="role" :value="role">
              {{ role }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Edit User Modal -->
    <a-modal 
      v-model:open="editModalVisible" 
      :title="'Sửa thông tin: ' + currentUser.email" 
      @ok="handleEditOk"
      @cancel="resetEditForm"
      :ok-button-props="{ disabled: !editFormValid }"
    >
      <a-form layout="vertical">
        <a-form-item label="Tên đăng nhập">
          <a-input v-model:value="currentUser.userName" />
        </a-form-item>
        <a-form-item label="Email">
          <a-input v-model:value="currentUser.email" disabled />
        </a-form-item>
        <a-form-item label="Họ tên">
          <a-input v-model:value="currentUser.fullName" />
        </a-form-item>
        <a-form-item label="Ngày sinh">
          <a-date-picker v-model:value="currentUser.dob" style="width: 100%" />
        </a-form-item>
        <a-form-item label="Số điện thoại">
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
    title: 'ID',
    dataIndex: 'id',
    key: 'id',
    sorter: true,
  },
  {
    title: 'Tên đăng nhập',
    dataIndex: 'userName',
    key: 'userName',
    sorter: true,
  },
  {
    title: 'Email',
    dataIndex: 'email',
    key: 'email',
    sorter: true,
  },
  {
    title: 'Họ tên',
    dataIndex: 'hoten',
    key: 'hoten',
    sorter: true,
  },
  {
    title: 'Trạng thái',
    key: 'trangthai',
  },
  {
    title: 'Hành động',
    key: 'action',
    width: '120px',
  },
];

const users = ref([]);
const loading = ref(false);
const searchQuery = ref('');
const createModalVisible = ref(false);
const editModalVisible = ref(false);
const currentUser = reactive({
  id: '',
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

// Form validation
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

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50'],
});

const fetchUsers = async () => {
  try {
    loading.value = true;
    const response = await apiClient.get('/api/user', {
      params: {
        page: pagination.current,
        pageSize: pagination.pageSize,
        search: searchQuery.value
      }
    });
    users.value = response.data;
    pagination.total = response.headers['x-total-count'] || 0;
  } catch (error) {
    message.error('Lỗi khi tải dữ liệu người dùng');
    console.error(error);
  } finally {
    loading.value = false;
  }
};

const handleTableChange = (pag, filters, sorter) => {
  pagination.current = pag.current;
  pagination.pageSize = pag.pageSize;
  fetchUsers();
};

const fetchRoles = async () => {
  try {
    const response = await apiClient.get('/api/user/roles');
    roles.value = response.data;
  } catch (error) {
    message.error('Không thể tải danh sách quyền');
    console.error(error);
  }
};

const showCreateModal = () => {
  createModalVisible.value = true;
  fetchRoles();
};

const showEditModal = (user) => {
  Object.assign(currentUser, {
    id: user.id,
    userName: user.userName,
    email: user.email,
    fullName: user.hoten,
    dob: user.ngaysinh ? dayjs(user.ngaysinh) : undefined,
    phoneNumber: user.phoneNumber,
    status: user.trangthai,
  });
  editModalVisible.value = true;
};

const handleCreateOk = async () => {
  try {
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
    fetchUsers();
    resetCreateForm();
  } catch (error) {
    message.error('Lỗi khi thêm người dùng: ' + (error.response?.data || error.message));
    console.error(error);
  }
};

const handleEditOk = async () => {
  try {
    await apiClient.put(`/api/user/${currentUser.id}`, {
      UserName: currentUser.userName,
      Email: currentUser.email,
      FullName: currentUser.fullName,
      Dob: currentUser.dob ? currentUser.dob.toISOString() : undefined,
      PhoneNumber: currentUser.phoneNumber
    });
    message.success('Cập nhật thông tin thành công');
    fetchUsers();
    resetEditForm();
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
        await apiClient.delete(`/api/user/${user.id}`);
        message.success('Đã xóa người dùng thành công');
        fetchUsers();
      } catch (error) {
        message.error('Lỗi khi xóa người dùng: ' + (error.response?.data || error.message));
        console.error(error);
      }
    },
  });
};

// Reset forms
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

// Initialize
onMounted(() => {
  fetchUsers();
});
</script>

<style scoped>
.container-fluid {
  padding: 20px;
}
</style>
