import StudentQuizLayout from '../layouts/student.vue';
import Dashboard from '../views/student/Dashboard.vue';
import Profile from '../views/student/Profile.vue';
import Class from '../views/student/Class.vue';

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
        path: 'profile',
        name: 'student-profile',
        component: Profile,
        meta: { title: 'Student Profile', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: 'class',
        name: 'student-class',
        component: Class,
        meta: { title: 'Student Class', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: '',
        redirect: { name: 'student-dashboard' }
      }
    ]
  }
];

export default studentRoutes;