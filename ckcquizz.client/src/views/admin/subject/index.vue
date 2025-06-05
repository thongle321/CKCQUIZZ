<template>
  <a-card title="Môn học" style="width: 100%">
    <a-button type="primary" @click="showAddModal = true" style="margin-bottom: 16px;">
      Thêm môn học
    </a-button>
    <div class="mb-4">
      <a-input v-model:value="searchText"
               placeholder="Tìm kiếm môn học..."
               allow-clear
               style="width: 300px;"
               prefix-icon="SearchOutlined" />
    </div>
    <a-table :dataSource="subject"
             :columns="columns"
             :pagination="pagination"
             rowKey="mamonhoc"
             @change="handleTableChange">
      <!-- Slot cho cột hành động -->
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'actions'">
          <a-tooltip title="Danh sách chương">
            <a-button type="text"
                      @click="openChapterListModal(record)"
                      :icon="h(ApartmentOutlined)"/> 
                      
          </a-tooltip>
          <a-tooltip title="Sửa môn học">
            <a-button type="text"
                      @click="openEditModal(record)"
                      :icon="h(EditOutlined)" />
          </a-tooltip>

          <a-tooltip title="Xoá môn học">
            <a-popconfirm title="Bạn có chắc muốn xóa môn học này?"
                          ok-text="Có"
                          cancel-text="Không"
                          @confirm="handleDelete(record.mamonhoc)">
              <a-button type="text"
                        danger
                        :icon="h(DeleteOutlined)" />
            </a-popconfirm>
          </a-tooltip>
        </template>
      </template>
    </a-table>

    <!-- Modal thêm môn học -->
    <a-modal title="Thêm môn học mới"
             v-model:open="showAddModal"
             @ok="handleAddOk"
             @cancel="handleAddCancel"
             :confirmLoading="modalLoading"
             destroyOnClose>
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
              <a-input-number v-model:value="newSubject.sotinchi"
                              :min="1"
                              :max="10"
                              placeholder="VD: 3"
                              style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết lý thuyết" name="sotietlythuyet">
              <a-input-number v-model:value="newSubject.sotietlythuyet"
                              :min="1"
                              :max="100"
                              placeholder="VD: 30"
                              style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết thực hành" name="sotietthuchanh">
              <a-input-number v-model:value="newSubject.sotietthuchanh"
                              :min="1"
                              :max="100"
                              placeholder="VD: 15"
                              style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>
    <!-- Modal sửa môn học -->
    <a-modal title="Chỉnh sửa môn học"
             v-model:open="showEditModal"
             @ok="handleEditOk"
             @cancel="handleEditCancel"
             :confirmLoading="modalLoading"
             destroyOnClose>
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
              <a-input-number v-model:value="editSubject.sotinchi"
                              :min="1"
                              :max="10"
                              style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết lý thuyết" name="sotietlythuyet" required>
              <a-input-number v-model:value="editSubject.sotietlythuyet"
                              :min="1"
                              :max="100"
                              style="width: 100%" />
            </a-form-item>
          </a-col>

          <a-col :span="8">
            <a-form-item label="Số tiết thực hành" name="sotietthuchanh" required>
              <a-input-number v-model:value="editSubject.sotietthuchanh"
                              :min="1"
                              :max="100"
                              style="width: 100%" />
            </a-form-item>
          </a-col>
        </a-row>
      </a-form>
    </a-modal>
    <!-- Modal Danh sách chương -->
    <a-modal :title="`Danh sách chương: ${currentSubjectForChapters?.tenmonhoc || ''}`"
             v-model:open="showChapterListModal"
             @cancel="closeChapterListModal"
             width="700px"
             :footer="null"
             destroyOnClose>
      <a-button type="primary" @click="openAddChapterFormModal" style="margin-bottom: 16px;">
        + Thêm chương
      </a-button>
      <a-table :dataSource="chapters"
               :columns="chapterTableColumns"
               :loading="chapterListLoading"
               rowKey="machuong"
               :pagination="false">
        <template #bodyCell="{ column, record, index }">
          <template v-if="column.key === 'stt'">
            {{ index + 1 }}
          </template>
          <template v-if="column.key === 'actions'">
            <a-tooltip title="Sửa chương">
              <a-button type="text" @click="openEditChapterFormModal(record)" :icon="h(EditOutlined)" />
            </a-tooltip>
            <a-tooltip title="Xoá chương">
              <a-popconfirm title="Bạn có chắc muốn xóa chương này?"
                            ok-text="Có"
                            cancel-text="Không"
                            @confirm="handleDeleteChapter(record.machuong)">
                <a-button type="text" danger :icon="h(DeleteOutlined)" />
              </a-popconfirm>
            </a-tooltip>
          </template>
        </template>
      </a-table>
      <template #footer>
        <a-button key="back" @click="closeChapterListModal">Thoát</a-button>
      </template>
    </a-modal>

    <!-- Modal Thêm/Sửa Chương -->
    <a-modal :title="isEditingChapter ? 'Sửa chương' : 'Thêm chương mới'"
             v-model:open="showChapterFormModal"
             @ok="handleChapterFormOk"
             @cancel="closeChapterFormModal"
             :confirmLoading="chapterFormLoading"
             destroyOnClose>
      <a-form ref="chapterFormRef" :model="currentChapter" layout="vertical" :rules="chapterRules">
        <a-form-item label="Tên chương" name="tenchuong" required>
          <a-input v-model:value="currentChapter.tenchuong" placeholder="Nhập tên chương" />
        </a-form-item>
        <!-- Thêm các trường khác cho chương nếu có, ví dụ: trạng thái -->
      </a-form>
    </a-modal>
  </a-card>
