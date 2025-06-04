
import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const isAuthenticated = ref(localStorage.getItem('isAuthenticated') === 'true')
  const userEmail = ref(localStorage.getItem('userEmail') || '')
  const userRoles = ref(JSON.parse(localStorage.getItem('userRoles') || '[]'))

  const setUser = (email, roles) => {
    isAuthenticated.value = true
    userEmail.value = email
    userRoles.value = roles
  }

  const logout = () => {
    isAuthenticated.value = false
    userEmail.value = ''
    userRoles.value = []
  }

  // Sync với localStorage
  watch([isAuthenticated, userEmail, userRoles], () => {
    localStorage.setItem('isAuthenticated', isAuthenticated.value)
    localStorage.setItem('userEmail', userEmail.value)
    localStorage.setItem('userRoles', JSON.stringify(userRoles.value))
  })

  return {
    isAuthenticated,
    userEmail,
    userRoles,
    setUser,
    logout
  }
})
