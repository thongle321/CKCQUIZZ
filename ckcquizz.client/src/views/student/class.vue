<template>
  <a-layout class="full-height-layout">
    <a-layout-sider v-model:collapsed="collapsed" collapsible theme="light" width="250">
      <a-menu :selectedKeys="selectedKeys" v-model:openKeys="openKeys" mode="inline" @select="handleMenuSelect">
        <a-menu-item key="home">
          <template #icon><LucideHome size="20" /></template>
          Danh sách lớp
        </a-menu-item>

        <a-sub-menu key="enrolled">
          <template #icon><GraduationCap size="20" /></template>
          <template #title>
            <span class="d-flex justify-content-between align-items-center w-100">
              Đã tham gia
              <a-tooltip title="Tham gia lớp học mới">
                <a-button type="text" shape="circle" @click.stop="showJoinDialog = true">
                  <template #icon><Plus size="16" /></template>
                </a-button>
              </a-tooltip>
            </span>
          </template>
          <a-spin v-if="menuLoading" class="p-4 d-flex justify-content-center" />
          <a-menu-item v-for="cls in allClasses" :key="cls.malop.toString()">
            <template #icon><LucideFolder size="16" /></template>
            {{ cls.tenlop }}
          </a-menu-item>
        </a-sub-menu>

        <a-menu-item key="settings">
          <template #icon><Settings size="20" /></template>
          Cài đặt
        </a-menu-item>
      </a-menu>
    </a-layout-sider>

    <a-layout>
      <a-layout-content style="padding: 24px;">
        <router-view v-if="!loading" />
        <div v-if="loading" class="d-flex justify-content-center align-items-center h-100">
          <a-spin size="large" />
        </div>
        <!-- <a-empty v-else-if="!currentClass" description="Không tìm thấy thông tin lớp học." />
        <div v-else>
          <a-breadcrumb style="margin-bottom: 16px;">
            <a-breadcrumb-item><router-link :to="{ name: 'student-class-list' }">Lớp học</router-link></a-breadcrumb-item>
            <a-breadcrumb-item>{{ currentClass.tenlop }}</a-breadcrumb-item>
          </a-breadcrumb>

          <a-card class="class-banner mb-4" :bordered="false" style="background: linear-gradient(135deg, #6b48ff, #00ddeb); color: white; border-radius: 12px;">
            <div class="row align-items-center">
              <div class="col-md-8">
                <h1 style="font-size: 2.5rem; font-weight: 600; color: white;">{{ currentClass.tenlop }}</h1>
                <p v-if="currentClass.moTa" style="font-size: 1rem;">{{ currentClass.moTa }}</p>
              </div>
              <div class="col-md-4 text-end">
                <img src="https://gw.alipayobjects.com/zos/rmsportal/gLaIAoVWTtLbBWZNYEMg.png" alt="Illustration" style="max-height: 150px;" />
              </div>
            </div>
          </a-card>

          <a-tabs v-model:activeKey="activeTabKey" type="card">
            <a-tab-pane key="1" tab="Bảng tin">...</a-tab-pane>
            <a-tab-pane key="2" tab="Bài tập trên lớp">...</a-tab-pane>
          </a-tabs>
        </div> -->
      </a-layout-content>
    </a-layout>

    <a-modal v-model:open="showJoinDialog" title="Tham gia lớp học" @ok="joinClass" :confirm-loading="joinLoading" ok-text="Tham gia" cancel-text="Hủy">
      <p>Nhập mã lớp học do giáo viên cung cấp để tham gia.</p>
      <a-input v-model:value="inviteCode" placeholder="Mã lớp học" @pressEnter="joinClass" />
      <!-- FIX: Đổi tên biến `message` thành `modalMessage` để tránh xung đột -->
      <a-alert v-if="modalMessage" :message="modalMessage" :type="messageType" show-icon class="mt-3" />
    </a-modal>
  </a-layout>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import { Plus, GraduationCap, LucideHome, LucideFolder, Settings } from 'lucide-vue-next';

const route = useRoute();
const router = useRouter();

const collapsed = ref(false);
const loading = ref(true);
const menuLoading = ref(true);
const allClasses = ref([]);
const selectedKeys = ref([]);
const openKeys = ref(['enrolled']);
const showJoinDialog = ref(false);
const inviteCode = ref('');
const joinLoading = ref(false);
const modalMessage = ref('');
const messageType = ref('error');

const currentClassId = computed(() => route.params.id);

const fetchAllClassesForMenu = async () => {
  menuLoading.value = true;
  try {
    const response = await apiClient.get('/Lop?hienthi=true');
    allClasses.value = response.data;
  } catch (err) {
    console.error("Lỗi tải danh sách lớp cho menu:", err);
  } finally {
    menuLoading.value = false;
  }
};

const fetchCurrentClassDetail = async () => {
    loading.value = true;
    if (allClasses.value.length === 0) {
        await fetchAllClassesForMenu();
    }
    loading.value = false;
};

const joinClass = async () => {
  if (!inviteCode.value.trim()) {
    modalMessage.value = 'Vui lòng nhập mã mời.';
    return;
  }
  joinLoading.value = true;
  modalMessage.value = '';
  try {
    await apiClient.post('/Lop/join-by-code', { inviteCode: inviteCode.value });
    message.success('Tham gia lớp học thành công!');
    showJoinDialog.value = false;
    inviteCode.value = '';
    await fetchAllClassesForMenu();
  } catch (err) {
    const errorMessage = err.response?.data?.message || 'Không thể tham gia lớp học.';
    message.error(errorMessage);
    modalMessage.value = errorMessage;
  } finally {
    joinLoading.value = false;
  }
};

watch(currentClassId, (newId) => {
  if (newId) {
    selectedKeys.value = [newId.toString()];
    fetchCurrentClassDetail();
  }
}, { immediate: true });

const handleMenuSelect = ({ key }) => {
  selectedKeys.value = [key]; 
  switch (key) {
    case 'home':
      router.push({ name: 'student-class-list' });
      break;
    case 'settings':
      router.push({ name: 'student-profile' });
      break;
    default:
      router.push({ name: 'student-classdetail', params: { id: key } });
      break;
  }
};

// FIX: Gọi đúng hàm khi component được mount
onMounted(fetchCurrentClassDetail);
</script>

<style scoped>
.full-height-layout { min-height: 100vh; }
:deep(.ant-layout-sider-children) { display: flex; flex-direction: column; }
:deep(.ant-menu) { flex-grow: 1; overflow: auto; border-inline-end: none !important; }
.class-banner, .ant-card { border-radius: 12px; }
</style>