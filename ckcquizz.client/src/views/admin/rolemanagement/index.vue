<template>
  <a-card title="Danh sách nhóm quyền" style="width: 100%">
    <!-- <template #extra>
      <a-button type="primary" @click="openAddModal" size="large" v-if="userStore.canCreate('NhomQuyen')">
        <template #icon>
          <Plus />
        </template>
        Thêm mới
      </a-button>
    </template> -->
    <div class="row mb-4">
      <div class="col-12">
        <a-input v-model:value="searchText" placeholder="Tìm kiếm nhóm quyền..." enter-button allow-clear block>
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </div>

    </div>

    <a-table :dataSource="filteredPermissionGroups" :columns="columns" :loading="tableLoading" rowKey="id">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'actions'">
          <a-tooltip title="Sửa nhóm quyền">
            <a-button type="text" @click="openEditModal(record)" v-if="userStore.canUpdate('NhomQuyen')">
              <SquarePen />
            </a-button>
          </a-tooltip>
          <!-- <a-tooltip title="Xoá nhóm quyền">
            <a-popconfirm title="Bạn có chắc muốn xóa nhóm quyền này?" ok-text="Có" cancel-text="Không"
              @confirm="handleDelete(record.id)">
              <a-button type="text" danger v-if="userStore.canDelete('NhomQuyen')">
                <Trash2 />
              </a-button>
            </a-popconfirm>
          </a-tooltip> -->
        </template>
      </template>
    </a-table>

    <a-modal :title="isEditMode ? 'Chỉnh sửa nhóm quyền' : 'Thêm nhóm quyền mới'" v-model:open="showModal" width="80%"
      @ok="handleOk" @cancel="handleCancel" :confirmLoading="modalLoading" destroyOnClose>
      <a-form ref="formRef" :model="currentGroup" layout="vertical" :rules="rules">
        <a-form-item label="Tên nhóm quyền" name="tenNhomQuyen" required>
          <a-input v-model:value="currentGroup.tenNhomQuyen" placeholder="VD: Giảng viên" />
        </a-form-item>

        <a-table :dataSource="filteredFunctionForPermissionTable" :columns="permissionTableColumns" :pagination="false"
          rowKey="chucNang">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key !== 'tenChucNang'">
              <a-checkbox
                v-if="!(record.chucNang.toLowerCase() === 'nhomquyen' && (column.key === 'create' || column.key === 'delete'))"
                :checked="isPermissionGranted(record.chucNang, column.key)"
                @change="(e) => togglePermission(record.chucNang, column.key, e.target.checked)" />
            </template>
          </template>
        </a-table>

        <a-row :gutter="16" style="margin-top: 24px;">
          <a-col>
            <a-form-item>
              <a-switch v-model:checked="currentGroup.thamGiaThi" />
              <span style="margin-left: 8px;">Tham gia thi</span>
            </a-form-item>
          </a-col>
          <a-col>
            <a-form-item>
              <a-switch v-model:checked="currentGroup.thamGiaHocPhan" />
              <span style="margin-left: 8px;">Tham gia học phần</span>
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup>
import { ref, onMounted, h, reactive, computed, watch } from "vue";
import { SquarePen, Trash2, Plus, Search } from 'lucide-vue-next';
import { message } from 'ant-design-vue';
import apiClient from "@/services/axiosServer";
import { useUserStore } from '@/stores/userStore';

const permissionGroups = ref([]);
const allFunctions = ref([]);
const tableLoading = ref(false);
const modalLoading = ref(false);
const showModal = ref(false);
const isEditMode = ref(false);
const searchText = ref('');
const formRef = ref(null);

const userStore = useUserStore();

const currentGroup = reactive({
  id: null,
  tenNhomQuyen: '',
  thamGiaThi: false,
  thamGiaHocPhan: false,
  permissions: []
});

const columns = [
  { title: "Tên nhóm", dataIndex: "tenNhomQuyen", key: "tenNhomQuyen" },
  { title: "Số người dùng", dataIndex: "soNguoiDung", key: "soNguoiDung", align: 'center' },
  { title: "Hành động", key: "actions", fixed: "right", align: 'center' },
];
const permissionTableColumns = computed(() => [
  { title: 'Chức năng', dataIndex: 'tenChucNang', key: 'tenChucNang', fixed: 'left', width: 180 },
  { title: 'Xem', key: 'view', dataIndex: 'view', align: 'center' },
  { title: 'Thêm', key: 'create', dataIndex: 'create', align: 'center' },
  { title: 'Sửa', key: 'update', dataIndex: 'update', align: 'center' },
  { title: 'Xóa', key: 'delete', dataIndex: 'delete', align: 'center' },
]);
const rules = {
  tenNhomQuyen: [{ required: true, message: "Vui lòng nhập tên nhóm quyền", trigger: "blur" }],
};

const filteredPermissionGroups = computed(() => {
  if (!searchText.value) {
    return permissionGroups.value;
  }
  return permissionGroups.value.filter(group =>
    (group.tenNhomQuyen || '').toLowerCase().includes(searchText.value.toLowerCase())
  );
});

const filteredFunctionForPermissionTable = computed(() =>
  allFunctions.value.filter(
    func => func.chucNang !== "thamgiahocphan" && func.chucNang !== "thamgiathi"
  )
);

