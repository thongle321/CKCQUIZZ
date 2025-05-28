const admin = [
    {
        path: "/admin",
        component: () => import("@/layouts/admin.vue"),
        children: [
            {
                path: "users",
                name: "admin-users",
                component: () => import("@/views/admin/users/Dashboard.vue")
            }
        ]
    }
]


export default admin;
