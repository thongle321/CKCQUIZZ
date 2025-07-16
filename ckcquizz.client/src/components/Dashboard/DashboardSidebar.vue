<template>
  <div class="sidebar-content">
    <div class="sidebar-brand-container">
      <img src="@/assets/images/ckclogo.png" class="sidebar-logo" />
      <transition name="fade">
        <span class="sidebar-title" v-if="!collapsed">CKC Quizz</span>
      </transition>
    </div>
    <a-menu v-model:selectedKeys="menuStore.selectedKeys" v-model:openKeys="menuStore.openKeys" mode="inline"
      :items="menuStore.itemsToDisplay" @click="handleMenuClick" class="sidebar-menu" />
  </div>
</template>

<script setup>
import { inject } from 'vue'
import { useRouter } from 'vue-router'
import { useMenuStore } from '@/stores/use-menu'

const router = useRouter()
const menuStore = useMenuStore()

const collapsed = inject('collapsed', false)

const handleMenuClick = ({ key }) => {
  if (router.hasRoute(key)) router.push({ name: key })
}
</script>

<style scoped>
.sidebar-content {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.sidebar-brand-container {
  display: flex;
  align-items: center;
  padding: 0 24px 16px;
  gap: 10px; 
  border-bottom: 1px solid #D1D8D1; 
}

.sidebar-logo {
  height: 50px; 
  transition: all 0.3s ease;
}

.sidebar-title {
  font-size: 1.35rem;
  font-weight: 600; 
  white-space: nowrap;
}

.sidebar-menu {
  flex-grow: 1;
  overflow-y: auto;
  border-right: none;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
