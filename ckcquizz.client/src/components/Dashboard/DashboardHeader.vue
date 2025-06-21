<template>
  <a-layout-header class="dashboard-header d-flex justify-content-between align-items-center px-3" style="height: 64px;">
    <!-- Header Left -->
    <div class="d-flex flex-column justify-content-center">
      <a-breadcrumb class="mb-0 small text-secondary">
        <a-breadcrumb-item>
          <a href="#" class="text-secondary text-decoration-none">Pages</a>
        </a-breadcrumb-item>
        <a-breadcrumb-item class="text-dark fw-semibold">Dashboard</a-breadcrumb-item>
      </a-breadcrumb>
      <h5 class="page-title mb-0 fw-semibold fs-6 text-dark">Dashboard</h5>
    </div>

    <!-- Header Right -->
    <div class="d-flex align-items-center gap-2 mx-3">
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
              <a-menu-item>
                <RouterLink :to="{ name: 'profile'}" class="d-flex text-decoration-none align-items-center">
                  <Settings size="16" class="me-2" />
                  Tài khoản
                </RouterLink>
              </a-menu-item>
              <a-menu-item key="logout" @click="logout">
                <span class="d-flex text-decoration-none align-items-center">
                  <LogOut size="16" class="me-2" />
                  Đăng xuất
                </span>
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>

      <a-dropdown>
        <template #default>

          <a-badge count="3" :overflow-count="99" size="small" :offset="[8, 0]">
            <a-button type="text" class="p-2 d-flex align-items-center icon-button-background" aria-label="Notifications">



              <Bell size="20" />
            </a-button>
          </a-badge>
        </template>
        <template #overlay>
          <a-menu style="min-width: 200px;">
            <a-menu-item key="1">Notification 1</a-menu-item>
            <a-menu-item key="2">Notification 2</a-menu-item>
            <a-menu-item key="3">Notification 3</a-menu-item>
          </a-menu>
        </template>
      </a-dropdown>
    </div>
  </a-layout-header>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import { useAuthStore } from '@/stores/authStore';

import {
  CircleUserRound,
  Settings,
  LogOut,
  Bell,
  ChevronDown
} from 'lucide-vue-next';


const router = useRouter();
const userProfile = ref(null)
const authStore = useAuthStore();

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
const logout = async () => {
  try {
    const res = await apiClient.post('/Auth/logout');
    if (res.status === 200) {
      const authStore = useAuthStore();
      authStore.logout();
      router.push({ name: 'SignIn' });
    }
  } catch (error) {
    console.error('Logout thất bại', error);
  }
};
onMounted(() => {
  if (authStore.isAuthenticated) {
    fetchUserProfile();
  }
});
</script>

<style scoped>
.dashboard-header {
  z-index: 999;
  background-color: white;
  box-shadow: 0 2px 8px #f0f1f2;
}
.page-title {
  margin-top: 0.125rem;
}
.icon-button-background {
  background-color: rgba(0, 0, 0, 0.05); 
  padding: 8px; 
}
</style>
