<template>
  <a-card title="Tất cả người dùng" style="width: 100%">
    <template #extra>
      <a-button type="primary" @click="showCreateModal" size="large" v-if="userStore.canCreate('NguoiDung')">
        <template #icon>
          <Plus />
        </template>
        Thêm người dùng
      </a-button>
    </template>
    <div class="row mb-4">
      <div class="col-12">
        <a-input v-model:value="searchQuery" placeholder="Tìm kiếm người dùng..." @search="onSearch" enter-button
          allow-clear block>
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </div>

    </div>


    <a-table :columns="columns" :data-source="users" :pagination="pagination" :loading="loading"
      @change="handleTableChange" rowKey="mssv">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'TrangThai'">
          <a-tag :color="record.trangthai ? 'green' : 'red'">
            {{ record.trangthai ? 'Hoạt động' : 'Khóa' }}
          </a-tag>
        </template>
        <template v-if="column.key === 'action'">
          <a-tooltip title="Sửa người dùng">
            <a-button type="text" @click="showEditModal(record)" :icon="h(SquarePen)"
              v-if="userStore.canUpdate('NguoiDung')" />
          </a-tooltip>

          <a-tooltip title="Xoá người dùng">
            <a-button type="text" danger @click="handleDelete(record)" :icon="h(Trash2)"
              v-if="userStore.canDelete('NguoiDung')" />
          </a-tooltip>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="createModalVisible" title="Thêm người dùng mới" @ok="handleCreate" @cancel="resetCreateForm">
      <a-form ref="createFormRef" layout="vertical" :model="newUser" :rules="userFormRules">
        <a-form-item label="MSSV" name="mssv" id="create_mssv" has-feedback>
          <a-input v-model:value="newUser.mssv" placeholder="Nhập mã số sinh viên" />
        </a-form-item>
        <a-form-item label="Tên đăng nhập" name="userName" id="create_userName" has-feedback>
          <a-input v-model:value="newUser.userName" placeholder="Nhập tên đăng nhập" />
        </a-form-item>
        <a-form-item label="Email" name="email" id="create_email" has-feedback>
          <a-input v-model:value="newUser.email" placeholder="Nhập email" />
        </a-form-item>
        <a-form-item label="Họ tên" name="hoten" id="create_hoten" has-feedback>
          <a-input v-model:value="newUser.hoten" placeholder="Nhập họ tên" />
        </a-form-item>
        <a-form-item label="Giới tính" name="gioitinh" id="create_gioitinh" has-feedback>
          <a-select v-model:value="newUser.gioitinh" placeholder="Chọn giới tính">
            <a-select-option value="true">Nam</a-select-option>
            <a-select-option value="false">Nữ</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="Mật khẩu" name="password" id="create_password" has-feedback>
          <a-input-password v-model:value="newUser.password" placeholder="Nhập mật khẩu" />
        </a-form-item>
        <a-form-item label="Ngày sinh" name="ngaysinh" id="create_ngaysinh" has-feedback>
          <a-date-picker v-model:value="newUser.ngaysinh" style="width: 100%" />
        </a-form-item>
        <a-form-item label="Số điện thoại" name="phoneNumber" id="create_phoneNumber" has-feedback>
          <a-input v-model:value="newUser.phoneNumber" placeholder="Nhập số điện thoại" />
        </a-form-item>
        <a-form-item label="Quyền" name="role" id="create_role" has-feedback>
          <a-select v-model:value="newUser.role" placeholder="Chọn quyền">
            <a-select-option v-for="role in roles" :key="role" :value="role">
              {{ role }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="editModalVisible" :title="'Sửa thông tin: ' + currentUser.email" @ok="handleEditOk"
      @cancel="resetEditForm">
      <a-form ref="editFormRef" layout="vertical" :model="currentUser" :rules="userFormRulesEdit">
        <a-form-item label="Tên đăng nhập" name="userName" has-feedback>
          <a-input v-model:value="currentUser.userName" />
        </a-form-item>
        <a-form-item label="Email" name="email">
          <a-input v-model:value="currentUser.email" disabled />
        </a-form-item>
        <a-form-item label="Họ tên" name="hoten" has-feedback>
          <a-input v-model:value="currentUser.hoten" />
        </a-form-item>
        <a-form-item label="Giới tính" name="gioitinh" has-feedback>
          <a-select v-model:value="currentUser.gioitinh" placeholder="Chọn giới tính">
            <a-select-option value="true">Nam</a-select-option>
            <a-select-option value="false">Nữ</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="Ngày sinh" name="ngaysinh" has-feedback>
          <a-date-picker v-model:value="currentUser.ngaysinh" style="width: 100%" />
        </a-form-item>
        <a-form-item label="Số điện thoại" name="phoneNumber" has-feedback>
          <a-input v-model:value="currentUser.phoneNumber" />
        </a-form-item>
        <a-form-item label="Quyền" has-feedback>
          <a-select v-model:value="currentUser.role" placeholder="Chọn quyền">
            <a-select-option v-for="role in roles" :key="role" :value="role">
              {{ role }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup lang="js">
import { ref, reactive, h, onMounted } from 'vue';
import { message, Modal } from 'ant-design-vue';
import dayjs from 'dayjs';
import {
  Plus,
  SquarePen,
  Trash2,
  Search
} from 'lucide-vue-next';
import apiClient from '@/services/axiosServer';
import { useUserStore } from '@/stores/userStore';


const userStore = useUserStore()
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
    title: 'Họ tên',
    dataIndex: 'hoten',
    key: 'HoTen',
  },
  {
    title: 'Giới tính',
    dataIndex: 'gioitinh',
    key: 'GioiTinh',
    customRender: ({ text }) => {
      if (text === true || text === 'true' || text === 1) {
        return 'Nam';
      } else if (text === false || text === 'false' || text === 0) {
        return 'Nữ';
      }
      return '';
    }
  },
  {
    title: 'Email',
    dataIndex: 'email',
    key: 'Email',
  },
  {
    title: 'Ngày sinh',
    dataIndex: 'ngaysinh',
    key: 'NgaySinh',
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
    dataIndex: 'trangthai',
    key: 'TrangThai',
    customRender: ({ text }) => {
      return text ? 'Hoạt động' : 'Khóa';
    }
  },
  {
    title: 'Hành động',
    key: 'action',
  },
];
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
  hoten: '',
  gioitinh: false,
  ngaysinh: undefined,
  phoneNumber: '',
  trangthai: true,
  role: '',
});
const newUser = reactive({
  mssv: '',
  userName: '',
  email: '',
  hoten: '',
  gioitinh: '',
  password: '',
  ngaysinh: undefined,
  phoneNumber: '',
  role: '',
  trangthai: true
});

