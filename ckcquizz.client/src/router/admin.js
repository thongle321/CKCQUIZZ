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
          title: "Quản lý câu hỏi",
          requiresAuth: true,
          allowedRoles: ["Teacher"]
        }
      },
      {
        path: "coursegroup",
        name: "admin-coursegroup",
        component: () => import("@/views/admin/coursegroup/index.vue"),
        meta: {
          title: "Quản lý nhóm học phần",
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
          title: "Chi tiết lớp",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        }
      },
      {
        path: "users",
        name: "admin-users",
        component: () => import("@/views/admin/users/index.vue"),
        meta: {
          title: "Quản lý người dùng",
          requiresAuth: true,
          allowedRoles: ["Admin"]
        }
      },
      {
        path: "subject",
        name: "admin-subject",
        component: () => import("@/views/admin/subject/index.vue"),
        meta: {
          title: "Quản lý môn học",
          requiresAuth: true,
          allowedRoles: ["Admin"]
        }
      },
      {
        path: "subject_teacher",
        name: "teacher-subject",
        component: () => import("@/views/admin/subject_gv/index.vue"),
        meta: {
          title: "Quản lý chương",
          requiresAuth: true,
          allowedRoles: ["Teacher"]
        }
      },
      {
        path: "rolemanagement",
        name: "admin-rolemanagement",
        component: () => import("@/views/admin/rolemanagement/index.vue"),
        meta: {
          title: "Quản lý nhóm quyền",
          requiresAuth: true,
          allowedRoles: ["Admin"]
        }
      },
      {
        path: "test",
        name: "admin-test",
        component: () => import("@/views/admin/test/index.vue"),
        meta: {
          title: "Quản lý đề thi",
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
        path: 'test/results/:id',
        name: 'admin-test-results',
        component: () => import('@/views/admin/test/TestResults.vue'),
        meta: {
          title: "Chi tiết đề thi",
          requiresAuth: true,
          allowedRoles: ["Teacher"]
        }
      },
      {
        path: "notification",
        name: "admin-notification",
        component: () => import("@/views/admin/notification/index.vue"),
        meta: {
          title: "Quản lý thông báo",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        }
      },
      {
        path: "phancong",
        name: "admin-assignment",
        component: () => import("@/views/admin/assignment/index.vue"),
        meta: {
          title: "Quản lý phân công",
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
