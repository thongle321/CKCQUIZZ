<template>
  <a-card>
    <a-tabs v-model:activeKey="activeKey">
      <a-tab-pane key="profile" tab="Hồ sơ">
        <div class="row">
          <div class="col-md-8">
            <a-form :model="profileForm" layout="vertical">
              <a-form-item label="Mã sinh viên">
                <a-input v-model:value="profileForm.studentId" disabled />
              </a-form-item>
              <a-form-item label="Họ và tên">
                <a-input v-model:value="profileForm.fullName" disabled/>
              </a-form-item>
              <a-form-item label="Địa chỉ email">
                <a-input v-model:value="profileForm.email" disabled />
              </a-form-item>
              <a-form-item label="Số điện thoại">
                <a-input v-model:value="profileForm.phoneNumber" disabled/>
              </a-form-item>
              <a-form-item label="Giới tính">
                <a-radio-group v-model:value="profileForm.gender" disabled>
                  <a-radio :value="true">Nam</a-radio>
                  <a-radio :value="false">Nữ</a-radio>
                </a-radio-group>
              </a-form-item>
              <a-form-item label="Ngày sinh">
                <a-date-picker v-model:value="profileForm.dateOfBirth" style="width: 100%;" disabled/>
              </a-form-item>
              <a-form-item label="Ảnh đại diện">
                <div class="d-flex align-items-center">
                  <a-avatar :size="64" :src="profileForm.avatar">
                    <template #icon>
                      <UserOutlined />
                    </template>
                  </a-avatar>
                  <a-upload v-model:file-list="fileList" name="avatar" list-type="picture" :max-count="1"
                    :before-upload="beforeUpload" :customRequest="handleAvatarUpload" class="ms-3">
                    <a-button>
                      <UploadOutlined />
                      Chọn ảnh đại diện mới
                    </a-button>
                  </a-upload>
                </div>
              </a-form-item>
              <a-form-item>
                <a-button type="primary" :loading="isLoading" @click="updateProfile">Cập nhật hồ sơ</a-button>
              </a-form-item>
            </a-form>
          </div>
        </div>
      </a-tab-pane>
    </a-tabs>
  </a-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import { UserOutlined, UploadOutlined } from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import dayjs from 'dayjs';
import apiClient from '@/services/axiosServer';

const activeKey = ref('profile');
const isLoading = ref(false);

const profileForm = reactive({
  studentId: '',
  fullName: '',
  email: '',
  phoneNumber: '',
  gender: false,
  dateOfBirth: null,
  avatar: ''
});

const fileList = ref([]);

const beforeUpload = (file) => {
  const isJpgOrPng = file.type === 'image/jpeg' || file.type === 'image/png';
  if (!isJpgOrPng) {
    message.error('Bạn chỉ có thể upload ảnh jpeg và png');
  }
  const limit = file.size / 1024 / 1024 < 2;
  if (!limit) {
    message.error('Ảnh đại diện phải nhỏ hơn 2MB');
  }
  return isJpgOrPng && limit;
};

const handleAvatarUpload = async ({ file }) => {
  const formData = new FormData();
  formData.append('file', file);
  try {
    const response = await apiClient.post('/Files/upload-avatar', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    profileForm.avatar = response.data.url;
    if (fileList.value.length > 0) {
      fileList.value[0].status = 'done';
    }
    message.success('Ảnh đã được tải lên. Nhấn "Cập nhật hồ sơ" để lưu thay đổi.');
  } catch (error) {
    message.error('Tải ảnh đại diện thất bại.');
    fileList.value[0].status = 'error';
  }
};

const fetchUserProfile = async () => {
  isLoading.value = true;
  try {
    const response = await apiClient.get(`/Auth/current-user-profile`);
    const userData = response.data
    profileForm.studentId = userData.mssv
    profileForm.fullName = userData.fullname
    profileForm.email = userData.email;
    profileForm.phoneNumber = userData.phonenumber
    profileForm.gender = userData.gender
    profileForm.dateOfBirth = userData.dob ? dayjs(userData.dob) : undefined,
      profileForm.avatar = userData.avatar
  } catch (error) {
  } finally {
    isLoading.value = false
  }
};

const updateProfile = async () => {
  isLoading.value = true
  try {
    const payload = {
      fullName: profileForm.fullName,
      email: profileForm.email,
      phoneNumber: profileForm.phoneNumber,
      gender: profileForm.gender,
      dob: profileForm.dateOfBirth ? profileForm.dateOfBirth.toISOString() : undefined,
      avatar: profileForm.avatar,
    };

    console.log('Dữ liệu trước khi cập nhật:', payload);
    await apiClient.put(`/Auth/update-profile`, payload);
    message.success('Cập nhật profile thành công');
    await fetchUserProfile();
  } catch (error) {
    console.error('Error updating profile:', error);
    message.error('Không thể cập nhật profile');
  } finally {
    isLoading.value = false;

  }
};

onMounted(() => {
  fetchUserProfile();
})
</script>

<style scoped>
.container {
  max-width: 960px;
}
</style>