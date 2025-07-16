<template>
  <a-card title="Tất cả người dùng" style="width: 100%">
    <template #extra>
      <div class="d-flex gap-3">
        <a-button type="primary" @click="showCreateModal" size="large" v-if="userStore.canCreate('NguoiDung')">
          <template #icon>
            <Plus />
          </template>
          Thêm người dùng
        </a-button>
        <a-button type="primary" @click="openImportExcelModal" size="large">
          <template #icon>
            <span class="anticon">
              <Upload class="mb-1" size="17" />
            </span>
          </template>
          Thêm sinh viên từ Excel
        </a-button>
      </div>
    </template>
    <div class="row mb-4">
      <div class="col-6">
        <a-input v-model:value="searchQuery" placeholder="Tìm kiếm người dùng..." @search="onSearch" enter-button
          allow-clear block>
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </div>
      <div class="col-6 d-flex justify-content-end gap-3">
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

    <a-modal v-model:open="createModalVisible" title="Thêm người dùng mới" :confirm-loading="createLoading" @ok="handleCreate"
      @cancel="resetCreateForm">
      <a-form ref="createFormRef" layout="vertical" :model="newUser" :rules="userFormRules">
        <a-form-item label="MSSV" name="mssv" id="create_mssv" has-feedback>
          <a-input v-model:value="newUser.mssv" placeholder="Nhập mã số sinh viên" />
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

    <a-modal v-model:open="editModalVisible" :title="'Sửa thông tin: ' + currentUser.email" :confirm-loading="editLoading"
      @ok="handleEditOk" @cancel="resetEditForm">
      <a-form ref="editFormRef" layout="vertical" :model="currentUser" :rules="userFormRulesEdit">
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
        <a-form-item label="Trạng thái">
          <a-switch v-model:checked="currentUser.trangthai" />
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

  <a-modal width="700px" v-model:open="importExcelModalVisible" title="Nhập người dùng bằng file Excel" :footer="null"
    @cancel="handleCancelImportExcel">
    <div>
      <p>Vui lòng chuẩn bị file theo đúng <a-button type="link" href="/templates/import_sinhvien.xlsx" download
          style="padding-left: 4px">định dạng mẫu (.xlsx)</a-button>.</p>
      <a-upload-dragger v-model:fileList="fileList" name="file" :multiple="false" accept=".xlsx" :before-upload="() => false"
        @change="handleExcelFileChange">
        <p class="ant-upload-drag-icon">
          <Upload />
        </p>
        <p class="ant-upload-text">Kéo thả hoặc nhấp để chọn file Excel (.xlsx)</p>
        <p class="ant-upload-hint">
          Chỉ hỗ trợ tải lên một file. Đảm bảo file có định dạng đúng.
        </p>
      </a-upload-dragger>
      <div class="d-flex justify-content-end mt-3 gap-2">
        <a-button @click="handleCancelImportExcel">Hủy</a-button>
        <a-button type="primary" :disabled="fileList.length === 0" :loading="importExcelLoading" @click="handleImportExcel">
          Thêm
        </a-button>
      </div>
    </div>
  </a-modal>
</template>

<script setup lang="js">
import { ref, reactive, h, onMounted } from 'vue';
import { message, Modal } from 'ant-design-vue';
import dayjs from 'dayjs';
import {
  Plus,
  SquarePen,
  Trash2,
  Search,
  Upload
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
    fixed: "right"
  },
];
const createFormRef = ref(null);
const editFormRef = ref(null);
const users = ref([]);
const loading = ref(false);
const searchQuery = ref('');
const createModalVisible = ref(false);
const createLoading = ref(false);
const editModalVisible = ref(false);
const editLoading = ref(false);
const currentUser = reactive({
  mssv: '',
  email: '',
  hoten: '',
  gioitinh: '',
  ngaysinh: undefined,
  phoneNumber: '',
  trangthai: true,
  role: '',
});
const newUser = reactive({
  mssv: '',
  email: '',
  hoten: '',
  gioitinh: '',
  password: '',
  ngaysinh: undefined,
  phoneNumber: '',
  role: '',
  trangthai: true
});

const fileList = ref([]);
const importExcelModalVisible = ref(false);
const importExcelLoading = ref(false);

const handleExcelFileChange = (info) => {
  if (info.fileList.length > 1) {
    message.warn('Chỉ chấp nhận tải lên một file Excel. Vui lòng xóa file hiện tại nếu muốn tải file khác.');
    fileList.value = [info.fileList[0]];
  } else if (info.fileList.length === 1) {
    fileList.value = [info.fileList[0]];
    message.success(`${info.file.name} đã thêm thành công`);
  } else {
    fileList.value = [];
  }
};

