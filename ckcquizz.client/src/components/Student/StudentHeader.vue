<template>
  <a-layout-header class="header">
    <div class="container-fluid d-flex justify-content-between align-items-center h-100">
      <div class="header-left">
        <a-menu mode="horizontal" :selectedKeys="selectedKeys" class="main-menu">
          <a-menu-item key="dashboard">
            <RouterLink :to="{ name: 'student-dashboard' }">Dashboard</RouterLink>
          </a-menu-item>
          <a-menu-item key="lophocphan">
            <RouterLink :to="{ name: 'student-class' }">Lớp học</RouterLink>
          </a-menu-item>
        </a-menu>
      </div>
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
              <a-menu-item>
                <RouterLink :to="{ name: 'profile'}" class="d-flex text-decoration-none align-items-center">
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
import { ref, watch, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { CircleUserRound, ChevronDown, Settings, LogOut } from 'lucide-vue-next';
import apiClient from '@/services/axiosServer';
import { useAuthStore } from '@/stores/authStore';

const route = useRoute();
const router = useRouter();
const selectedKeys = ref([]);
const authStore = useAuthStore();
const userProfile = ref(null)

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

watch(
  () => route.path,
  (path) => {
    if (path.includes('/student/dashboard')) {
      selectedKeys.value = ['dashboard'];
    } else if (path.includes('/student/class')) {
      selectedKeys.value = ['lophocphan'];
    } else {
      selectedKeys.value = [];
    }
  },
  { immediate: true }
);

const handleLogout = async () => {
  try {
    const res = await apiClient.post('/Auth/logout')
    if (res.status === 200) {
      const authStore = useAuthStore()
      authStore.logout()
      router.push({ name: 'SignIn' })
    }
  } catch (error) {
    console.log(error)
  }
};
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

.main-menu {
  border-bottom: none;
  line-height: 64px;
}

.main-menu .ant-menu-item {
  height: 64px;
  line-height: 64px;
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

</style>
