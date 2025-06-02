import { createApp } from 'vue'
import Antd from 'ant-design-vue'
import { message } from 'ant-design-vue'
import router from './router/index.js'
import App from './App.vue'
import { createPinia } from 'pinia'
import "./assets/scss/argon-dashboard.scss"
import "./assets/css/nucleo-icons.css"
import "./assets/css/nucleo-svg.css"
import "./assets/js/nav-pills.js"
import Vue3Lottie from 'vue3-lottie'

// import 'bootstrap/dist/css/bootstrap.min.css'

import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { fab } from '@fortawesome/free-brands-svg-icons'
import { far } from '@fortawesome/free-regular-svg-icons'

library.add(fas,fab,far);

const app = createApp(App);

const pinia = createPinia()

app.component('font-awesome-icon', FontAwesomeIcon);

app.use(Antd);

app.use(router);

app.use(Vue3Lottie)

app.use(pinia);

app.mount('#app');

app.config.globalProperties.$message = message;
