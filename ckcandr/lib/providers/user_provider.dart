import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/models/hoat_dong_gan_day_model.dart';
import 'package:ckcandr/providers/hoat_dong_provider.dart';

// Provider cho danh sách người dùng
final userListProvider = StateProvider<List<User>>((ref) {
  // Dữ liệu mẫu người dùng
  return [
    User(
      id: '1',
      mssv: 'admin',
      hoVaTen: 'Administrator',
      gioiTinh: true,
      email: 'admin@ckc.edu.vn',
      matKhau: 'admin123',
      quyen: UserRole.admin,
      ngayTao: DateTime.now().subtract(const Duration(days: 365)),
      ngayCapNhat: DateTime.now().subtract(const Duration(days: 365)),
    ),
    User(
      id: '2',
      mssv: 'GV001',
      hoVaTen: 'Nguyễn Văn A',
      gioiTinh: true,
      ngaySinh: DateTime(1985, 1, 15),
      email: 'nguyenvana@ckc.edu.vn',
      quyen: UserRole.giangVien,
      ngayTao: DateTime.now().subtract(const Duration(days: 180)),
      ngayCapNhat: DateTime.now().subtract(const Duration(days: 30)),
    ),
    User(
      id: '3',
      mssv: 'GV002',
      hoVaTen: 'Trần Thị B',
      gioiTinh: false,
      ngaySinh: DateTime(1988, 6, 22),
      email: 'tranthib@ckc.edu.vn',
      quyen: UserRole.giangVien,
      ngayTao: DateTime.now().subtract(const Duration(days: 150)),
      ngayCapNhat: DateTime.now().subtract(const Duration(days: 25)),
    ),
    User(
      id: '4',
      mssv: '111111',
      hoVaTen: 'Lê Văn C',
      gioiTinh: true,
      ngaySinh: DateTime(2000, 3, 10),
      email: 'levanc@student.ckc.edu.vn',
      quyen: UserRole.sinhVien,
      ngayTao: DateTime.now().subtract(const Duration(days: 100)),
      ngayCapNhat: DateTime.now().subtract(const Duration(days: 20)),
    ),
    User(
      id: '5',
      mssv: '111112',
      hoVaTen: 'Phạm Thị D',
      gioiTinh: false,
      ngaySinh: DateTime(2001, 5, 5),
      email: 'phamthid@student.ckc.edu.vn',
      quyen: UserRole.sinhVien,
      ngayTao: DateTime.now().subtract(const Duration(days: 90)),
      ngayCapNhat: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];
});

// Provider để lọc người dùng theo vai trò
final filteredUserListProvider = Provider.family<List<User>, UserRole?>((ref, role) {
  final userList = ref.watch(userListProvider);
  
  if (role == null) {
    return userList;
  }
  
  return userList.where((user) => user.quyen == role).toList();
});

// Provider cho người dùng hiện tại (đang đăng nhập)
final currentUserControllerProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  // SECURITY FIX: No default user initialization
  // User must explicitly login through authentication flow
  // This prevents automatic admin access on app startup
  return CurrentUserNotifier(null);
});

// Cập nhật Provider để đảm bảo tính nhất quán trong toàn bộ ứng dụng
final currentUserProvider = currentUserControllerProvider;

// Notifier để quản lý người dùng hiện tại với stream để thông báo thay đổi
class CurrentUserNotifier extends StateNotifier<User?> {
  CurrentUserNotifier(User? user) : super(user) {
    _streamController = StreamController<User?>.broadcast();
    // Thêm giá trị ban đầu vào stream
    _streamController.add(user);
  }

  late StreamController<User?> _streamController;

  Stream<User?> get stream => _streamController.stream;

  void setUser(User? user) {
    state = user;
    _streamController.add(user);
  }

  /// Load user from persistent storage
  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null && userData.isNotEmpty) {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        setUser(user);
      }
    } catch (e) {
      print('Error loading user from storage: $e');
      // If error loading user, clear any invalid data
      setUser(null);
    }
  }

  /// Clear user data
  void clearUser() {
    setUser(null);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}

// Notifier để quản lý thao tác với người dùng
class UserNotifier extends StateNotifier<List<User>> {
  final Ref ref;

  UserNotifier(this.ref, List<User> users) : super(users);

  // Thêm người dùng mới
  void addUser(User user) {
    state = [...state, user];
    
    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    hoatDongNotifier.addHoatDong(
      'Đã thêm người dùng: ${user.hoVaTen} (${user.tenQuyen})',
      LoaiHoatDong.KHAC,
      Icons.person_add,
      idDoiTuongLienQuan: user.id,
    );
  }

  // Cập nhật người dùng
  void updateUser(User user) {
    state = state.map((u) => u.id == user.id ? user : u).toList();
    
    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    hoatDongNotifier.addHoatDong(
      'Đã cập nhật người dùng: ${user.hoVaTen} (${user.tenQuyen})',
      LoaiHoatDong.KHAC,
      Icons.edit_note,
      idDoiTuongLienQuan: user.id,
    );
  }

  // Xóa người dùng
  void deleteUser(User user) {
    final tenUserLog = user.hoVaTen;
    state = state.where((u) => u.id != user.id).toList();
    
    final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
    hoatDongNotifier.addHoatDong(
      'Đã xóa người dùng: $tenUserLog (${user.tenQuyen})',
      LoaiHoatDong.KHAC,
      Icons.person_remove,
      idDoiTuongLienQuan: user.id,
    );
  }

  // Cập nhật trạng thái người dùng (khóa/mở khóa)
  void updateUserStatus(String userId, bool newStatus) {
    state = state.map((u) {
      if (u.id == userId) {
        final updatedUser = u.copyWith(
          trangThai: newStatus,
          ngayCapNhat: DateTime.now(),
        );
        
        final hoatDongNotifier = ref.read(hoatDongGanDayListProvider.notifier);
        hoatDongNotifier.addHoatDong(
          '${newStatus ? "Đã kích hoạt" : "Đã khóa"} người dùng: ${u.hoVaTen}',
          LoaiHoatDong.KHAC,
          newStatus ? Icons.lock_open : Icons.lock,
          idDoiTuongLienQuan: u.id,
        );
        
        return updatedUser;
      }
      return u;
    }).toList();
  }

  // Lấy người dùng theo ID
  User? getUserById(String id) {
    try {
      return state.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Provider để quản lý người dùng với notifier
final userNotifierProvider = StateNotifierProvider<UserNotifier, List<User>>((ref) {
  final users = ref.watch(userListProvider);
  return UserNotifier(ref, users);
}); 