
import { defineStore } from 'pinia'
import apiClient from '@/services/axiosServer'
import thongBaoConnection, { startConnection as startThongBaoConnection } from '@/services/signalrThongBaoService.js';
import deThiConnection, { startConnection as startDeThiConnection } from '@/services/signalrDeThiService.js';

export const useAuthStore = defineStore('auth', {
  state: () => {
    const initialRememberMe = localStorage.getItem('rememberMe') === 'true';
    const initialStorage = initialRememberMe ? localStorage : sessionStorage;

    return {
      userId: initialStorage.getItem('userId') || null,
      fullName: initialStorage.getItem('fullName') || null,
      userEmail: initialStorage.getItem('userEmail') || null,
      userRoles: JSON.parse(initialStorage.getItem('userRoles') || '[]'),
      refreshToken: initialStorage.getItem('refreshToken') || null,
      rememberMe: initialRememberMe,
      accessToken: initialStorage.getItem('accessToken') || null,
    }
  },

  getters: {
    isAuthenticated(state) {
      return !!state.userId;
    },
  },

  actions: {
    setUser(userData, shouldRemember) {
      this.userId = userData.id;
      this.fullName = userData.fullname;
      this.userEmail = userData.email;
      this.userRoles = Array.isArray(userData.roles) ? userData.roles : [];
      this.refreshToken = userData.token.refreshToken;
      this.rememberMe = shouldRemember;
      this.accessToken = userData.token.accessToken;

      const currentStorage = shouldRemember ? localStorage : sessionStorage;
      const otherStorage = shouldRemember ? sessionStorage : localStorage;
      otherStorage.clear();

      currentStorage.setItem('userId', this.userId);
      currentStorage.setItem('fullName', this.fullName);
      currentStorage.setItem('userEmail', this.userEmail);
      currentStorage.setItem('userRoles', JSON.stringify(this.userRoles));
      currentStorage.setItem('accessToken', userData.token.accessToken);
      currentStorage.setItem('refreshToken', this.refreshToken);
      currentStorage.setItem('rememberMe', String(shouldRemember));

      startThongBaoConnection();
      startDeThiConnection();
    },

    async logout() {
      try {
        if (thongBaoConnection.state === 'Connected') {
          await thongBaoConnection.stop();
        }
        if (deThiConnection.state === 'Connected') {
          await deThiConnection.stop();
        }
        await apiClient.post('/auth/logout');
      } catch (error) {
      }

      this.userId = null;
      this.fullName = null;
      this.userEmail = null;
      this.userRoles = [];
      this.refreshToken = null;
      this.rememberMe = false;
      this.accessToken = null;

      sessionStorage.clear();
      localStorage.clear();
    },
  }
})