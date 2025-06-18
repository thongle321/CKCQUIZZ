import StudentQuizLayout from '../layouts/student.vue';
import DashboardView from '../views/student/DashboardView.vue';
import QuizzesView from '../views/student/QuizzesView.vue';
import ResultsView from '../views/student/ResultsView.vue';
import ProfileView from '../views/student/ProfileView.vue';
import SettingsView from '../views/student/SettingsView.vue';

const studentRoutes = [
  {
    path: '/student',
    component: StudentQuizLayout,
    children: [
      {
        path: 'dashboard',
        name: 'student-dashboard',
        component: DashboardView,
        meta: { title: 'Student Dashboard', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: 'quizzes',
        name: 'student-quizzes',
        component: QuizzesView,
        meta: { title: 'Student Quizzes', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: 'results',
        name: 'student-results',
        component: ResultsView,
        meta: { title: 'Student Results', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: 'profile',
        name: 'student-profile',
        component: ProfileView,
        meta: { title: 'Student Profile', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: 'settings',
        name: 'student-settings',
        component: SettingsView,
        meta: { title: 'Student Settings', requiresAuth: true, allowedRoles: ['Student'] }
      },
      {
        path: '',
        redirect: { name: 'student-dashboard' }
      }
    ]
  }
];

export default studentRoutes;