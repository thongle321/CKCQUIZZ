<template>
  <a-layout-header :class="['dashboard-header', { 'navbar-fixed': layoutStore.isNavbarFixed }]">
    <div class="header-content">
      <div class="header-left">
        <a-breadcrumb class="breadcrumb">
          <a-breadcrumb-item>
            <router-link :to="{ name: 'admin-dashboard' }">Pages</router-link>
          </a-breadcrumb-item>
          <a-breadcrumb-item v-if="currentRouteTitle">{{ currentRouteTitle }}</a-breadcrumb-item>
        </a-breadcrumb>
        <h5 class="page-title">{{ currentRouteTitle || 'Dashboard' }}</h5>
      </div>

      <div class="header-right">
        <a-input-group compact class="search-input-group">
          <a-input placeholder="Type here..." class="search-input">
            <template #prefix>
              <font-awesome-icon :icon="['fas', 'search']" />
            </template>
          </a-input>
        </a-input-group>

        <a-button type="text" class="header-icon-button" @click="goToSignIn" v-if="!layoutStore.isUserLoggedIn">
          <font-awesome-icon :icon="['fas', 'user-circle']" class="icon-margin" />
          Sign In
        </a-button>

        <!-- User Dropdown -->
        <a-dropdown :trigger="['click']" v-if="layoutStore.isUserLoggedIn">
          <a class="ant-dropdown-link header-icon-button user-profile-trigger" @click.prevent>
            <a-avatar :src="layoutStore.userAvatar" size="small" v-if="layoutStore.userAvatar">
              <template #icon><font-awesome-icon :icon="['fas', 'user']" /></template>
            </a-avatar>
            <font-awesome-icon :icon="['fas', 'user-circle']" v-else />
            <span class="username-display">{{ layoutStore.userName }}</span>
          </a>
          <template #overlay>
            <a-menu @click="handleUserMenuClick">
              <a-menu-item key="profile">
                <font-awesome-icon :icon="['fas', 'user']" class="icon-margin" /> Profile
              </a-menu-item>
              <a-menu-item key="settings-account">
                <font-awesome-icon :icon="['fas', 'cog']" class="icon-margin" /> Settings
              </a-menu-item>
              <a-menu-divider />
              <a-menu-item key="logout">
                <font-awesome-icon :icon="['fas', 'sign-out-alt']" class="icon-margin" /> Logout
              </a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>

        <!-- Sidenav Toggle Button -->
        <a-button type="text" class="header-icon-button d-lg-none" @click="layoutStore.toggleSidenavCollapsed()">
           <!-- Chỉ hiển thị trên màn hình nhỏ hơn lg (Bootstrap breakpoint) -->
          <font-awesome-icon :icon="['fas', 'bars']" />
        </a-button>

        <!-- Configurator Toggle Button -->
        <a-button type="text" class="header-icon-button" @click="layoutStore.toggleConfigurator()">
           <font-awesome-icon :icon="['fas', 'cog']" />
        </a-button>

        <!-- Notifications Dropdown -->
        <a-dropdown :trigger="['click']">
          <a-badge :count="layoutStore.unreadNotificationCount" :overflow-count="9">
            <a class="ant-dropdown-link header-icon-button" @click.prevent>
              <font-awesome-icon :icon="['fas', 'bell']" />
            </a>
          </a-badge>
          <template #overlay>
            <a-list
              class="header-notifications-list"
              item-layout="horizontal"
              :data-source="layoutStore.notificationsData"
              style="width: 320px;"
            >
              <template #header>
                <div class="notification-header" v-if="layoutStore.notificationsData.length > 0">
                  You have {{ layoutStore.unreadNotificationCount }} new notifications
                </div>
              </template>
              <template #renderItem="{ item }">
                <a-list-item @click="handleNotificationClick(item)" :class="{'notification-unread': !item.read}">
                  <a-list-item-meta>
                    <template #avatar>
                       <font-awesome-icon :icon="item.icon" class="notification-icon" v-if="item.icon"/>
                    </template>
                     <template #title>
                      <a href="#">{{ item.title }}</a>
                    </template>
                    <template #description>
                      {{ item.time }}
                    </template>
                  </a-list-item-meta>
                </a-list-item>
              </template>
              <template #footer v-if="layoutStore.notificationsData.length > 0">
                <div class="notification-footer">
                  <a-button type="link" block>View all notifications</a-button>
                </div>
              </template>
               <template #empty>
                  <div style="padding: 20px; text-align: center;">
                    <font-awesome-icon :icon="['fas', 'comment-slash']" style="font-size: 24px; margin-bottom: 8px; color: #ccc;" />
                    <p>No new notifications</p>
                  </div>
              </template>
            </a-list>
          </template>
        </a-dropdown>

      </div>
    </div>
    <!-- Bạn có thể tạo một component ConfiguratorDrawer riêng và bind visible với layoutStore.showConfigurator -->
    <!-- <ConfiguratorDrawer v-model:visible="layoutStore.showConfigurator" /> -->
  </a-layout-header>
</template>

