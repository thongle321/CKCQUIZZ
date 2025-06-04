// stores/auth.js
import { defineStore } from 'pinia';
import apiClient from '@/services/axiosServer'; // Instance Axios đã cấu hình interceptor
import router from '@/router'; // Vue router instance

export const useAuthStore = defineStore('auth', {
    state: () => ({
        user: null,             // Sẽ lưu thông tin người dùng (ví dụ: { id, email, roles })
        isAuthenticated: false, // Trạng thái đăng nhập
        // Không cần lưu trữ access/refresh token ở đây vì chúng là HttpOnly cookies.
        // Trạng thái `isAuthenticated` được suy ra từ việc API call thành công.
    }),

    getters: {
        currentUser: (state) => state.user,
        isLoggedIn: (state) => state.isAuthenticated,
        userRoles: (state) => state.user?.roles || [], // Giả sử user object có thuộc tính 'roles'
    },

    actions: {
        // Action đăng nhập bằng email/password
        async login(credentials) { // credentials = { email, password }
            // API call đã được chuyển vào component, nhưng tốt hơn là ở đây.
            // Giả sử component gọi trực tiếp API và sau đó gọi action này khi thành công.
            // Hoặc, bạn có thể chuyển logic gọi API vào đây:
            // try {
            //   const response = await apiClient.post('/api/Auth/signin', credentials);
            //   // Backend đã set HttpOnly cookies.
            //   // Bây giờ, fetch thông tin người dùng để cập nhật state.
            //   await this.fetchUser();
            //   // router.push(this.returnUrl || '/'); // this.returnUrl có thể được set trước đó
            //   // this.returnUrl = null;
            //   return true; // Đăng nhập thành công
            // } catch (error) {
            //   console.error("Login failed in store action:", error);
            //   this.user = null;
            //   this.isAuthenticated = false;
            //   throw error; // Ném lỗi để component xử lý hiển thị
            // }
            //
            // Nếu logic API ở component, thì component sẽ gọi setUserData sau khi thành công
        },

        // Action được gọi sau khi API login thành công trong component
        async processLoginSuccess(userDataFromApi) {
            // userDataFromApi là dữ liệu người dùng trả về từ backend sau khi đăng nhập thành công
            // hoặc chúng ta sẽ fetch nó.
            if (userDataFromApi) {
                this.user = userDataFromApi; // Nếu API login trả về user data
            } else {
                await this.fetchUser(); // Nếu API login không trả về user data, thì fetch riêng
            }
            this.isAuthenticated = true;
            // Logic điều hướng nên ở component hoặc sau khi action này hoàn tất
        },

        // Xử lý khi đăng nhập Google thành công (sau khi backend redirect lại)
        async handleGoogleLoginSuccess() {
            // Sau khi backend xử lý Google OAuth và redirect về frontend (đã set cookies),
            // gọi action này để fetch thông tin người dùng và cập nhật store.
            await this.fetchUser();
            // Logic điều hướng có thể được xử lý trong component gọi action này
            // hoặc dựa trên một `returnUrl` đã lưu trước đó.
            // Ví dụ: router.push(this.returnUrl || '/');
        },

        // Lấy thông tin người dùng hiện tại (dựa trên cookie đã có)
        async fetchUser() {
            try {
                // Backend sẽ đọc access token từ HttpOnly cookie
                const response = await apiClient.get('/api/Auth/userprofile'); // Thay bằng endpoint lấy thông tin người dùng của bạn
                this.user = response.data; // Giả sử API trả về { id, email, roles, ... }
                this.isAuthenticated = true;
            } catch (error) {
                console.error('Failed to fetch user:', error);
                this.user = null;
                this.isAuthenticated = false;
                // Quan trọng: Nếu fetchUser thất bại (ví dụ 401 do cookie không hợp lệ/hết hạn),
                // isAuthenticated sẽ là false. Navigation guards sẽ dựa vào đây.
                throw error; // Ném lỗi để nơi gọi có thể xử lý
            }
        },

        // Đăng xuất
        async logout() {
            try {
                await apiClient.post('/api/Auth/signout'); // Endpoint backend để logout (xóa cookies)
            } catch (error) {
                console.error('Logout API call failed:', error);
                // Vẫn tiếp tục dọn dẹp ở client
            } finally {
                this.user = null;
                this.isAuthenticated = false;
                router.push({ name: 'Login' }); // Chuyển hướng về trang Login
            }
        },

        // Kiểm tra trạng thái xác thực (thường dùng khi app load)
        async checkAuthStatus() {
            // Nếu access token trong cookie còn hạn, API call này sẽ thành công
            // và interceptor sẽ tự động refresh token nếu cần.
            if (!this.isAuthenticated) { // Chỉ fetch nếu chưa có thông tin trong store
                try {
                    await this.fetchUser();
                } catch (error) {
                    // Không làm gì, user chưa đăng nhập hoặc session hết hạn
                    // isAuthenticated vẫn là false
                }
            }
        },
    },
});