<template>
  <a-layout-header class="header">
    <div class="container-fluid d-flex justify-content-between align-items-center h-100">
      <div class="header-left">
        <a-menu
          mode="horizontal"
          :selectedKeys="selectedKeys"
          class="main-menu"
        >
          <a-menu-item key="dashboard">
            <router-link to="/student/dashboard">Dashboard</router-link>
          </a-menu-item>
          <a-menu-item key="quizzes">
            <router-link to="/student/quizzes">Quizzes</router-link>
          </a-menu-item>
          <a-menu-item key="results">
            <router-link to="/student/results">Results</router-link>
          </a-menu-item>
        </a-menu>
      </div>
      <div class="header-right">
        <a-dropdown>
          <a-avatar style="background-color: #87d068; cursor: pointer;">
            <template #icon><UserOutlined /></template>
          </a-avatar>
          <template #overlay>
            <a-menu>
              <a-menu-item key="profile">
                <router-link to="/student/profile">Profile</router-link>
              </a-menu-item>
              <a-menu-item key="settings">
                <router-link to="/student/settings">Settings</router-link>
              </a-menu-item>
              <a-menu-item key="logout">
                <a @click="handleLogout">Logout</a>
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
      </div>
    </div>
  </a-layout-header>
</template>

<script setup>
import { ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { UserOutlined } from '@ant-design/icons-vue';
import 'bootstrap/dist/css/bootstrap.min.css'; // Import Bootstrap CSS

const route = useRoute();
const selectedKeys = ref([]);

// Update selectedKeys based on the current route
watch(
  () => route.path,
  (path) => {
    if (path.includes('/student/dashboard')) {
      selectedKeys.value = ['dashboard'];
    } else if (path.includes('/student/quizzes')) {
      selectedKeys.value = ['quizzes'];
    } else if (path.includes('/student/results')) {
      selectedKeys.value = ['results'];
    } else {
      selectedKeys.value = [];
    }
  },
  { immediate: true }
);

const handleLogout = () => {
  // Implement logout logic here
  console.log('User logged out');
  // Example: Clear user session/token and redirect to login
  // router.push('/auth/signin');
};
</script>

<style scoped>
.header {
  background-color: #fff;
  padding: 0 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  height: 64px; /* Standard Ant Design header height */
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

/* Override Ant Design default styles for a cleaner look */
:deep(.ant-menu-horizontal > .ant-menu-item::after) {
  bottom: 0px; /* Remove default bottom border animation */
}

:deep(.ant-menu-horizontal:not(.ant-menu-dark) > .ant-menu-item-selected::after) {
  border-bottom: 2px solid #1890ff; /* Ant Design primary color */
}

:deep(.ant-menu-horizontal:not(.ant-menu-dark) > .ant-menu-item:hover::after) {
  border-bottom: 2px solid #1890ff;
}
</style>