const userFormRules = {
  mssv: [
    { required: true, message: 'MSSV không được để trống', trigger: 'blur' }
    , {
      min: 6,
      message: 'MSSV phải có ít nhất 6 ký tự',
      trigger: 'blur'
    },
    {
      max: 10,
      message: 'MSSV không được vượt quá 10 ký tự',
      trigger: 'blur'
    }
  ],
  userName: [{ required: true, message: 'Tên đăng nhập không được để trống', trigger: 'blur' }, , {
    min: 5,
    message: 'Tên người dùng phải có ít nhất 5 ký tự',
    trigger: 'blur'
  },
  {
    max: 30,
    message: 'Tên người dùng không được vượt quá 30 ký tự',
    trigger: 'blur'
  }],
  email: [
    { required: true, message: 'Email không được để trống', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|caothang\.edu\.vn)$/, message: 'Email không đúng định dạng', trigger: ['blur', 'change'] }
  ],
  hoten: [{ required: true, message: 'Họ tên không được để trống', trigger: 'blur' },
  {
    max: 40,
    message: 'Họ  không được vượt quá 40 ký tự',
    trigger: 'blur'
  }
  ],
  password: [{ required: true, message: 'Mật khẩu không được để trống', trigger: 'blur' }, {
    min: 8,
    message: 'Mật khẩu phải có ít nhất 8 ký tự',
    trigger: 'change'
  }],
  ngaysinh: [{ required: true, message: 'Ngày sinh không được để trống', trigger: 'change', type: 'object' }],
  gioitinh: [{ required: true, message: 'Giới tính không được để trống', trigger: 'change' }],
  phoneNumber: [{ required: true, message: 'Số điện thoại không được để trống', trigger: 'blur' }, {
    pattern: /^\d{10}$/,
    message: 'Số điện thoại phải là 10 chữ số',
    trigger: 'blur'
  }],
  role: [{ required: true, message: 'Quyền không được để trống', trigger: 'change' }],
};

const userFormRulesEdit = {
  userName: [{ required: true, message: 'Tên đăng nhập không được để trống', trigger: 'blur' }],
  hoten: [{ required: true, message: 'Họ tên không được để trống', trigger: 'blur' }],
  gioitinh: [{ required: true, message: 'Giới tính không được để trống', trigger: 'change' }],
  ngaysinh: [{ required: true, message: 'Ngày sinh không được để trống', trigger: 'change', type: 'object' }],
  phoneNumber: [{ required: true, message: 'Số điện thoại không được để trống', trigger: 'blur' }, {
    pattern: /^\d{10}$/,
    message: 'Số điện thoại phải là 10 chữ số',
    trigger: 'blur'
  }],
  role: [{ required: true, message: 'Quyền không được để trống', trigger: 'change' }],
};
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  pageSizeOptions: ['10', '20', '50'],
});
const onSearch = () => {
  pagination.current = 1;
  getUsers();
};


