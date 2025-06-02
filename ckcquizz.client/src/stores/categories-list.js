import { defineStore } from 'pinia';

export const useAppStore = defineStore('app', {
  state: () => ({
    isRTL: false, // Assuming default value
  }),
  actions: {
    setIsRTL(value) {
      this.isRTL = value;
    },
  },
});
