<template>
  <a-card title="Danh sách nhóm quyền" style="width: 100%">
    <!-- Nút Thêm mới -->
    <a-button type="primary" @click="openAddModal" style="margin-bottom: 16px;">
      <template #icon><PlusOutlined /></template>
      Thêm mới
    </a-button>

    <!-- Thanh tìm kiếm -->
    <div class="mb-4">
      <a-input v-model:value="searchText"
               placeholder="Tìm kiếm nhóm quyền..."
               allow-clear
               style="width: 300px;">
        <template #prefix><SearchOutlined /></template>
      </a-input>
    </div>

    <!-- Bảng dữ liệu -->
    <a-table :dataSource="permissionGroups"
             :columns="columns"
             :pagination="pagination"
             :loading="tableLoading"
             rowKey="maNhomQuyen"
             @change="handleTableChange">
      <!-- Slot cho cột hành động -->
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'actions'">
          <a-tooltip title="Sửa nhóm quyền">
            <a-button type="text"
                      @click="openEditModal(record)"
                      :icon="h(EditOutlined)" />
          </a-tooltip>
          <a-tooltip title="Xoá nhóm quyền">
            <a-popconfirm title="Bạn có chắc muốn xóa nhóm quyền này?"
                          ok-text="Có"
                          cancel-text="Không"
                          @confirm="handleDelete(record.maNhomQuyen)">
              <a-button type="text"
                        danger
                        :icon="h(DeleteOutlined)" />
            </a-popconfirm>
          </a-tooltip>
        </template>
      </template>
    </a-table>

    <!-- Modal thêm nhóm quyền -->
    <a-modal title="Thêm nhóm quyền mới"
             v-model:open="showAddModal"
             @ok="handleAddOk"
             @cancel="handleAddCancel"
             :confirmLoading="modalLoading"
             destroyOnClose>
      <a-form ref="addFormRef" :model="newPermissionGroup" layout="vertical" :rules="rules">
        <a-form-item label="Tên nhóm quyền" name="tenNhom" required>
          <a-input v-model:value="newPermissionGroup.tenNhom" placeholder="VD: Quản trị viên" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- Modal sửa nhóm quyền -->
    <a-modal title="Chỉnh sửa nhóm quyền"
             v-model:open="showEditModal"
             @ok="handleEditOk"
             @cancel="handleEditCancel"
             :confirmLoading="modalLoading"
             destroyOnClose>
      <a-form ref="editFormRef" :model="editPermissionGroup" layout="vertical" :rules="rules">
        <a-form-item label="Mã nhóm quyền">
          <a-input :value="editPermissionGroup.maNhomQuyen" disabled />
        </a-form-item>
        <a-form-item label="Tên nhóm quyền" name="tenNhom" required>
          <a-input v-model:value="editPermissionGroup.tenNhom" />
        </a-form-item>
      </a-form>
    </a-modal>
  </a-card>
</template>

<script setup>
import { ref, onMounted, h, watch, reactive } from "vue";
import { EditOutlined, DeleteOutlined, PlusOutlined, SearchOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import debounce from 'lodash/debounce';

// --- CẤU HÌNH BẢNG ---
const columns = [
  { title: "Mã nhóm quyền", dataIndex: "maNhomQuyen", key: "maNhomQuyen", width: 150 },
  { title: "Tên nhóm", dataIndex: "tenNhom", key: "tenNhom" },
  { title: "Số người dùng", dataIndex: "soNguoiDung", key: "soNguoiDung", width: 150 },
  { title: "Hành động", key: "actions", fixed: "right", width: 120, align: 'center' },
];



const rules = {
  tenNhom: [{ required: true, message: "Vui lòng nhập tên nhóm quyền", trigger: "blur" }],
};
</script>
