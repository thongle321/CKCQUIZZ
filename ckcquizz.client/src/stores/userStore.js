import { defineStore } from 'pinia';
import apiClient from "@/services/axiosServer"; // Assuming apiClient is correctly configured

export const useUserStore = defineStore('user', {
  state: () => ({
    user: null,
    permissions: [], // This array will hold the permissions of the logged-in user
  }),
  actions: {
    async fetchUserPermissions() {
      try {

        const response = await apiClient.get('/permission/my-permissions');
        // The backend returns a list of strings like "ChucNang.HanhDong"
        // We need to parse them into objects for easier checking
        this.permissions = response.data.map(permissionString => {
          // Remove "Permission." prefix if it exists
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
      // Permissions are stored as { chucNang: "...", hanhDong: "..." }
      // The server-side PermissionDetailDTO has IsGranted, but we assume
      // the fetched permissions array only contains those that ARE granted.
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