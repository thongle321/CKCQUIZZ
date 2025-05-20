import './assets/css/custom.css'
import './assets/css/dashmix.css'
import './assets/js/jquery.min.js'

import { createApp } from 'vue';
import router from './router/index.js';
import App from './App.vue'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap/dist/css/bootstrap-grid.min.css'
import 'bootstrap/dist/css/bootstrap-utilities.min.css'
import 'bootstrap/dist/js/bootstrap.bundle.js'

import { library } from '@fortawesome/fontawesome-svg-core';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { fab } from '@fortawesome/free-brands-svg-icons'
import { far } from '@fortawesome/free-regular-svg-icons'

library.add(fas,fab,far);

const app = createApp(App);
app.component('font-awesome-icon', FontAwesomeIcon);
app.use(router).mount('#app')
