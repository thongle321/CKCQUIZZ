import { defineStore } from 'pinia';
import apiClient from "@/services/axiosServer"; 

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null,
    permissions: [], 
  }),
  actions: {
    async fetchUserPermissions() {
      try {

        const response = await apiClient.get('/permission/my-permissions');
        this.permissions = response.data.map(permissionString => {
          const cleanPermissionString = permissionString.startsWith('Permission.')
                                        ? permissionString.substring('Permission.'.length)
                                        : permissionString;
          const parts = cleanPermissionString.split('.');
          return {
            chucNang: parts[0],
            hanhDong: parts[1]
          };
        });
      } catch (error) {
        console.error('Failed to fetch user permissions:', error);
        this.permissions = [];
      }
    },
    hasPermission(chucNang, hanhDong) {
      return this.permissions.some(p => 
        p.chucNang.toLowerCase() === chucNang.toLowerCase() && 
        p.hanhDong.toLowerCase() === hanhDong.toLowerCase()
      );
    }
  },
  getters: {
    canCreate: (state) => (chucNang) => state.hasPermission(chucNang, 'create'),
    canView: (state) => (chucNang) => state.hasPermission(chucNang, 'view'),
    canUpdate: (state) => (chucNang) => state.hasPermission(chucNang, 'update'),
    canDelete: (state) => (chucNang) => state.hasPermission(chucNang, 'delete'),
  }
});