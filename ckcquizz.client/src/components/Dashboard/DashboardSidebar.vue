<template>
  <nav class="sidebar">
    <div class="sidebar-brand-container">
      <img src="../../assets/images/ckclogo.png" class="sidebar-logo">
      <span class="sidebar-title">CKC Quizz</span>
    </div>

    <a-menu v-model:selectedKeys="menuStore.selectedKeys" v-model:openKeys="menuStore.openKeys" mode="inline"
      :items="menuStore.itemsToDisplay" @click="handleMenuClick" class="sidebar-menu" />
  </nav>
</template>

<style lang="scss" scoped>
.sidebar {
  width: 260px;
  background-color: #ffffff;
  color: #344767;
  height: 100vh;
  display: flex;
  flex-direction: column;
  border-right: 1px solid #e8e8e8;
  box-shadow: 0 0 20px 0 rgba(0, 0, 0, .05);
}

.sidebar-brand-container {
  padding: 18px 24px;
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

.sidebar-logo {
  height: 80px;
}

.sidebar-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: #1f2937;
}

.sidebar-menu {
  border-right: 0;
  background-color: transparent;
  flex-grow: 1;
  overflow-y: auto;
}


:deep(.ant-menu-item),
:deep(.ant-menu-submenu-title) {
  margin: 4px 12px !important;
  padding: 0 12px !important;
  width: calc(100% - 24px) !important;
  height: 40px !important;
  line-height: 40px !important;
  border-radius: 0.375rem !important;
  color: #67748e;
  display: flex;
  align-items: center;

  .ant-menu-title-content {
    margin-left: 10px;
  }
}

:deep(.ant-menu-item .ant-menu-item-icon),
:deep(.ant-menu-submenu-title .ant-menu-item-icon) {
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 32px;
  height: 32px;
  background-color: #fff;
  border-radius: 0.25rem;
  box-shadow: 0 2px 4px -1px rgba(0, 0, 0, .07), 0 2px 2px -1px rgba(0, 0, 0, .04);
  color: #344767;
  font-size: 0.875rem;
}

:deep(.ant-menu-item:not(.ant-menu-item-selected):not(.ant-menu-submenu-selected):hover),
:deep(.ant-menu-submenu-title:not(.ant-menu-item-selected):not(.ant-menu-submenu-selected):hover) {
  background-color: #f0f2f5 !important;
  color: #344767 !important;
}

// :deep(.ant-menu-item:hover .ant-menu-item-icon),
// :deep(.ant-menu-submenu-title:hover .ant-menu-item-icon) {}

:deep(.ant-menu-item-selected),
:deep(.ant-menu-item-selected.ant-menu-submenu-title) {
  background-color: white !important;
  color: black !important;
  font-weight: bold;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, .1), 0 2px 4px -1px rgba(0, 0, 0, .06) !important;
}

:deep(.ant-menu-item-selected .ant-menu-item-icon),
:deep(.ant-menu-item-selected.ant-menu-submenu-title .ant-menu-item-icon) {
  background-color: #ffffff !important;
  color: #1A73E8 !important;
}


:deep(.ant-menu-submenu-arrow) {
  color: #67748e;
}

:deep(.ant-menu-submenu:hover > .ant-menu-submenu-title > .ant-menu-submenu-arrow),
:deep(.ant-menu-submenu-open > .ant-menu-submenu-title > .ant-menu-submenu-arrow) {
  color: #344767;
}

:deep(.ant-menu-item-selected.ant-menu-submenu-title > .ant-menu-submenu-arrow) {
  color: #ffffff !important;
}


:deep(.ant-menu-item-divider) {
  margin: 16px 0 !important;
  border-top-color: #e9ecef !important; // Màu divider
}

:deep(.ant-menu-item-group-title) {
  padding: 8px 24px !important;
  font-size: 0.75rem !important;
  font-weight: 600 !important;
  color: #67748e !important;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}


:deep(.ant-menu-inline .ant-menu-item) {
  padding-left: 24px !important;
}

:deep(.ant-menu-sub.ant-menu-inline > .ant-menu-item) {
  padding-left: 40px !important;
}

:deep(.ant-menu-sub.ant-menu-inline > .ant-menu-sub > .ant-menu-item) {
  padding-left: 56px !important;
}
</style>

<script setup>
import { onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useMenuStore } from '@/stores/use-menu';


const route = useRoute();
const router = useRouter();
const menuStore = useMenuStore();

onMounted(() => {
  if (route.name) {
    menuStore.updateMenuStateBasedOnRoute(route.name);
  }
});

watch(() => route.name, (newRouteName) => {
  if (newRouteName) {
    menuStore.updateMenuStateBasedOnRoute(newRouteName);
  }
}, { immediate: true });

const handleMenuClick = ({ key, keyPath }) => {
  const keyStr = key.toString();


  const findClickedItemInDisplayedMenu = (items, targetKey) => {
    for (const item of items) {
      if (item.key === targetKey) return item;
      if (item.children) {
        const found = findClickedItemInDisplayedMenu(item.children, targetKey);
        if (found) return found;
      }
    }
    return null;
  };

  const clickedItem = findClickedItemInDisplayedMenu(menuStore.itemsToDisplay, keyStr);


  if (clickedItem && (!clickedItem.children || clickedItem.children.length === 0) && clickedItem.type !== 'group') {
    if (router.hasRoute(keyStr)) {
      router.push({ name: keyStr });
    } else {
      console.warn(`Route with name "${keyStr}" does not exist.`);
    }
  }

};
</script>