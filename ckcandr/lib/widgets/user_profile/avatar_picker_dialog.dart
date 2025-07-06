import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/services/user_profile_service.dart';

/// Dialog để chọn và upload avatar
class AvatarPickerDialog extends ConsumerStatefulWidget {
  final String currentAvatarUrl;
  final Function(String newAvatarUrl) onAvatarUpdated;

  const AvatarPickerDialog({
    super.key,
    required this.currentAvatarUrl,
    required this.onAvatarUpdated,
  });

  @override
  ConsumerState<AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends ConsumerState<AvatarPickerDialog> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;
  String? _uploadedAvatarUrl;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn ảnh đại diện'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hiển thị ảnh hiện tại hoặc ảnh đã chọn
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _buildAvatarImage(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Nút chọn ảnh
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Chọn từ thư viện
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Thư viện'),
                ),
                
                // Chụp ảnh
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Chụp ảnh'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Hiển thị trạng thái upload
            if (_isUploading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Đang tải ảnh lên...'),
                ],
              ),
          ],
        ),
      ),
      actions: [
        // Nút hủy
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        
        // Nút lưu
        ElevatedButton(
          onPressed: _canSave() ? _saveAvatar : null,
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  /// Xây dựng widget hiển thị ảnh
  Widget _buildAvatarImage() {
    if (_selectedImage != null) {
      // Hiển thị ảnh đã chọn
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else if (widget.currentAvatarUrl.isNotEmpty) {
      // Hiển thị ảnh hiện tại
      return Image.network(
        widget.currentAvatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      // Hiển thị avatar mặc định
      return _buildDefaultAvatar();
    }
  }

  /// Xây dựng avatar mặc định
  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: 80,
        color: Colors.grey[600],
      ),
    );
  }

  /// Chọn ảnh từ thư viện hoặc camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Kiểm tra có thể lưu không
  bool _canSave() {
    return _selectedImage != null && !_isUploading;
  }

  /// Lưu avatar
  Future<void> _saveAvatar() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final userProfileService = ref.read(userProfileServiceProvider);
      final avatarUrl = await userProfileService.uploadAvatar(_selectedImage!.path);

      if (avatarUrl != null) {
        setState(() {
          _uploadedAvatarUrl = avatarUrl;
        });

        // Gọi callback để cập nhật avatar
        widget.onAvatarUpdated(avatarUrl);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tải ảnh đại diện lên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Không thể tải ảnh lên');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải ảnh lên: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
