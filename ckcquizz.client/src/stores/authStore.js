
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  // Try to load from localStorage first, then sessionStorage
  const userId = ref(localStorage.getItem('userId') || sessionStorage.getItem('userId') || null)
  const fullName = ref(localStorage.getItem('fullName') || sessionStorage.getItem('fullName') || null)
  const userEmail = ref(localStorage.getItem('userEmail') || sessionStorage.getItem('userEmail') || null)
  const storedRoles = localStorage.getItem('userRoles') || sessionStorage.getItem('userRoles');

  const userRoles = ref(storedRoles ? JSON.parse(storedRoles) : []);

  const isAuthenticated = computed(() => !!userId.value);

  const setUser = (id, email, fullname, roles, rememberMe) => {
    userId.value = id
    fullName.value = fullname
    userEmail.value = email
    userRoles.value = Array.isArray(roles) ? roles : [];

    const storage = rememberMe ? localStorage : sessionStorage;

    storage.setItem('userId', id);
    storage.setItem('fullName', fullname);
    storage.setItem('userEmail', email);
    storage.setItem('userRoles', JSON.stringify(userRoles.value));

    // Clear the other storage if it was used previously
    const otherStorage = rememberMe ? sessionStorage : localStorage;
    otherStorage.clear();
  }

  const logout = () => {
    userId.value = null
    fullName.value = null
    userEmail.value = null
    userRoles.value = []
    localStorage.clear();
    sessionStorage.clear();
  }


  return {
    userId,
    fullName,
    userEmail,
    userRoles,
    isAuthenticated,
    setUser,
    logout
  }
})
