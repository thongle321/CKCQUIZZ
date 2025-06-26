
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const userId = ref(localStorage.getItem('userId') || null)
  const fullName = ref(localStorage.getItem('fullName') || null)
  const userEmail = ref(localStorage.getItem('userEmail') || null)
  const storedRoles = localStorage.getItem('userRoles');

  const userRoles = ref(storedRoles ? JSON.parse(storedRoles) : []);

  const isAuthenticated = computed(() => !!userId.value);

  const setUser = (id, email, fullname, roles) => {
    userId.value = id
    fullName.value = fullname
    userEmail.value = email
    userRoles.value = Array.isArray(roles) ? roles : [];

    localStorage.setItem('userId', id);
    localStorage.setItem('fullName', fullname);
    localStorage.setItem('userEmail', email);
    localStorage.setItem('userRoles', JSON.stringify(userRoles.value));

  }

  const logout = () => {
    userId.value = null
    fullName.value = null
    userEmail.value = null
    userRoles.value = []
    localStorage.clear()
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
