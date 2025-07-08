<template>
  <a-layout-header class="dashboard-header d-flex justify-content-between align-items-center px-3"
    style="height: 64px;">
    <!-- Header Left -->
    <div class="d-flex flex-column justify-content-center">
      <a-breadcrumb class="mb-0 small text-secondary">
        <a-breadcrumb-item v-for="(item, index) in breadcrumbItems" :key="index">
          <RouterLink v-if="item.path && index < breadcrumbItems.length - 1" :to="item.path"
            class="text-secondary text-decoration-none">
            {{ item.name }}
          </RouterLink>
          <span v-else :class="{ 'text-dark fw-semibold': index === breadcrumbItems.length - 1 }">
            {{ item.name }}
          </span>
        </a-breadcrumb-item>
      </a-breadcrumb>
      <h5 class="page-title mb-0 fw-semibold fs-6 text-dark">{{ pageTitle }}</h5>
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
              <RouterLink :to="{ name: 'profile' }" class="d-flex text-decoration-none align-items-center">
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

      <!-- <a-dropdown>
        <template #default>

          <a-badge count="3" :overflow-count="99" size="small" :offset="[8, 0]">
            <a-button type="text" class="p-2 d-flex align-items-center icon-button-background"
              aria-label="Notifications">



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
      </a-dropdown> -->
    </div>
  </a-layout-header>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
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
const route = useRoute();
const userProfile = ref(null)
const authStore = useAuthStore();

const breadcrumbItems = computed(() => {
  const matchedRoutes = route.matched;
  const items = [];

  items.push({ name: 'Trang', path: '/admin/dashboard' });

  matchedRoutes.forEach(match => {
    if (match.name) {
      let name = String(match.name);
      if (name.startsWith('admin-')) {
        name = name.substring(6);
      } else if (name.startsWith('teacher-')) {
        name = name.substring(8);
      }
      name = name.charAt(0).toUpperCase() + name.slice(1);

      if (match.meta && match.meta.breadcrumb) {
        items.push({
          name: match.meta.breadcrumb,
          path: match.path
        });
      } else {
        items.push({
          name: name,
          path: match.path
        });
      }
    }
  });
  return items;
});

const pageTitle = computed(() => {
  const lastMatched = route.matched[route.matched.length - 1];
  if (lastMatched && lastMatched.name) {
    let title = String(lastMatched.name);
    if (title.startsWith('admin-')) {
      title = title.substring(6);
    } else if (title.startsWith('teacher-')) {
      title = title.substring(8);
    }
    title = title.charAt(0).toUpperCase() + title.slice(1);

    if (lastMatched.meta && lastMatched.meta.title) {
      return lastMatched.meta.title;
    } else {
      return title;
    }
  }
  return 'Dashboard';
});

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
  await authStore.logout();
  router.push({ name: 'SignInTeacher' }); 
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