</template>
<script setup>
  import { ref, onMounted, h, watch } from "vue";
  import axios from "axios";
  import { EditOutlined, DeleteOutlined, ApartmentOutlined } from '@ant-design/icons-vue';
  import debounce from 'lodash/debounce';

  // Data và trạng thái
  const allSubjectsData = ref([]); // Sẽ chứa TOÀN BỘ dữ liệu từ API /api/MonHoc
  const subject = ref([]); // Dữ liệu hiển thị trên table (dataSource cho a-table)
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
    mamonhoc: "", // Sẽ là string nếu API trả về string, number nếu API trả về number.
    // API của bạn trả về number cho mamonhoc, nhưng input thường là string.
    // Cần đảm bảo kiểu dữ liệu khi gửi đi.
    tenmonhoc: "",
    sotinchi: 1,
    sotietlythuyet: 1,
    sotietthuchanh: 1,
    // trangthai: true, // Nếu bạn muốn set mặc định khi thêm
  });

  const editSubject = ref({
    mamonhoc: "",
    tenmonhoc: "",
    sotinchi: 1,
    sotietlythuyet: 1,
    sotietthuchanh: 1,
    // trangthai: true,
  });

  // Cột bảng (dataIndex phải khớp với key trong object item của subject.value)
  const columns = [
    { title: "Mã môn học", dataIndex: "mamonhoc", key: "mamonhoc", width: 150 },
    { title: "Tên môn học", dataIndex: "tenmonhoc", key: "tenmonhoc", width: 150 },
    { title: "Số tín chỉ", dataIndex: "sotinchi", key: "sotinchi", width: 100 },
    { title: "Số tiết LT", dataIndex: "sotietlythuyet", key: "sotietlythuyet", width: 100 },
    { title: "Số tiết TH", dataIndex: "sotietthuchanh", key: "sotietthuchanh", width: 100 },
    // { title: "Trạng thái", dataIndex: "trangthai", key: "trangthai", width: 100 }, // Nếu muốn hiển thị
    { title: "Hành động", key: "actions", fixed: "right", width: 120, },
  ];

  // Rules cho form
  const rules = {
    mamonhoc: [
      { required: true, message: "Vui lòng nhập mã môn học", trigger: "blur" },
      // API trả về mamonhoc là number, nhưng input là text.
      // Nếu backend yêu cầu mã môn học là số và tự động tăng hoặc là string, điều chỉnh rule.
      // Nếu mã môn học là số như API trả về (ví dụ 51258), rule pattern này có thể không cần.
      // { pattern: /^\d{5}$/, message: "Mã môn học phải gồm 5 chữ số", trigger: "blur" },
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
      { required: true, type: 'number', min: 0, message: "Số tiết TH phải ≥ 0", trigger: "change" }, // Có thể là 0
    ],
  };

  // 1. Hàm lấy TOÀN BỘ dữ liệu
  const fetchAllSubjects = async () => {
    modalLoading.value = true; // Bắt đầu tải chung
    try {
      const response = await axios.get("https://localhost:7254/api/MonHoc");
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
      updateDisplayedSubjects(); // Vẫn cập nhật để table rỗng hoặc hiển thị lỗi
      // Hiển thị thông báo lỗi cho người dùng ở đây nếu cần
    } finally {
      modalLoading.value = false; // Kết thúc tải chung
    }
  };

  // 2. Hàm cập nhật dữ liệu hiển thị (kết hợp search và pagination)
  const updateDisplayedSubjects = () => {
    let dataToProcess = [...allSubjectsData.value];
    const keywordLower = searchText.value.trim().toLowerCase();

    if (keywordLower) {
      dataToProcess = allSubjectsData.value.filter((item) => {
        // `mamonhoc` từ API là number, cần chuyển sang string để .includes và .toLowerCase
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

  // 3. Debounce cho việc tìm kiếm
  const debouncedSearch = debounce(() => {
    pagination.value.current = 1; // Reset về trang 1 khi tìm kiếm
    updateDisplayedSubjects();
  }, 300);

  watch(searchText, () => {
    debouncedSearch();
  });

  // 4. Xử lý thay đổi phân trang
  const handleTableChange = (newPagination) => {
    pagination.value.current = newPagination.current;
    pagination.value.pageSize = newPagination.pageSize;
    updateDisplayedSubjects();
  };

  // Refs form
  const subjectForm = ref(null);
  const editForm = ref(null);

  // 5. Xử lý thêm môn học
  const handleAddOk = () => {
    subjectForm.value.validate().then(async () => {
      modalLoading.value = true; // Chỉ loading cho modal này
      try {
        const payload = {
          // API của bạn có vẻ nhận mamonhoc là number
          mamonhoc: Number(newSubject.value.mamonhoc), // Chuyển sang Number nếu input là string
          tenmonhoc: newSubject.value.tenmonhoc,
          sotinchi: newSubject.value.sotinchi,
          sotietlythuyet: newSubject.value.sotietlythuyet,
          sotietthuchanh: newSubject.value.sotietthuchanh,
          trangthai: true, // Mặc định là true khi thêm mới, hoặc lấy từ form
        };
        await axios.post("https://localhost:7254/api/MonHoc", payload);
        showAddModal.value = false;
        subjectForm.value.resetFields();
        newSubject.value = { // Reset newSubject về giá trị ban đầu
          mamonhoc: "", tenmonhoc: "", sotinchi: 1, sotietlythuyet: 1, sotietthuchanh: 1,
        };
        await fetchAllSubjects(); // Tải lại toàn bộ dữ liệu
      } catch (error) {
        console.error("Lỗi thêm môn học:", error);
        // Xử lý hiển thị lỗi cụ thể từ API (ví dụ: mã môn học đã tồn tại)
      } finally {
        modalLoading.value = false;
      }
    }).catch((errorInfo) => {
      console.log("Lỗi validate form thêm:", errorInfo);
    });
  };

  const handleAddCancel = () => {
    showAddModal.value = false;
    subjectForm.value.resetFields();
    newSubject.value = {
      mamonhoc: "", tenmonhoc: "", sotinchi: 1, sotietlythuyet: 1, sotietthuchanh: 1,
    };
  };

  // 6. Mở modal sửa và xử lý sửa
  const openEditModal = (record) => {
    // record từ subject.value, đã có key đúng
    editSubject.value = { ...record };
    showEditModal.value = true;
  };

  const handleEditOk = () => {
    editForm.value.validate().then(async () => {
      modalLoading.value = true; // Chỉ loading cho modal này
      try {
        const payloadToUpdate = {
          // mamonhoc không cần gửi trong body vì nó là ID trong URL
          tenmonhoc: editSubject.value.tenmonhoc,
          sotinchi: editSubject.value.sotinchi,
          sotietlythuyet: editSubject.value.sotietlythuyet,
          sotietthuchanh: editSubject.value.sotietthuchanh,
          trangthai: editSubject.value.trangthai, // Nếu cho phép sửa trạng thái
        };
        await axios.put(`https://localhost:7254/api/MonHoc/${editSubject.value.mamonhoc}`, payloadToUpdate);
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
    // editForm.value.resetFields(); // Cân nhắc có nên reset không, vì dữ liệu đã load từ record
  };

  // 7. Xóa môn học
  const handleDelete = async (mamonhocId) => {
    modalLoading.value = true; // Loading chung cho cả bảng
    try {
      await axios.delete(`https://localhost:7254/api/MonHoc/${mamonhocId}`);
      await fetchAllSubjects();
    } catch (error) {
      console.error("Lỗi xóa môn học:", error);
    } finally {
      modalLoading.value = false;
    }
  };

  // Gọi dữ liệu ban đầu
  onMounted(() => {
    fetchAllSubjects();
  });
</script>
