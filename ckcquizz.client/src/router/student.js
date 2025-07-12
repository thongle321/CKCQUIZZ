import StudentQuizLayout from '../layouts/student.vue';
import Class from '../views/student/class.vue';
import ClassList from '../views/student/classlist.vue';
import ClassDetail from '../views/student/classdetail.vue';
import ClassExams from '../views/student/classexams.vue';
import ExamResult from '../views/student/examresult.vue';

const studentRoutes = [
  {
    path: '/student',
    component: StudentQuizLayout,
    children: [
      {
        path: '',
        redirect: { name: 'student-class-list' }
      },
      {
        path: '',
        component: Class,
        children: [
          {
            path: 'class-list',
            name: 'student-class-list',
            component: ClassList,
            meta: { title: 'Danh sách lớp', requiresAuth: true, allowedRoles: ['Student'] }
          },
          {
            path: 'class-detail/:id',
            name: 'student-classdetail',
            component: ClassDetail,
            meta: { title: 'Chi tiết lớp', requiresAuth: true, allowedRoles: ['Student'] }
          },
          {
            path: 'class-exams',
            component: ClassExams,
            name: 'student-class-exams',
            meta: { title: 'Danh sách đề thi', requiresAuth: true, allowedRoles: ['Student'] }
          },
          {
            path: 'profile',
            component: () => import('../views/student/profile.vue'),
            name: 'student-profile',
            meta: { title: 'Hồ sơ', requiresAuth: true, allowedRoles: ['Student'] }
          }
        ]
      },
    ],
    meta: { title: 'Lớp', requiresAuth: true, allowedRoles: ['Student'] }
  },
  {
    path: '/exam/:id',
    name: 'student-exam-taking',
    component: () => import('../views/student/examtake.vue'),
    meta: { title: 'Làm bài thi', requiresAuth: true, allowedRoles: ['Student'] }
  },
  {
    path: '/exam-result/:examId/:resultId',
    name: 'student-exam-result',
    component: () => ExamResult,
    meta: { title: 'Kết quả bài thi', requiresAuth: true, allowedRoles: ['Student'] }
  },
];

export default studentRoutes;