const openImportExcelModal = () => {
  fileList.value = [];
  importExcelModalVisible.value = true;
};

const handleImportExcel = async () => {
  if (fileList.value.length === 0) {
    message.error('Vui lòng chọn một file Excel để tải lên.');
    return;
  }

  importExcelLoading.value = true;
  try {
    const formData = new FormData();
    formData.append('file', fileList.value[0].originFileObj);

    const response = await apiClient.post(`/Lop/import-students`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });

    if (response.data.errors && response.data.errors.length > 0) {
      let errorMessage = 'Có lỗi xảy ra khi nhập liệu:';
      response.data.errors.forEach(err => {
        errorMessage += `\n- ${err}`;
      });
      message.error(errorMessage, 5);
    } else {
      message.success('Nhập danh sách sinh viên từ Excel thành công!');
      importExcelModalVisible.value = false;
      fileList.value = [];
      getUsers();
    }
  } catch (error) {
    const errorMessage = error.response?.data?.message || error.response?.data || 'Lỗi khi nhập file Excel!';
    message.error(errorMessage);
  } finally {
    importExcelLoading.value = false;
  }
};

const handleCancelImportExcel = () => {
  importExcelModalVisible.value = false;
  fileList.value = [];
};

const agevalidate = async (rule, value) => {
  if (!value) {
    return Promise.resolve();
  }
  const eighteen = dayjs().subtract(18, 'year');

  if (dayjs(value).isAfter(eighteen)) {
    return Promise.reject('Người dùng phải đủ 18 tuổi.');
  }

  return Promise.resolve();
};

const userFormRules = {
  mssv: [
    { required: true, message: 'MSSV không được để trống', trigger: 'blur' },
    {
      min: 6,
      message: 'MSSV phải có ít nhất 6 ký tự',
      trigger: 'blur'
    },
    {
      max: 10,
      message: 'MSSV không được vượt quá 10 ký tự',
      trigger: 'blur'
    },
    {
      pattern: /^\d+$/,
      message: 'MSSV chỉ có thể chứa chữ số',
      trigger: 'blur'
    },
    {
      validator: async (_rule, value) => {
        if (!value) return Promise.resolve();
        try {
          await apiClient.get(`/NguoiDung/check-mssv/${value}`);
          return Promise.reject('MSSV này đã tồn tại');
        } catch (error) {
          if (error.response?.status === 404) {
            return Promise.resolve();
          }
          return Promise.reject('Lỗi khi kiểm tra MSSV');
        }
      },
      trigger: 'blur'
    }
  ],
  email: [
    { required: true, message: 'Email không được để trống', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9._%+-]+@caothang\.edu\.vn$/, message: 'Email không đúng định dạng', trigger: ['blur', 'change'] },
    {
      validator: async (_rule, value) => {
        if (!value) return Promise.resolve();
        try {
          await apiClient.get(`/NguoiDung/check-email/${value}`);
          return Promise.reject('Email này đã tồn tại');
        } catch (error) {
          if (error.response?.status === 404) {
            return Promise.resolve();
          }
          return Promise.reject('Lỗi khi kiểm tra email');
        }
      },
      trigger: 'blur'
    }
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
  ngaysinh: [{ required: true, message: 'Ngày sinh không được để trống', trigger: 'change', type: 'object' },
  { validator: agevalidate, trigger: 'change' }
  ],
  gioitinh: [{ required: true, message: 'Giới tính không được để trống', trigger: 'change', type: 'string' }],
  phoneNumber: [
    { required: true, message: 'Số điện thoại không được để trống', trigger: 'blur' },
    {
      pattern: /^(03|05|07|08|09|01[2|6|8|9])([0-9]{8})$/,
      message: 'Số điện thoại không đúng định dạng Việt Nam (VD: 0912345678)',
      trigger: 'blur'
    },
    {
      validator: async (_rule, value) => {
        if (!value) return Promise.resolve();
        try {
          await apiClient.get(`/NguoiDung/check-phone/${value}`);
          return Promise.reject('Số điện thoại này đã tồn tại');
        } catch (error) {
          if (error.response?.status === 404) {
            return Promise.resolve();
          }
          return Promise.reject('Lỗi khi kiểm tra số điện thoại');
        }
      },
      trigger: 'blur'
    }
  ],
  role: [{ required: true, message: 'Quyền không được để trống', trigger: 'change' }],
};

