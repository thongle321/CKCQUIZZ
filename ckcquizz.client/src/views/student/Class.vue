<template>
  <a-card title="Lớp học của tôi" style="width: 100%">
    <div class="row mb-4">
      <div class="col-12 d-flex justify-content-end">
        <a-button type="primary" size="large" @click="showJoinDialog = true">
          <template #icon>
            <Plus />
          </template>
          Tham gia lớp học
        </a-button>
      </div>
    </div>

    <a-spin :spinning="loading" tip="Đang tải lớp học...">
      <div v-if="error" class="text-center p-10 bg-gray-50 rounded-lg">
        <a-alert :message="error" type="error" show-icon />
      </div>
      <div v-else-if="classes.length === 0 && !loading" class="text-center p-10 bg-gray-50 rounded-lg">
        <a-empty description="Bạn chưa tham gia lớp học nào." />
      </div>
      <div v-else>
        <a-row :gutter="[16, 16]">
          <a-col v-for="cls in classes" :key="cls.malop" :xs="24" :sm="12" :lg="8">
            <a-card hoverable class="class-card-item">
              <template #title>
                <div class="font-bold text-base">{{ cls.tenlop }}</div>
              </template>
              <p><strong>Mã lớp:</strong> {{ cls.malop }}</p>
              <p v-if="cls.mota"><strong>Mô tả:</strong> {{ cls.mota }}</p>
              <p><strong>Giảng viên:</strong> {{ cls.tenGiangVien }}</p>
              <p><strong>Môn học:</strong> {{ cls.tenMonHoc }}</p>
            </a-card>
          </a-col>
        </a-row>
      </div>
    </a-spin>

    <a-modal v-model:open="showJoinDialog" title="Tham gia lớp học" @ok="joinClass" :confirm-loading="joinLoading"
      @cancel="inviteCode = ''">
      <a-form layout="vertical">
        <a-form-item label="Mã mời">
          <a-input v-model:value="inviteCode" placeholder="Nhập mã mời của lớp học" />
        </a-form-item>
      </a-form>
      <a-alert v-if="message" :message="message" :type="messageType" show-icon class="mt-3" />
    </a-modal>
  </a-card>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from '@/services/axiosServer';
import { message as AntdMessage } from 'ant-design-vue';
import { Plus } from 'lucide-vue-next';

const classes = ref([]);
const loading = ref(true);
const error = ref(null);
const showJoinDialog = ref(false);
const inviteCode = ref('');
const joinLoading = ref(false);
const message = ref('');
const messageType = ref('');

const fetchClasses = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await axios.get('/Lop?hienthi=true');
    classes.value = response.data;
  } catch (err) {
    error.value = 'Không thể tải danh sách lớp học.';
    console.error('Error fetching classes:', err);
  } finally {
    loading.value = false;
  }
};

const joinClass = async () => {
  if (!inviteCode.value) {
    message.value = 'Vui lòng nhập mã mời.';
    messageType.value = 'error';
    return;
  }

  joinLoading.value = true;
  message.value = '';
  try {
    const response = await axios.post('/Lop/join-by-code', { inviteCode: inviteCode.value });
    AntdMessage.success(response.data.message);
    showJoinDialog.value = false;
    inviteCode.value = '';
    await fetchClasses();
  } catch (err) {
    const errorMessage = err.response?.data?.message || 'Không thể tham gia lớp học. Vui lòng thử lại.';
    AntdMessage.error(errorMessage);
    message.value = errorMessage;
    messageType.value = 'error';
    console.error('Error joining class:', err);
  } finally {
    joinLoading.value = false;
  }
};

onMounted(fetchClasses);
</script>

<style scoped>
.class-card-item {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.class-card-item .ant-card-head {
  flex-shrink: 0;
}

.class-card-item .ant-card-body {
  flex-grow: 1;
}
</style>