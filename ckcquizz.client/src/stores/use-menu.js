// src/stores/menuStore.js
import { defineStore } from 'pinia';
// useRoute không nên được gọi ở top-level của store theo cách này trong Options Store.
// Nó sẽ được truyền vào actions nếu cần, hoặc component sẽ truyền route.name.

// Định nghĩa cấu trúc menu tĩnh (giữ nguyên)
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
  // Ví dụ nếu bạn có submenu thực sự (không phải group) để test openKeys
  // {
  //   key: 'sub1', // Key của submenu cha
  //   label: 'Sub Menu Thực Sự',
  //   children: [
  //     { key: 'admin-sub-item1', label: 'Sub Item 1' },
  //     { key: 'admin-sub-item2', label: 'Sub Item 2' },
  //   ]
  // },
  { key: 'logout', label: 'Logout' },
];

export const useMenuStore = defineStore('menu', {
  state: () => ({
    selectedKeys: [], 
    openKeys: [],    
  }),

  actions: {
    // Action này sẽ cập nhật selectedKeys và openKeys dựa trên route name
    updateMenuStateBasedOnRoute(currentRouteName) {
      if (!currentRouteName) {
        // Nếu không có route name, có thể reset state hoặc giữ nguyên tùy logic
        // this.selectedKeys = [];
        // this.openKeys = [];
        return;
      }

      const routeNameStr = currentRouteName.toString();
      this.selectedKeys = [routeNameStr]; // `this` ở đây trỏ đến state của store

      let parentKey = null;
      for (const item of staticMenuItems) { // Sử dụng staticMenuItems đã định nghĩa ở ngoài
        // Chỉ tìm parentKey nếu item đó là submenu thực sự (có children và không phải type: 'group')
        if (item.children && !item.type) {
          if (item.children.some(child => child.key === routeNameStr)) {
            parentKey = item.key;
            break;
          }
        }
      }

      if (parentKey) {
        // Nếu muốn chỉ một submenu cha được mở, gán trực tiếp
        this.openKeys = [parentKey];
        // Nếu muốn cho phép nhiều submenu được mở và giữ lại những cái đã mở:
        // if (!this.openKeys.includes(parentKey)) {
        //   this.openKeys.push(parentKey);
        // }
      } else {
        // Nếu item được chọn không nằm trong submenu có thể mở/đóng (ví dụ item cấp 1)
        // bạn có thể muốn đóng các submenu khác
        // this.openKeys = []; // Bỏ comment nếu muốn đóng tất cả submenu khác khi chọn item cấp 1
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