const handleTableChange = (newPagination) => {
  pagination.current = newPagination.current;
  pagination.pageSize = newPagination.pageSize;
  getUsers();
};
const getUsers = async () => {
  loading.value = true;

  try {
    if (!userStore.canView('NguoiDung')) {
      users.value = []
      pagination.total = 0
      return
    }
    const params = {
      page: pagination.current,
      pageSize: pagination.pageSize,
    };
    if (searchQuery.value) {
      params.searchQuery = searchQuery.value;
    }

    const response = await apiClient.get('/nguoidung', {
      params
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
    const response = await apiClient.get('/nguoidung/roles');
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
  const isMale = user.gioitinh === true || user.gioitinh === 'true' || user.gioitinh === 1;

  Object.assign(currentUser, {
    mssv: user.mssv,
    userName: user.userName,
    email: user.email,
    hoten: user.hoten,
    gioitinh: String(isMale),
    ngaysinh: user.ngaysinh ? dayjs(user.ngaysinh) : undefined,
    phoneNumber: user.phoneNumber,
    trangthai: user.trangthai,
    role: user.currentRole || ''
  });
  editModalVisible.value = true;
};

const handleCreate = async () => {
  try {
    await createFormRef.value.validate();
    loading.value = true;

    try {
      await apiClient.get(`/nguoidung/check-mssv/${newUser.mssv}`)
      message.error(`MSSV ${newUser.mssv} đã tồn tại`)
      loading.value = false
      return
    }
    catch (error) {
      if (error.response && error.response.status !== 404) {
        message.error("Lỗi khi kiểm tra MSSV. Vui lòng thử lại.")
        loading.value = false
        return
      }
    }

    try {
      await apiClient.get(`/nguoidung/check-email/${newUser.email}`)
      message.error(`Email ${newUser.email} đã tồn tại`)
      loading.value = false
      return
    }
    catch (error) {
      if (error.response && error.response.status !== 404) {
        message.error("Lỗi khi kiểm tra Email. Vui lòng thử lại.")
        loading.value = false
        return
      }
    }
    await apiClient.post('/nguoidung', {
      MSSV: newUser.mssv,
      UserName: newUser.userName,
      Password: newUser.password,
      Email: newUser.email,
      Hoten: newUser.hoten,
      Gioitinh: newUser.gioitinh === 'true',
      Ngaysinh: newUser.ngaysinh ? newUser.ngaysinh.toISOString() : undefined,
      PhoneNumber: newUser.phoneNumber,
      Role: newUser.role,
      TrangThai: true
    })
    message.success('Thêm người dùng thành công')
    createModalVisible.value = false
    getUsers()
  } catch (error) {
    if (error.errorFields) {
      message.warning('Vui lòng điền đầy đủ và đúng định dạng các trường.')
    } else {
      message.error('Thêm người dùng thất bại')
      console.log(error)
    }
  } finally {
    loading.value = false;
  }
};

const handleEditOk = async () => {
  try {
    await editFormRef.value.validate()
    loading.value = true
    await apiClient.put(`/nguoidung/${currentUser.mssv}`, {
      UserName: currentUser.userName,
      Email: currentUser.email,
      FullName: currentUser.hoten,
      Gioitinh: currentUser.gioitinh === 'true',
      Dob: currentUser.ngaysinh ? currentUser.ngaysinh.toISOString() : undefined,
      PhoneNumber: currentUser.phoneNumber,
      Role: currentUser.role
    });
    message.success('Cập nhật thông tin thành công')
    editModalVisible.value = false
    getUsers();
  } catch (error) {
    message.error('Lỗi khi cập nhật thông tin: ' + (error.response?.data || error.message))
    console.error(error);
  }
  finally {
    loading.value = false
  }
};

const handleDelete = (user) => {
  if (user.currentRole && user.currentRole.toLowerCase() === 'admin') {
    message.error('Không thể xóa tài khoản Quản trị viên. Vui lòng liên hệ người có thẩm quyền cao hơn.')
    return
  }
  Modal.confirm({
    title: 'Xác nhận khóa người dùng',
    content: `Bạn có chắc chắn muốn khóa người dùng ${user.email}?`,
    okText: 'Có',
    okType: 'danger',
    cancelText: 'Không',
    onOk: async () => {
      try {
        await apiClient.put(`/nguoidung/${user.mssv}/toggle-status`, null, {
          params: { status: false }
        });
        message.success('Đã khóa người dùng thành công');
        getUsers();
      } catch (error) {
        message.error(`Lỗi khi khóa người dùng: ${error.message}`)
      }
    },
  });
};


const resetCreateForm = () => {
  Object.assign(newUser, {
    mssv: '',
    userName: '',
    email: '',
    hoten: '',
    gioitinh: '',
    password: '',
    ngaysinh: undefined,
    phoneNumber: ''
  });
  if (createFormRef.value) {
    createFormRef.value.resetFields();
  }
};

const resetEditForm = () => {
  Object.assign(currentUser, {
    id: '',
    userName: '',
    email: '',
    hoten: '',
    gioitinh: 'false',
    ngaysinh: undefined,
    phoneNumber: '',
    trangthai: true,
  });
  if (editFormRef.value) {
    editFormRef.value.resetFields();
  }
};

onMounted(async () => {
  await userStore.fetchUserPermissions();
  getUsers();
});
</script>

<style scoped>
.container-fluid {
  padding: 20px;
}
</style>
