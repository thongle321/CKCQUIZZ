


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
        path: "assignment",
        name: "admin-assignment",
        component: () => import("@/views/admin/assignment/index.vue"),
        meta: {
          title: "Assignment",
          requiresAuth: true,
          allowedRoles: ["Teacher"]
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
        path: "notification",
        name: "admin-notification",
        component: () => import("@/views/admin/notification/index.vue"),
        meta: {
          title: "Notification",
          requiresAuth: true,
          allowedRoles: ["Admin", "Teacher"]
        }
      }


    ]
  }
]


export default admin;
