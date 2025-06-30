<template>
  <a-layout-header class="header">
    <div class="container-fluid d-flex justify-content-between align-items-center h-100">
      <div class="header-left">
        <RouterLink :to="{name: 'student-class-list'}" class="brand d-flex align-items-center text-decoration-none">
          <img src="@/assets/images/ckclogo.png" alt="CKCQuiz Logo" class="me-2" style="height: 80px; width: auto;" />
          <span class="brand-text">CKCQuiz</span>
        </RouterLink>
      </div>

      <!-- DROPDOWN BÊN PHẢI -->
      <div class="header-right">
        <a-dropdown trigger="click" placement="bottomRight">
          <template #default>
            <a-button type="text" class="p-2 d-flex align-items-center icon-button-background">
              <CircleUserRound size="20" />
              <ChevronDown />
            </a-button>
          </template>

          <template #overlay>
            <a-menu>
              <div class="d-flex flex-column align-items-center p-2 background">
                <a-avatar :size="60" :src="userProfile?.avatar || ''">
                  <template #icon>
                    <CircleUserRound size="60" />
                  </template>
                </a-avatar>
                <span class="fw-bold mt-2">{{ userProfile?.fullname }}</span>
              </div>
              <a-menu-divider />
              <a-menu-item key="profile">
                <RouterLink :to="{ name: 'profile' }" class="d-flex text-decoration-none align-items-center">
                  <Settings size="16" class="me-2" />
                  Tài khoản
                </RouterLink>
              </a-menu-item>
              <a-menu-item key="logout" @click="handleLogout">
                <span class="d-flex text-decoration-none align-items-center">
                  <LogOut size="16" class="me-2" />
                  Đăng xuất
                </span>
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
      </div>
    </div>
  </a-layout-header>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { CircleUserRound, ChevronDown, Settings, LogOut } from 'lucide-vue-next';
import apiClient from '@/services/axiosServer';
import { useAuthStore } from '@/stores/authStore';

const router = useRouter();
const authStore = useAuthStore();
const userProfile = ref(null);

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

onMounted(() => {
  if (authStore.isAuthenticated) {
    fetchUserProfile();
  }
});

const handleLogout = async () => {
  authStore.logout();
  window.location.href = '/auth/signin'
}
</script>

<style scoped>
.header {
  background-color: #fff;
  padding: 0 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  height: 64px;
  line-height: 64px;
  display: flex;
  align-items: center;
}

.header .container-fluid {
  height: 100%;
}


.header-right {
  display: flex;
  align-items: center;
}

.icon-button-background {
  background-color: rgba(0, 0, 0, 0.08);
  padding: 8px;
}

.background {
  background: rgba(238, 239, 224, 0.3);
}

.brand-text {
  font-size: 1.5rem;
  color: #3e3e3e;
}

.brand:hover .brand-text {
  color: #1a73e8;
  /* Google blue */
  text-decoration: underline;
}
</style>