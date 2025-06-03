<template>
  <header class="navbar navbar-expand-lg sticky-top bg-body-tertiary shadow-sm p-0 dashboard-header">
    <div class="container-fluid d-flex justify-content-between align-items-center px-3" style="height: 64px;">
      <!-- Header Left -->
      <div class="d-flex flex-column justify-content-center">
        <nav aria-label="breadcrumb">
          <ol class="breadcrumb mb-0 small text-secondary">
            <li class="breadcrumb-item"><a href="#" class="text-secondary text-decoration-none">Pages</a></li>
            <li class="breadcrumb-item text-dark fw-semibold" aria-current="page">Dashboard</li>
          </ol>
        </nav>
        <h5 class="page-title mb-0 fw-semibold fs-6 text-dark">Dashboard</h5>
      </div>

      <!-- Header Right -->
      <div class="d-flex align-items-center gap-3">

        <a-dropdown :trigger="['click']" placement="bottomRight">
          <a
            class="btn btn-sm btn-link dropdown-toggle text-secondary text-decoration-none d-flex align-items-center p-2"
            href="#"
            @click.prevent
            aria-label="User actions"
          >
            <CircleUserRound :size="20"></CircleUserRound>
          </a>
          <template #overlay>
            <a-menu style="min-width: 150px;"> 
              <a-menu-item key="settings">
                <Settings :size="16" style="margin-right: 8px; vertical-align: middle;" />
                <span style="vertical-align: middle;">Settings</span>
              </a-menu-item>
              <a-menu-item key="logout">
                <LogOut :size="16" style="margin-right: 8px; vertical-align: middle;" />
                <span style="vertical-align: middle;">Logout</span>
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>

        <div class="dropdown">
          <a href="#" class="btn btn-sm btn-link text-secondary p-2 dropdown-toggle position-relative" id="notificationsDropdownMenu" data-bs-toggle="dropdown" aria-expanded="false" aria-label="Notifications">
            <Bell :size="18" />
            <span class="position-absolute top-0 start-75 translate-middle badge rounded-pill bg-danger p-1" style="font-size: 0.6em;">
              3<span class="visually-hidden">unread notifications</span>
            </span>
          </a>
        </div>

      </div>
    </div>

  </header>
</template>

<script setup>
import { ref } from 'vue';
import {
  Dropdown as ADropdown,
  Menu as AMenu,
  MenuItem as AMenuItem,
  Drawer as ADrawer,
} from 'ant-design-vue';
import {
  Search,
  CircleUserRound,
  Settings,
  LogOut,
  ChevronDown,
  Bell,
  Gift,
  CheckCircle,
  AlertTriangle,
} from 'lucide-vue-next';

const drawerVisible = ref(false);

const showDrawer = () => {
  drawerVisible.value = true;
};

const onCloseDrawer = () => {
  drawerVisible.value = false;
};


</script>

<style lang="scss" scoped>
</style>