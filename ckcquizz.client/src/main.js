import { createApp } from 'vue'
import Antd from 'ant-design-vue'
import { message } from 'ant-design-vue'
import router from './router/index.js'
import App from './App.vue'
import { createPinia } from 'pinia'
import Vue3Lottie from 'vue3-lottie'

import 'bootstrap/dist/css/bootstrap.min.css'

const app = createApp(App);

const pinia = createPinia()

app.use(Antd);

app.use(router);

app.use(Vue3Lottie)

app.use(pinia);

app.mount('#app');

app.config.globalProperties.$message = message;