const userFormRulesEdit = {
  hoten: [{ required: true, message: 'Họ tên không được để trống', trigger: 'blur' }],
  gioitinh: [{ required: true, message: 'Giới tính không được để trống', trigger: 'change', type: 'string' }],
  ngaysinh: [{ required: true, message: 'Ngày sinh không được để trống', trigger: 'change', type: 'object'},
    { validator: agevalidate, trigger: 'change' }],
  phoneNumber: [
    { required: true, message: 'Số điện thoại không được để trống', trigger: 'blur' },
    {
      pattern: /^(03|05|07|08|09|01[2|6|8|9])([0-9]{8})$/,
      message: 'Số điện thoại không đúng định dạng Việt Nam (VD: 0912345678)',
      trigger: 'blur'
    },
    {
      validator: async (_rule, value) => {
        if (!value) return Promise.resolve();
        try {
          await apiClient.get(`/NguoiDung/check-phone/${value}/exclude/${currentUser.mssv}`);
          return Promise.reject('Số điện thoại này đã tồn tại');
        } catch (error) {
          if (error.response?.status === 404) {
            return Promise.resolve();
          }
          return Promise.reject('Lỗi khi kiểm tra số điện thoại');
        }
      },
      trigger: 'blur'
    }
  ],
  role: [{ required: true, message: 'Quyền không được để trống', trigger: 'change' }],
};
const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0,
  showSizeChanger: true,
  showQuickJumper: true,
  pageSizeOptions: ['10', '20', '50'],
});
const onSearch = () => {
  pagination.current = 1;
  getUsers();
};


const handleTableChange = (newPagination) => {
  if (pagination.pageSize !== newPagination.pageSize) {
    pagination.current = 1;
    pagination.pageSize = newPagination.pageSize;
  } else {
    pagination.current = newPagination.current;
  }
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
    createLoading.value = true;

    await apiClient.post('/nguoidung', {
      MSSV: newUser.mssv,
      Password: newUser.password,
      Email: newUser.email,
      Hoten: newUser.hoten,
      Gioitinh: newUser.gioitinh == 'true',
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
    } else if (error.response && error.response.data) {
      let errorMessage = 'Thêm người dùng thất bại: ';
      if (error.response.data.errors) {
        errorMessage += JSON.stringify(error.response.data.errors);
      } else if (error.response.data.message) {
        errorMessage += error.response.data.message;
      } else {
        errorMessage += JSON.stringify(error.response.data);
      }
      message.error(errorMessage);
    } else {
      message.error('Thêm người dùng thất bại: ' + error.message);
    }
  } finally {
    createLoading.value = false;
  }
};

const handleEditOk = async () => {
  try {
    await editFormRef.value.validate()
    editLoading.value = true
    await apiClient.put(`/nguoidung/${currentUser.mssv}`, {
      Email: currentUser.email,
      FullName: currentUser.hoten,
      Gioitinh: currentUser.gioitinh == 'true',
      Dob: currentUser.ngaysinh ? currentUser.ngaysinh.toISOString() : undefined,
      PhoneNumber: currentUser.phoneNumber,
      Status: currentUser.trangthai,
      Role: currentUser.role
    });
    message.success('Cập nhật thông tin thành công')
    editModalVisible.value = false
    getUsers();
  } catch (error) {
    message.error('Lỗi khi cập nhật thông tin:')
  }
  finally {
    editLoading.value = false
  }
};

const handleDelete = (user) => {
  if (user.currentRole && user.currentRole.toLowerCase() === 'admin') {
    message.error('Không thể xóa tài khoản Quản trị viên. Vui lòng liên hệ người có thẩm quyền cao hơn.')
    return
  }
  Modal.confirm({
    title: 'Xác nhận xóa người dùng',
    content: `Bạn có chắc chắn muốn  người dùng ${user.email}?`,
    okText: 'Có',
    okType: 'danger',
    cancelText: 'Không',
    onOk: async () => {
      try {
        await apiClient.put(`/nguoidung/${user.mssv}/soft-delete`, null, {
          params: { hienthi: false }
        });
        message.success('Xóa người dùng thành công');
        getUsers();
      } catch (error) {
        message.error(`Lỗi khi xóa người dùng: ${error.message}`)
      }
    },
  });
};


const resetCreateForm = () => {
  Object.assign(newUser, {
    mssv: '',
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
    email: '',
    hoten: '',
    gioitinh: null,
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
 
