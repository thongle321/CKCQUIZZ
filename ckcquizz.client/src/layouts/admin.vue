<template>
  <a-layout class="admin-layout">
    <a-layout-sider
      class="sidebar"
      breakpoint="md"
      collapsible
      :collapsed="collapsed"
      @collapse="collapsed = $event"
      :width="260"
      :collapsed-width="80"
      theme="light"
    >
      <DashboardSidebar />
    </a-layout-sider>

    <a-layout class="site-layout">
      <DashboardHeader @toggleSidebar="collapsed = !collapsed" />
      <a-layout-content class="page-content-area">
        <router-view />
      </a-layout-content>
      <DashboardFooter />
    </a-layout>
  </a-layout>
</template>

<script setup>
import { ref } from 'vue'
  import DashboardHeader from '../components/Dashboard/DashboardHeader.vue';
  import DashboardSidebar from '../components/Dashboard/DashboardSidebar.vue';
  import DashboardFooter from '../components/Dashboard/DashboardFooter.vue';

const collapsed = ref(false)
</script>

<style scoped>
.admin-layout {
  min-height: 100vh;
}

.sidebar {
  position: fixed;
  height: 100vh;
  left: 0;
  top: 0;
  z-index: 1000;
  overflow: auto;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
}

.site-layout {
  margin-left: 260px;
  transition: all 0.2s;
}

:deep(.ant-layout-sider-collapsed) + .site-layout {
  margin-left: 80px;
}

.page-content-area {
  padding: 24px;
  min-height: 100vh;
  background: #f5f7fa;
}
</style>
