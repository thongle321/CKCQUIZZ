// src/stores/layoutStore.js
import { defineStore } from 'pinia';
import { ref } from 'vue';

export const useLayoutStore = defineStore('layout', {
  state: () => ({
    isNavbarFixed: false, // Header có cố định khi cuộn không
    isUserLoggedIn: true, // Trạng thái đăng nhập (true: đã đăng nhập, false: chưa)
    userName: 'Alex Thompson', // Tên người dùng (ví dụ)
    userAvatar: null, // URL avatar (ví dụ: '/path/to/avatar.jpg') hoặc null
    notificationCount: 5,
    notificationsData: [
      { id: 1, title: 'New message from Laur', time: '13 minutes ago', icon: ['fas', 'envelope'], read: false },
      { id: 2, title: 'New album by Travis Scott', time: '1 day ago', icon: ['fas', 'compact-disc'], read: true },
      { id: 3, title: 'Payment successfully completed', time: '2 days ago', icon: ['fas', 'credit-card'], read: false },
    ],
    showConfigurator: false, // Trạng thái hiển thị của configurator
    isSidenavCollapsed: false, // Trạng thái của sidebar (thu gọn/mở rộng)
  }),

  getters: {
    unreadNotificationCount: (state) => {
      return state.notificationsData.filter(n => !n.read).length;
    },
  },

  actions: {
    toggleNavbarFixed() {
      this.isNavbarFixed = !this.isNavbarFixed;
    },
    setUserLoggedIn(status, userData = {}) {
      this.isUserLoggedIn = status;
      if (status) {
        this.userName = userData.name || 'User';
        this.userAvatar = userData.avatar || null;
      } else {
        this.userName = '';
        this.userAvatar = null;
      }
    },
    setNotifications(notifications) {
      this.notificationsData = notifications;
      this.notificationCount = notifications.length; // Hoặc tính toán dựa trên unread
    },
    addNotification(notification) {
      this.notificationsData.unshift(notification); // Thêm vào đầu danh sách
      this.notificationCount++;
    },
    markNotificationAsRead(notificationId) {
      const notification = this.notificationsData.find(n => n.id === notificationId);
      if (notification && !notification.read) {
        notification.read = true;
        // Cập nhật lại unreadNotificationCount nếu cần (getter sẽ tự làm)
      }
    },
    toggleConfigurator() {
      this.showConfigurator = !this.showConfigurator;
    },
    toggleSidenavCollapsed() {
      this.isSidenavCollapsed = !this.isSidenavCollapsed;
    },
    // Action cho logout
    async logout() {
      console.log('Logging out from store...');
      // Thực hiện gọi API logout ở đây nếu cần
      // Sau đó cập nhật trạng thái
      this.setUserLoggedIn(false);
      this.notificationsData = [];
      this.notificationCount = 0;
      // Không điều hướng từ store, component sẽ xử lý điều hướng
    }
  },
});