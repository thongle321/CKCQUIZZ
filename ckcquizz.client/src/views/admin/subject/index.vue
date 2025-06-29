<template>
  <a-card title="Danh sách môn học" style="width: 100%">
    <template #extra>
       <a-button type="primary" @click="showAddModal = true" size="large" v-if="userStore.canCreate('MonHoc')">
          <template #icon>
            <Plus />
          </template>
          Thêm môn học
        </a-button>
    </template>
    <div class="row mb-4">
      <div class="col-12">
        <a-input v-model:value="searchText" placeholder="Tìm kiếm môn học..." allow-clear enter-button block>
          <template #prefix>
            <Search size="14" />
          </template>
        </a-input>
      </div>
    </div>

    <a-table :dataSource="subject" :columns="columns" :pagination="pagination" rowKey="mamonhoc"
      @change="handleTableChange">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'actions'">

          <a-tooltip title="Sửa môn học">
            <a-button type="text" @click="openEditModal(record)" :icon="h(SquarePen)" v-if="userStore.canUpdate('MonHoc')"/>
          </a-tooltip>
 
          <a-tooltip title="Xoá môn học">
              <a-button type="text" danger @click="handleDelete(record)" :icon="h(Trash2)" v-if="userStore.canDelete('MonHoc')"/>
          </a-tooltip>
        </template>
      </template>
    </a-table>

    <a-modal title="Thêm môn học mới" v-model:open="showAddModal" @ok="handleAddOk" @cancel="handleAddCancel"
      :confirmLoading="modalLoading" destroyOnClose>
      <a-form ref="subjectForm" :model="newSubject" layout="vertical" :rules="rules">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="Mã môn học" required name="mamonhoc">
              <a-input v-model:value="newSubject.mamonhoc" placeholder="VD: 85001" />
            </a-form-item>
          </a-col>

          <a-col :span="12">
            <a-form-item label="Tên môn học" name="tenmonhoc">
              <a-input v-model:value="newSubject.tenmonhoc" placeholder="VD: Toán rời rạc" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tín chỉ" name="sotinchi">
              <a-input-number v-model:value="newSubject.sotinchi" :min="1" :max="10" placeholder="VD: 3"
                style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết lý thuyết" name="sotietlythuyet">
              <a-input-number v-model:value="newSubject.sotietlythuyet" :min="1" :max="100" placeholder="VD: 30"
                style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết thực hành" name="sotietthuchanh">
              <a-input-number v-model:value="newSubject.sotietthuchanh" :min="1" :max="100" placeholder="VD: 15"
                style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>
    <a-modal title="Chỉnh sửa môn học" v-model:open="showEditModal" @ok="handleEditOk" @cancel="handleEditCancel"
      :confirmLoading="modalLoading" destroyOnClose>
      <a-form ref="editForm" :model="editSubject" layout="vertical" :rules="rules">
        <a-row :gutter="16">
          <a-col :span="12">
            <a-form-item label="Mã môn học" name="mamonhoc" required>
              <a-input v-model:value="editSubject.mamonhoc" disabled />
            </a-form-item>
          </a-col>

          <a-col :span="12">
            <a-form-item label="Tên môn học" name="tenmonhoc" required>
              <a-input v-model:value="editSubject.tenmonhoc" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tín chỉ" name="sotinchi" required>
              <a-input-number v-model:value="editSubject.sotinchi" :min="1" :max="10" style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết lý thuyết" name="sotietlythuyet" required>
              <a-input-number v-model:value="editSubject.sotietlythuyet" :min="1" :max="100" style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết thực hành" name="sotietthuchanh" required>
              <a-input-number v-model:value="editSubject.sotietthuchanh" :min="1" :max="100" style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>

  </a-card>
</template>
<script setup>
import { ref, onMounted, h, watch } from "vue";
import { SquarePen, Trash2, Plus } from 'lucide-vue-next';
import debounce from 'lodash/debounce';
import { message, Modal } from 'ant-design-vue';
import { Search } from "lucide-vue-next";
import apiClient from "@/services/axiosServer";
import { useUserStore } from '@/stores/userStore';

const userStore = useUserStore();
const allSubjectsData = ref([]);
const subject = ref([]);
const searchText = ref('');
const pagination = ref({
  current: 1,
  pageSize: 6,
  total: 0,
});
const showAddModal = ref(false);
const showEditModal = ref(false);
const modalLoading = ref(false);

