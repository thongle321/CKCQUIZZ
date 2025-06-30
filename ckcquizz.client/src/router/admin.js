const admin = [
  {
    path: "/admin",
    component: () => import("@/layouts/admin.vue"),
    meta: {
      requiresAuth: true,
      allowedRoles: ["Admin", "Teacher"]
    },

    children: [
      {
        path: "home",
        name: "admin-home",
        component: () => import("@/views/admin/home/index.vue"),
        meta: {
          title: "Home",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        },
      },
      {
        path: "dashboard",
        name: "admin-dashboard",
        component: () => import("@/views/admin/dashboard/index.vue"),
        meta: {
          title: "DashBoard",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        },
      },
      {
        path: "question",
        name: "admin-question",
        component: () => import("@/views/admin/question/index.vue"),
        meta: {
          title: "Question",
          requiresAuth: true,
          allowedRoles: ["Teacher"]
        }
      },
      {
        path: "coursegroup",
        name: "admin-coursegroup",
        component: () => import("@/views/admin/coursegroup/index.vue"),
        meta: {
          title: "CourseGroup",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        }
      },
      {
        path: "classdetail/:id",
        name: "admin-classdetail",
        component: () => import("@/views/admin/coursegroup/classdetail.vue"),
        props: true,
        meta: {
          title: "ClassDetail",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        }
      },
      {
        path: "users",
        name: "admin-users",
        component: () => import("@/views/admin/users/index.vue"),
        meta: {
          title: "Users",
          requiresAuth: true,
          allowedRoles: ["Admin"]
        }
      },
      {
        path: "subject",
        name: "admin-subject",
        component: () => import("@/views/admin/subject/index.vue"),
        meta: {
          title: "Subject",
          requiresAuth: true,
          allowedRoles: ["Admin"]
        }
      },
      {
        path: "subject_teacher",
        name: "teacher-subject",
        component: () => import("@/views/admin/subject_gv/index.vue"),
        meta: {
          title: "Subject",
          requiresAuth: true,
          allowedRoles: ["Teacher"]
        }
      },
      {
        path: "rolemanagement",
        name: "admin-rolemanagement",
        component: () => import("@/views/admin/rolemanagement/index.vue"),
        meta: {
          title: "Role Management",
          requiresAuth: true,
          allowedRoles: ["Admin"]
        }
      },
      {
        path: "test",
        name: "admin-test",
        component: () => import("@/views/admin/test/index.vue"),
        meta: {
          title: "Test",
          requiresAuth: true,
          allowedRoles: ["Teacher"]
        }
      },
      {
        path: "test/compose/:id",
        name: "admin-test-compose",
        component: () => import("@/views/admin/test/ComposePage.vue"),
        props: true,
        meta: {
          title: "Soạn câu hỏi",
          requiresAuth: true,
          allowedRoles: ["Teacher"]
        }
      },
      {
        path: "notification",
        name: "admin-notification",
        component: () => import("@/views/admin/notification/index.vue"),
        meta: {
          title: "Notification",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        }
      },
      {
        path: "phancong",
        name: "admin-assignment",
        component: () => import("@/views/admin/assignment/index.vue"),
        meta: {
          title: "Phân công",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        }
      },
      {
        path: 'profile',
        name: 'profile',
        component: () => import('@/views/student/profile.vue'),
        meta: { title: 'Hồ sơ', requiresAuth: true, allowedRoles: ['Teacher', 'Admin'] }
      },
    ]
  }
]


export default admin;
