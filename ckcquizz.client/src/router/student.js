import StudentQuizLayout from '../layouts/student.vue';
import Dashboard from '../views/student/Dashboard.vue';
import Class from '../views/student/Class.vue';
import ClassDetail from '../views/student/classdetail.vue';

const studentRoutes = [
  {
    path: '/student',
    component: StudentQuizLayout,
    children: [
      {
        path: 'dashboard',
        name: 'student-dashboard',
        component: Dashboard,
        meta: { title: 'Student Dashboard', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: 'class',
        name: 'student-class',
        component: Class,
        meta: { title: 'Student Class', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: 'class-detail/:id',
        name: 'student-classdetail',
        component: ClassDetail,
        meta: { title: 'Student Class Detail', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: '',
        redirect: { name: 'student-dashboard' }
      }
    ]
  }
];

export default studentRoutes;