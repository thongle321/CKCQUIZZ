import { defineStore } from 'pinia';

const staticMenuItems = [
  {
    key: 'admin-dashboard',
    label: 'Dashboard',
  },
  { type: 'divider', key: 'divider-1' },
  {
    type: 'group',
    key: 'group-account',
    label: 'Quản lý',
    children: [
      { key: 'admin-coursegroup', label: 'Nhóm học phần' },
      { key: 'admin-question', label: 'Câu hỏi' },
      { key: 'admin-users', label: 'Người dùng' },
      { key: 'admin-subject', label: 'Môn học' },
      { key: 'admin-test', label: 'Đề kiểm tra' },
      { key: 'admin-notification', label: 'Thông báo' },
    ],
  },
];

export const useMenuStore = defineStore('menu', {
  state: () => ({
    selectedKeys: [], 
    openKeys: [],    
  }),

  actions: {
    updateMenuStateBasedOnRoute(currentRouteName) {
      if (!currentRouteName) {

        return;
      }

      const routeNameStr = currentRouteName.toString();
      this.selectedKeys = [routeNameStr]; 

      let parentKey = null;
      for (const item of staticMenuItems) { 
        if (item.children && !item.type) {
          if (item.children.some(child => child.key === routeNameStr)) {
            parentKey = item.key;
            break;
          }
        }
      }

      if (parentKey) {
        this.openKeys = [parentKey];

      } else {
1
      }
    },

    setOpenKeys(keys) {
      if (Array.isArray(keys)) {
        this.openKeys = keys;
      }
    },

    setSelectedKeys(keys) {
      if (Array.isArray(keys)) {
        this.selectedKeys = keys;
      }
    },
  },
});