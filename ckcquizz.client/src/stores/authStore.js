
import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  const isAuthenticated = ref(localStorage.getItem('isAuthenticated') === 'true')
  const userEmail = ref(localStorage.getItem('userEmail') || '')
  const userRoles = ref(JSON.parse(localStorage.getItem('userRoles') || '[]'))
  const userId = ref(localStorage.getItem('userId') || '')

  const setUser = (id, email, roles) => {
    isAuthenticated.value = true
    userId.value = id
    userEmail.value = email
    userRoles.value = roles
    console.log(localStorage.getItem('userEmail'));
  }

  const logout = () => {
    isAuthenticated.value = false
    userId.value = ''
    userEmail.value = ''
    userRoles.value = []
    localStorage.clear()
  }

  watch([isAuthenticated, userId, userEmail, userRoles], () => {
    localStorage.setItem('isAuthenticated', isAuthenticated.value)
    localStorage.setItem('userId', userId.value)
    localStorage.setItem('userEmail', userEmail.value)
    localStorage.setItem('userRoles', JSON.stringify(userRoles.value))
  })

  return {
    isAuthenticated,
    userId,
    userEmail,
    userRoles,
    setUser,
    logout
  }
})