const fetchPermissionGroups = async () => {
  tableLoading.value = true;
  try {
    if (!userStore.canView('NhomQuyen')) {
      permissionGroups.value = []
      pagination.total = 0
      return
    }
    const response = await apiClient.get("/permission");
    permissionGroups.value = response.data;
  } catch (error) {
    message.error("Không thể tải danh sách nhóm quyền.");
  } finally {
    tableLoading.value = false;
  }
};
const fetchAllFunctions = async () => {
  try {
    const response = await apiClient.get("/permission/functions");
    allFunctions.value = response.data;
  } catch (error) {
    message.error("Không thể tải danh sách chức năng.");
  }
};

const resetCurrentGroup = () => {
  currentGroup.id = null;
  currentGroup.tenNhomQuyen = '';
  currentGroup.thamGiaThi = false;
  currentGroup.thamGiaHocPhan = false;
  currentGroup.permissions = [];
};

const isPermissionGranted = (chucNang, hanhDong) => {
  const perm = currentGroup.permissions.find(p => p.chucNang === chucNang && p.hanhDong === hanhDong);
  return perm ? perm.isGranted : false;
};
const togglePermission = (chucNang, hanhDong, isChecked) => {
  const perm = currentGroup.permissions.find(p => p.chucNang === chucNang && p.hanhDong === hanhDong);
  if (perm) {
    perm.isGranted = isChecked;
  } else if (isChecked) {
    currentGroup.permissions.push({
      chucNang,
      hanhDong,
      isGranted: true,
    });
  }
  else {
    const idx = currentGroup.permissions.findIndex(
      p => p.chucNang === chucNang && p.hanhDong === hanhDong
    );
    if (idx !== -1) currentGroup.permissions.splice(idx, 1);
  }
};

const setSwitchFromPermissions = () => {
  currentGroup.thamGiaThi = currentGroup.permissions.some(
    p => p.chucNang === "thamgiathi" && p.hanhDong === "join"
  );
  currentGroup.thamGiaHocPhan = currentGroup.permissions.some(
    p => p.chucNang === "thamgiahocphan" && p.hanhDong === "join"
  );
};
watch(() => currentGroup.thamGiaThi, (val) => {
  const idx = currentGroup.permissions.findIndex(
    p => p.chucNang === "thamgiathi" && p.hanhDong === "join"
  );
  if (val && idx === -1) {
    currentGroup.permissions.push({
      chucNang: "thamgiathi",
      hanhDong: "join",
      isGranted: true,
    });
  } else if (!val && idx !== -1) {
    currentGroup.permissions.splice(idx, 1);
  }
});
watch(() => currentGroup.thamGiaHocPhan, (val) => {
  const idx = currentGroup.permissions.findIndex(
    p => p.chucNang === "thamgiahocphan" && p.hanhDong === "join"
  );
  if (val && idx === -1) {
    currentGroup.permissions.push({
      chucNang: "thamgiahocphan",
      hanhDong: "join",
      isGranted: true,
    });
  } else if (!val && idx !== -1) {
    currentGroup.permissions.splice(idx, 1);
  }
});

const openAddModal = () => {
  resetCurrentGroup();
  const actions = ['view', 'create', 'update', 'delete'];
  filteredFunctionForPermissionTable.value.forEach(func => {
    actions.forEach(action => {
      currentGroup.permissions.push({
        chucNang: func.chucNang,
        hanhDong: action,
        isGranted: false,
      });
    });
  });
  isEditMode.value = false;
  showModal.value = true;
};
const openEditModal = async (record) => {
  resetCurrentGroup();
  isEditMode.value = true;
  try {
    const response = await apiClient.get(`/permission/${record.id}`);
    const data = response.data;
    currentGroup.id = data.id;
    currentGroup.tenNhomQuyen = data.tenNhomQuyen;
    currentGroup.permissions = data.permissions.map(p => ({
      chucNang: p.chucNang,
      hanhDong: p.hanhDong,
      isGranted: p.isGranted !== undefined ? p.isGranted : true,
    }));
    setSwitchFromPermissions();
    showModal.value = true;
  } catch (error) {
    message.error("Không thể tải chi tiết quyền.");
  }
};

const handleOk = async () => {
  try {
    await formRef.value.validate();
    modalLoading.value = true;
    const payload = { ...currentGroup };
    payload.permissions = currentGroup.permissions.filter(p => p.isGranted);

    if (isEditMode.value) {
      await apiClient.put(`/permission/${currentGroup.id}`, payload);
      message.success("Cập nhật nhóm quyền thành công!");
    } else {
      await apiClient.post('/permission', payload);
      message.success("Thêm nhóm quyền thành công!");
    }

    showModal.value = false;
    await fetchPermissionGroups();
  } catch (error) {
    const errorMsg = error.response?.data?.errors?.[0]?.description || (isEditMode.value ? "Cập nhật thất bại." : "Thêm mới thất bại.");
    message.error(errorMsg);
  } finally {
    modalLoading.value = false;
  }
};

const handleCancel = () => {
  showModal.value = false;
};

const handleDelete = async (id) => {
  try {
    const canDelete = permissionGroups.value.find(group => group.id === id);
    if (canDelete && canDelete.soNguoiDung > 0) {
      message.error("Không thể xóa nhóm quyền này vì đang có người dùng");
      return;
    }
    await apiClient.delete(`/permission/${id}`);
    message.success("Xóa nhóm quyền thành công!");
    await fetchPermissionGroups();
  } catch (error) {
    message.error("Xóa nhóm quyền thất bại.");
  }
};

onMounted(async () => {
  await userStore.fetchUserPermissions();
  await Promise.all([
    fetchPermissionGroups(),
    fetchAllFunctions()
  ]);
});
</script>