const newSubject = ref({
  mamonhoc: "",
  tenmonhoc: "",
  sotinchi: 1,
  sotietlythuyet: 1,
  sotietthuchanh: 1,
});

const editSubject = ref({
  mamonhoc: "",
  tenmonhoc: "",
  sotinchi: 1,
  sotietlythuyet: 1,
  sotietthuchanh: 1,
});

const columns = [
  { title: "Mã môn học", dataIndex: "mamonhoc", key: "mamonhoc", width: 150 },
  { title: "Tên môn học", dataIndex: "tenmonhoc", key: "tenmonhoc", width: 150 },
  { title: "Số tín chỉ", dataIndex: "sotinchi", key: "sotinchi", width: 100 },
  { title: "Số tiết LT", dataIndex: "sotietlythuyet", key: "sotietlythuyet", width: 100 },
  { title: "Số tiết TH", dataIndex: "sotietthuchanh", key: "sotietthuchanh", width: 100 },
  { title: "Hành động", key: "actions", fixed: "right", width: 120, },
];


const rules = {
  mamonhoc: [
    { required: true, message: "Vui lòng nhập mã môn học", trigger: "blur" },
  ],
  tenmonhoc: [
    { required: true, message: "Vui lòng nhập tên môn học", trigger: "blur" },
  ],
  sotinchi: [
    { required: true, type: 'number', min: 1, message: "Tín chỉ phải ≥ 1", trigger: "change" },
  ],
  sotietlythuyet: [
    { required: true, type: 'number', min: 1, message: "Số tiết LT phải ≥ 1", trigger: "change" },
  ],
  sotietthuchanh: [
    { required: true, type: 'number', min: 0, message: "Số tiết TH phải ≥ 0", trigger: "change" },
  ],
};

const fetchAllSubjects = async () => {
  modalLoading.value = true;
  try {
    const response = await apiClient.get("/MonHoc");
    allSubjectsData.value = response.data.map(item => ({
      mamonhoc: item.mamonhoc,
      tenmonhoc: item.tenmonhoc,
      sotinchi: item.sotinchi,
      sotietlythuyet: item.sotietlythuyet,
      sotietthuchanh: item.sotietthuchanh,
      trangthai: item.trangthai
    }));
    updateDisplayedSubjects();
  } catch (error) {
    console.error("Lỗi khi tải toàn bộ môn học:", error);
    allSubjectsData.value = [];
    updateDisplayedSubjects();
  } finally {
    modalLoading.value = false;
  }
};

const updateDisplayedSubjects = () => {
  let dataToProcess = [...allSubjectsData.value];
  const keywordLower = searchText.value.trim().toLowerCase();

  if (keywordLower) {
    dataToProcess = allSubjectsData.value.filter((item) => {
      const maMonAsString = String(item.mamonhoc);
      const maMonMatch = maMonAsString.toLowerCase().includes(keywordLower);

      const tenMonMatch = item.tenmonhoc && typeof item.tenmonhoc === 'string'
        ? item.tenmonhoc.toLowerCase().includes(keywordLower)
        : false;
      return maMonMatch || tenMonMatch;
    });
  }

  pagination.value.total = dataToProcess.length;
  const start = (pagination.value.current - 1) * pagination.value.pageSize;
  const end = start + pagination.value.pageSize;
  subject.value = dataToProcess.slice(start, end);
};

const debouncedSearch = debounce(() => {
  pagination.value.current = 1;
  updateDisplayedSubjects();
}, 300);

watch(searchText, () => {
  debouncedSearch();
});

const handleTableChange = (newPagination) => {
  pagination.value.current = newPagination.current;
  pagination.value.pageSize = newPagination.pageSize;
  updateDisplayedSubjects();
};

const subjectForm = ref(null);
const editForm = ref(null);

