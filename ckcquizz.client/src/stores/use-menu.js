import { defineStore } from 'pinia';
import { ref, computed, h } from 'vue';
import { useAuthStore } from './authStore';
import {
  LayoutDashboard, Layers, ClipboardCheck, Users, BookOpen, FileText, Bell, UserCog, House, ContactRound
} from 'lucide-vue-next';

const lucideIcon = (IconComponent) => {
  return () => h('span', { class: 'ant-menu-item-icon' }, [
    h(IconComponent, { size: 16 })
  ]);
};


const MENU_CONFIG = [
  {
    key: 'admin-home',
    icon: lucideIcon(House),
    label: 'Home',
    roles: ['Admin', 'Teacher'],
  },
  {
    key: 'admin-dashboard',
    icon: lucideIcon(LayoutDashboard),
    label: 'Dashboard',
    roles: ['Admin', 'Teacher'],
  },
  { type: 'divider', key: 'divider-1' },
  {
    type: 'group',
    key: 'group-account',
    label: 'Quản lý',
    children: [
      { key: 'admin-coursegroup', icon: lucideIcon(Layers), label: 'Nhóm học phần', roles: ['Admin', 'Teacher'] },
      { key: 'admin-question', icon: lucideIcon(ClipboardCheck), label: 'Câu hỏi', roles: ['Teacher'] },
      { key: 'admin-users', icon: lucideIcon(Users), label: 'Người dùng', roles: ['Admin'] },
      { key: 'admin-subject', icon: lucideIcon(BookOpen), label: 'Môn học', roles: ['Admin'] },
      { key: 'teacher-subject', icon: lucideIcon(BookOpen), label: 'Môn học', roles: ['Teacher'] },
      { key: 'admin-test', icon: lucideIcon(FileText), label: 'Đề kiểm tra', roles: ['Teacher'] },
      { key: 'admin-assignment', icon: lucideIcon(ContactRound), label: 'Phân công', roles: ['Admin'] },
      { key: 'admin-notification', icon: lucideIcon(Bell), label: 'Thông báo', roles: ['Admin', 'Teacher'] },
      { key: 'admin-rolemanagement', icon: lucideIcon(UserCog), label: 'Nhóm quyền', roles: ['Admin'] },


    ],
  },
];

export const useMenuStore = defineStore('menu', () => {
  const authStore = useAuthStore();

  const selectedKeys = ref([]);
  const openKeys = ref([]);

  const itemsToDisplay = computed(() => {
    if (!authStore.isAuthenticated) {
      return [];
    }

    const userRoles = authStore.userRoles;

    const filterByRole = (items) => {
      const result = [];
      for (const item of items) {
        if (item.type === 'group') {
          const visibleChildren = filterByRole(item.children);
          if (visibleChildren.length > 0) {
            result.push({ ...item, children: visibleChildren });
          }
        } else if (item.type === 'divider') {
          result.push(item);
        } else {
          if (item.roles && item.roles.some(role => userRoles.includes(role))) {
            result.push(item);
          }
        }
      }
      return result;
    };

    const tempFiltered = filterByRole(MENU_CONFIG);

    const finalMenu = [];
    for (let i = 0; i < tempFiltered.length; i++) {
      const current = tempFiltered[i];
      if (current.type === 'divider') {
        if (finalMenu.length > 0 && finalMenu[finalMenu.length - 1].type !== 'divider' && i < tempFiltered.length - 1) {
          let nextItemExists = false;
          for (let j = i + 1; j < tempFiltered.length; j++) {
            if (tempFiltered[j].type !== 'divider') {
              nextItemExists = true;
              break;
            }
          }
          if (nextItemExists) {
            finalMenu.push(current);
          }
        }
      } else {
        finalMenu.push(current);
      }
    }
    return finalMenu;
  });


  const updateMenuStateBasedOnRoute = (currentRouteName) => {
    if (!currentRouteName) {
      return;
    }
    const routeNameStr = currentRouteName.toString();
    selectedKeys.value = [routeNameStr];

    let parentKey = null;

    for (const item of MENU_CONFIG) {
      if (item.children && (item.type === 'group' || !item.type)) {
        if (item.children.some(child => child.key === routeNameStr)) {
          parentKey = item.key;
          break;
        }
      }
    }

    if (parentKey) {
      const isParentVisible = itemsToDisplay.value.some(item => item.key === parentKey && (item.type === 'group' || item.children));
      if (isParentVisible) {
        openKeys.value = [parentKey];
      } else {
        openKeys.value = [];
      }
    } else {
      openKeys.value = [];
    }
  };

  const setOpenKeys = (keys) => {
    if (Array.isArray(keys)) {
      openKeys.value = keys;
    }
  };

  const setSelectedKeys = (keys) => {
    if (Array.isArray(keys)) {
      selectedKeys.value = keys;
    }
  };

  return {
    selectedKeys,
    openKeys,
    itemsToDisplay,
    updateMenuStateBasedOnRoute,
    setOpenKeys,
    setSelectedKeys,
  };
});
