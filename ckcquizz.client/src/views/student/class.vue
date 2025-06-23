<template>
  <a-layout class="full-height-layout">
    <a-layout-sider v-model:collapsed="collapsed" collapsible theme="light" width="250">
      <a-menu :selectedKeys="selectedKeys" v-model:openKeys="openKeys" mode="inline" @select="handleMenuSelect">
        <a-menu-item key="home">
          <template #icon>
            <LucideHome size="20" />
          </template>
          Danh sách lớp
        </a-menu-item>

        <a-sub-menu key="enrolled">
          <template #icon>
            <GraduationCap size="20" />
          </template>
          <template #title>
            <span class="d-flex justify-content-between align-items-center w-100">
              Đã tham gia
              <a-tooltip title="Tham gia lớp học mới">
                <a-button type="text" shape="circle" @click.stop="showJoinDialog = true">
                  <template #icon>
                    <Plus size="16" />
                  </template>
                </a-button>
              </a-tooltip>
            </span>
          </template>
          <a-spin v-if="menuLoading" class="p-4 d-flex justify-content-center" />
          <a-menu-item v-for="cls in allClasses" :key="cls.malop.toString()">
            <template #icon>
              <LucideFolder size="16" />
            </template>
            {{ cls.tenlop }}
          </a-menu-item>
        </a-sub-menu>

        <a-menu-item key="settings">
          <template #icon>
            <Settings size="20" />
          </template>
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
      </a-layout-content>
    </a-layout>

    <a-modal v-model:open="showJoinDialog" title="Tham gia lớp học" @ok="joinClass" :confirm-loading="joinLoading"
      ok-text="Tham gia" cancel-text="Hủy">
      <p>Nhập mã lớp học do giáo viên cung cấp để tham gia.</p>
      <a-input v-model:value="inviteCode" placeholder="Mã lớp học" @pressEnter="joinClass" />
    </a-modal>
  </a-layout>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import apiClient from '@/services/axiosServer';
import { message } from 'ant-design-vue'
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

const currentClassId = computed(() => route.params.id);

// Initialize selectedKeys based on current route on setup
if (route.params.id) {
  selectedKeys.value = [route.params.id.toString()];
} else if (route.name === 'student-class-list') {
  selectedKeys.value = ['home'];
} else if (route.name === 'student-profile') {
  selectedKeys.value = ['settings'];
}

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


const joinClass = async () => {
  if (!inviteCode.value.trim()) {
    message.error('Vui lòng nhập mã mời.');
    return;
  }
  joinLoading.value = true;
  try {
    await apiClient.post('/Lop/join-by-code', { inviteCode: inviteCode.value });
    const successMessage = res.data?.message || 'Tham gia lớp học thành công! Hãy chờ giảng viên duyệt để vào lớp';
    message.success(successMessage);

    showJoinDialog.value = false;
    inviteCode.value = '';
    await fetchAllClassesForMenu();
  } catch (err) {
    let errorMessage = 'Không thể tham gia lớp học.';

    if (typeof err.response?.data === 'string') {
      errorMessage = err.response.data;
    } else if (err.response?.data?.message) {
      errorMessage = err.response.data.message;
    }

    message.error(errorMessage);
  } finally {
    joinLoading.value = false;
  }
};

watch(currentClassId, (newId) => {
  if (newId) {
    selectedKeys.value = [newId.toString()];
  }
});

watch(() => route.name, (newName) => {
  if (newName === 'student-class-list') {
    selectedKeys.value = ['home'];
  } else if (newName === 'student-profile') {
    selectedKeys.value = ['settings'];
  }
});

const handleMenuSelect = ({ key }) => {
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

const initializeLayoutData = async () => {
  loading.value = true;
  await fetchAllClassesForMenu();
  loading.value = false;
};

onMounted(initializeLayoutData);
</script>

<style scoped>
.full-height-layout {
  min-height: 100vh;
}

:deep(.ant-layout-sider-children) {
  display: flex;
  flex-direction: column;
}

:deep(.ant-menu) {
  flex-grow: 1;
  overflow-y: auto;
  border-inline-end: none !important;
}

/* Responsive adjustments for smaller screens */
@media (max-width: 768px) {
  .ant-layout-sider {
    position: fixed;
    height: 100vh;
    z-index: 1000;
  }

  .ant-layout-content {
    margin-left: 0 !important;
    /* Adjust content margin when sidebar is collapsed */
  }
}
</style>