const handleAddOk = async () => {
  try {
    // 1. Validate form trên client trước
    await subjectForm.value.validate();
    modalLoading.value = true;
    const maMonHocToCheck = newSubject.value.mamonhoc;
    if (!maMonHocToCheck) {
      message.error("Vui lòng nhập mã môn học!");
      modalLoading.value = false;
      return;
    }
    // 2. GỬI YÊU CẦU KIỂM TRA TRÙNG LẶP
    //try {
    //  await apiClient.get(`/api/MonHoc/${maMonHocToCheck}`);
    //  // Nếu lệnh await ở trên chạy thành công (không ném ra lỗi 404)
    //  // có nghĩa là MÃ MÔN HỌC ĐÃ TỒN TẠI.
    //  message.error(`Mã môn học '${maMonHocToCheck}' đã tồn tại! Vui lòng chọn mã khác.`);
    //  modalLoading.value = false;
    //  return; 

    //} catch (error) {
    //  if (error.response && error.response.status === 404) {
    //  } else {
    //    // Nếu là một lỗi khác (ví dụ: mất mạng, lỗi server 500...), thì báo lỗi và dừng lại.
    //    console.error("Lỗi khi kiểm tra mã môn học:", error);
    //    message.error("Không thể kiểm tra được mã môn học. Vui lòng thử lại.");
    //    modalLoading.value = false;
    //    return;
    //  }
    //}

    // 3. NẾU KIỂM TRA OK, TIẾN HÀNH THÊM MỚI
    const payload = {
      mamonhoc: Number(newSubject.value.mamonhoc),
      tenmonhoc: newSubject.value.tenmonhoc,
      sotinchi: newSubject.value.sotinchi,
      sotietlythuyet: newSubject.value.sotietlythuyet,
      sotietthuchanh: newSubject.value.sotietthuchanh,
      trangthai: true,
    };

    // Gửi yêu cầu POST để tạo mới
    await apiClient.post("/MonHoc", payload);

    message.success("Thêm môn học thành công!");
    showAddModal.value = false;
    subjectForm.value.resetFields();
    newSubject.value = { mamonhoc: "", tenmonhoc: "", sotinchi: 1, sotietlythuyet: 1, sotietthuchanh: 1 };
    await fetchAllSubjects();

  } catch (error) {
    // Bắt các lỗi khác, ví dụ lỗi validation của form
      
    if (error?.message?.includes("validate")) {
    } else {
      message.error("Thông tin môn học bị lỗi, vui lòng kiểm tra lại!");
    }
  } finally {
    modalLoading.value = false;
  }
};

const handleAddCancel = () => {
  showAddModal.value = false;
  subjectForm.value.resetFields();
  newSubject.value = {
    mamonhoc: "", tenmonhoc: "", sotinchi: 1, sotietlythuyet: 1, sotietthuchanh: 1,
  };
};

const openEditModal = (record) => {
  editSubject.value = { ...record };
  showEditModal.value = true;
};

const handleEditOk = () => {
  editForm.value.validate().then(async () => {
    modalLoading.value = true;
    try {
      const payloadToUpdate = {
        tenmonhoc: editSubject.value.tenmonhoc,
        sotinchi: editSubject.value.sotinchi,
        sotietlythuyet: editSubject.value.sotietlythuyet,
        sotietthuchanh: editSubject.value.sotietthuchanh,
        trangthai: editSubject.value.trangthai,
      };
      await apiClient.put(`/MonHoc/${editSubject.value.mamonhoc}`, payloadToUpdate);
      showEditModal.value = false;
      await fetchAllSubjects();
    } catch (error) {
      console.error("Lỗi sửa môn học:", error);
    } finally {
      modalLoading.value = false;
    }
  }).catch((errorInfo) => {
    console.log("Lỗi validate form sửa:", errorInfo);
  });
};

const handleEditCancel = () => {
  showEditModal.value = false;
};

// const handleDelete = async (mamonhocId) => {
//   modalLoading.value = true;
//   try {
//     await apiClient.delete(`/api/MonHoc/${mamonhocId}`);
//     await fetchAllSubjects();
//   } catch (error) {
//     console.error("Lỗi xóa môn học:", error);
//   } finally {
//     modalLoading.value = false;
//   }
// };
const handleDelete = async (monhoc) => {
  Modal.confirm({
    title: 'Xác nhận xóa môn học',
    content: `Bạn có chắc chắn muốn xóa môn học ${monhoc.tenmonhoc}?`,
    okText: 'Có',
    okType: 'danger',
    cancelText: 'Không',
    onOk: async () => {
      try {
        await apiClient.delete(`/MonHoc/${monhoc.mamonhoc}`);
        message.success('Đã xóa môn học thành công');
        await fetchAllSubjects();
      } catch (error) {
        message.error('Lỗi khi xóa môn học' + (error.response?.data || error.message));
        console.error(error);
      }
    },
  });
};
onMounted(async () => {
  await userStore.fetchUserPermissions(); // Ensure permissions are fetched first
  fetchAllSubjects();
});
</script>