<script setup>
import { computed } from 'vue'; 
import { useRoute, useRouter } from 'vue-router';
import { useLayoutStore } from '@/stores/admin-header'; 

const layoutStore = useLayoutStore();
const route = useRoute();
const router = useRouter();

const currentRouteTitle = computed(() => {
  const matched = route.matched.slice().reverse();
  const nearestWithTitle = matched.find(r => r.meta && r.meta.title);
  return nearestWithTitle ? nearestWithTitle.meta.title : (route.meta.title || route.name);
});

const goToSignIn = () => {
  router.push({ name: 'SignIn' }); // Đảm bảo route 'SignIn' tồn tại
};

const handleUserMenuClick = async (menuInfo) => {
  if (menuInfo.key === 'logout') {
    await layoutStore.logout(); // Gọi action logout từ store
    router.push({ name: 'SignIn' }); // Điều hướng sau khi logout
  } else if (menuInfo.key === 'profile') {
    router.push({ name: 'UserProfile' }); // Đảm bảo route 'UserProfile' tồn tại
  } else if (menuInfo.key === 'settings-account') {
    router.push({ name: 'AccountSettings' }); 
  }
};

const handleNotificationClick = (notification) => {
  console.log('Notification clicked:', notification);
  layoutStore.markNotificationAsRead(notification.id);

};


</script>

<style lang="scss" scoped>
.dashboard-header {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: saturate(200%) blur(30px);
  padding: 0 16px; 
  box-shadow: 0 2px 12px 0 rgba(0,0,0,.05);
  position: sticky;
  top: 0;
  z-index: 100;
  transition: box-shadow .25s ease-in-out, background-color .25s ease-in-out;
  height: 64px;
  display: flex;
  align-items: center;

  @media (min-width: 992px) { // lg breakpoint
    padding: 0 24px;
  }
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.header-left {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;

  .breadcrumb {
    margin-bottom: 0px;
    font-size: 0.875rem;
    :deep(.ant-breadcrumb-link a),
    :deep(.ant-breadcrumb-separator) {
      color: #67748e;
    }
     :deep(.ant-breadcrumb-link > span:not(.ant-breadcrumb-separator)) {
        color: #344767;
        font-weight: 600;
    }
  }

  .page-title {
    font-size: 1rem;
    font-weight: 600;
    color: #344767;
    margin: 0;
    line-height: 1.5;
  }
}

.header-right {
  display: flex;
  align-items: center;
  gap: 8px; /* Giảm gap cho màn hình nhỏ */
   @media (min-width: 768px) { // md breakpoint
    gap: 12px;
  }


  .search-input-group {
    width: 150px; /* Thu nhỏ search bar */
    @media (min-width: 768px) {
        width: 200px;
    }
    .search-input {
      border-radius: 0.375rem;
      &:focus, &:hover {
        border-color: #49a3f1;
        box-shadow: 0 0 0 2px rgba(24, 144, 255, 0.2);
      }
    }
    .ant-input-prefix .svg-inline--fa {
        color: #adb5bd;
    }
  }

  .header-icon-button {
    color: #67748e;
    font-size: 0.875rem;
    padding: 6px 8px;
    border: none;
    background: transparent;
    display: flex;
    align-items: center;

    .svg-inline--fa {
        font-size: 1rem;
    }

    .icon-margin {
        margin-right: 6px;
    }

    &:hover {
      color: #344767;
      background-color: rgba(0,0,0,0.04);
    }
  }

  .user-profile-trigger {
    .username-display {
        margin-left: 8px;
        font-weight: 500;
        display: none; // Ẩn tên trên màn hình nhỏ
        @media (min-width: 768px) { // Hiển thị tên trên màn hình md trở lên
            display: inline;
        }
    }
  }
}
.d-lg-none { // Bootstrap class: display: none trên lg trở lên
    @media (min-width: 992px) {
        display: none !important;
    }
}


.header-notifications-list {
  .notification-header {
    padding: 12px 16px;
    font-weight: 600;
    border-bottom: 1px solid #f0f0f0;
  }
  .notification-unread {
    background-color: #e6f7ff; // Màu nền cho thông báo chưa đọc
  }
  .ant-list-item {
    padding: 10px 16px;
    cursor: pointer;
    &:hover {
        background-color: #f0f2f5;
    }
  }
  .notification-icon {
    font-size: 1.1rem; // Giảm nhẹ size icon
    // margin-right: 8px; // ant-list-item-meta-avatar có margin rồi
    color: #1890ff;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    background-color: #e6f7ff;
    border-radius: 50%;
  }
  :deep(.ant-list-item-meta-title a) {
    font-size: 0.875rem;
    color: #344767;
    font-weight: 500;
    margin-bottom: 2px;
  }
  :deep(.ant-list-item-meta-description) {
    font-size: 0.75rem;
    color: #67748e;
  }
  .notification-footer {
    text-align: center;
    padding: 0px; // Nút link đã có padding
    border-top: 1px solid #f0f0f0;
    .ant-btn-link {
        color: #1890ff;
        font-weight: 500;
        width: 100%;
        height: 40px;
        &:hover {
            background-color: #f0f2f5;
        }
    }
  }
}
</style>