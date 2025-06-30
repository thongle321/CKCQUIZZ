
import { defineStore } from 'pinia'
import apiClient from '@/services/axiosServer'

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
    },

    async logout() {
      try {
        await apiClient.post('/auth/logout');
      } catch (error) {
        console.error("Logout API call failed...", error);
      }

      this.userId = null;
      this.fullName = null;
      this.userEmail = null;
      this.userRoles = [];
      this.refreshToken = null;
      this.rememberMe = false;

      sessionStorage.clear();
      localStorage.clear();
    },
  }
})