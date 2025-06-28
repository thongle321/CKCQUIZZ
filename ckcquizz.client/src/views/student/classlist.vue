<template>
  <a-page-header title="Danh sách lớp học">
    <template #avatar>
      <a-avatar>
        <template #icon>
          <School />
        </template>
      </a-avatar>
    </template>
  </a-page-header>
    <a-divider />
    <a-spin :spinning="loading" tip="Đang tải lớp học...">
      <div v-if="error" class="py-4">
        <a-alert :message="error" type="error" show-icon />
      </div>

      <div v-else-if="classes.length === 0 && !loading" class="py-4">
        <a-empty description="Bạn chưa tham gia lớp học nào." />
      </div>

      <a-row :gutter="[24, 24]" v-else>
        <a-col v-for="cls in classes" :key="cls.malop" :xs="24" :sm="12" :lg="6">
          <router-link :to="{ name: 'student-classdetail', params: { id: cls.malop } }" class="text-decoration-none">
            <a-card hoverable class="shadow-sm" :bodyStyle="{ padding: '0' }">
              <div class="position-relative" style="height: 160px; background: #B9B28A">
                <div class="text-white p-3" style="min-height: 100px;">
                  <div class="fw-semibold fs-5">
                    {{ cls.tenlop }}
                  </div>
                  <div class="fs-6">{{ cls.monHocs?.[0] || 'Chưa có môn học' }}</div>
                </div>
                <a-avatar class="position-absolute end-0 bottom-0 translate-middle-y mb-2 me-3" :size="50"
                  :src="userProfile?.avatar || ''">
                  <template #icon>
                    <CircleUserRound size="34" />
                  </template>
                </a-avatar>
                <a-dropdown trigger="click" placement="bottomRight">
                  <template #overlay>
                    <a-menu>
                      <a-menu-item @click="() => console.log('Xem chi tiết')">Xem chi tiết</a-menu-item>
                      <a-menu-item @click="() => console.log('Rời lớp học')">Rời lớp học</a-menu-item>
                    </a-menu>
                  </template>

                  <a-tooltip title="Tùy chọn">
                    <a-button type="text" shape="circle" class="position-absolute end-0 top-0 mt-2 me-2">
                      <MoreVertical color="white" />
                    </a-button>
                  </a-tooltip>
                </a-dropdown>
              </div>

              <div class="p-3 mt-5">
                <p class="mb-1 text-muted">
                  <strong>Năm học:</strong> {{ cls.namhoc || 'N/A' }} &nbsp;
                  <strong>HK:</strong> {{ cls.hocky || 'N/A' }}
                </p>
                <p class="mb-0">
                  <strong>GV:</strong> {{ cls.tengiangvien || 'Chưa cập nhật' }}
                </p>
              </div>
            </a-card>
          </router-link>
        </a-col>
      </a-row>
    </a-spin>
</template>
<script setup>
import { ref, onMounted } from 'vue';
import apiClient from '@/services/axiosServer';
import { CircleUserRound, MoreVertical, School } from 'lucide-vue-next';
const classes = ref([]);
const userProfile = ref(null);
const loading = ref(true);
const error = ref(null);

const fetchClasses = async () => {
  loading.value = true;
  error.value = null;
  try {
    const response = await apiClient.get('/Lop?hienthi=true');
    classes.value = response.data;
  } catch (err) {
    error.value = 'Không thể tải danh sách lớp học.';
    console.error('Error fetching classes:', err);
  } finally {
    loading.value = false;
  }
};
const fetchUserProfile = async () => {
  try {
    const res = await apiClient.get('/Auth/current-user-profile');
    if (res.status === 200) {
      userProfile.value = res.data;
    }
  } catch (error) {
    console.error('Failed to fetch user profile:', error);
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

.class-card-item .ant-card-body {
  flex-grow: 1;
}

.text-truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

a {
  text-decoration: none;
  color: inherit;
}
</style>