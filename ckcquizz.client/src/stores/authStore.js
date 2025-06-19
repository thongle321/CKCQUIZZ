
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const userId = ref(localStorage.getItem('userId') || null)
  const userEmail = ref(localStorage.getItem('userEmail') || null)
  const storedRoles = localStorage.getItem('userRoles');

  const userRoles = ref(storedRoles ? JSON.parse(storedRoles) : []);

  const isAuthenticated = computed(() => !!userId.value);

  const setUser = (id, email, roles) => {
    userId.value = id
    userEmail.value = email
    userRoles.value = Array.isArray(roles) ? roles : [];

    localStorage.setItem('userId', id);
    localStorage.setItem('userEmail', email);
    localStorage.setItem('userRoles', JSON.stringify(userRoles.value));

    console.log('User set in store and localStorage:', { id, email, roles });
  }

  const logout = () => {
    userId.value = null
    userEmail.value = null
    userRoles.value = []
    localStorage.clear()
  }


  return {
    userId,
    userEmail,
    userRoles,
    isAuthenticated,
    setUser,
    logout
  }
})
