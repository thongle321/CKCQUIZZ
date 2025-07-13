import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/ai_chat_model.dart';
import 'package:ckcandr/providers/ai_chat_provider.dart';
import 'package:ckcandr/providers/ai_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/views/shared/ai_chat_detail_screen.dart';
import 'package:ckcandr/widgets/ai_api_key_required_dialog.dart';
import 'package:ckcandr/widgets/ai_error_dialog.dart';
import 'package:ckcandr/views/shared/ai_settings_screen.dart';

class AiChatSessionsScreen extends ConsumerStatefulWidget {
  const AiChatSessionsScreen({super.key});

  @override
  ConsumerState<AiChatSessionsScreen> createState() => _AiChatSessionsScreenState();
}

class _AiChatSessionsScreenState extends ConsumerState<AiChatSessionsScreen> {
  String _selectedModel = 'gemini-2.5-flash';
  bool _hasCheckedApiKey = false;

  @override
  void initState() {
    super.initState();
    // Check API key after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApiKeyRequired();
    });
  }

  Future<void> _checkApiKeyRequired() async {
    if (_hasCheckedApiKey) return;

    try {
      final aiService = ref.read(aiServiceProvider);
      final settings = await aiService.getSettings();

      if (!settings.hasApiKey && mounted) {
        _hasCheckedApiKey = true;
        await _showApiKeyRequiredDialog();
      } else {
        _hasCheckedApiKey = true;
      }
    } catch (e) {
      debugPrint('Error checking API key: $e');
      _hasCheckedApiKey = true;
    }
  }

  Future<void> _showApiKeyRequiredDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AiApiKeyRequiredDialog(),
    );

    if (result == true) {
      // API key was saved successfully, refresh the screen
      setState(() {
        _hasCheckedApiKey = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final sessionsAsync = ref.watch(aiChatSessionsProvider(currentUser?.id));
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with model selector
            _buildHeader(context, primaryColor),
            
            // Sessions list
            Expanded(
              child: sessionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text('Lỗi tải danh sách chat: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(aiChatSessionsProvider(currentUser?.id)),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
                data: (sessions) => _buildSessionsList(context, sessions, primaryColor),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewSession(context),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Assistant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Chọn cuộc trò chuyện',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Model selector dropdown
              _buildModelSelector(),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedModel,
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        items: const [
          DropdownMenuItem(
            value: 'gemini-2.5-flash',
            child: Text('Gemini 2.5 Flash', style: TextStyle(color: Colors.black, fontSize: 12)),
          ),
          DropdownMenuItem(
            value: 'gemini-2.5-pro',
            child: Text('Gemini 2.5 Pro', style: TextStyle(color: Colors.black, fontSize: 12)),
          ),
          DropdownMenuItem(
            value: 'gemini-2.0-flash',
            child: Text('Gemini 2.0 Flash', style: TextStyle(color: Colors.black, fontSize: 12)),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedModel = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildSessionsList(BuildContext context, List<AiChatSession> sessions, Color primaryColor) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có cuộc trò chuyện nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút + để tạo cuộc trò chuyện mới',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionItem(context, session, primaryColor);
      },
    );
  }

  Widget _buildSessionItem(BuildContext context, AiChatSession session, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: const Icon(Icons.chat, color: Colors.white),
        ),
        title: Text(
          session.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.summary != null) ...[
              const SizedBox(height: 4),
              Text(
                session.summary!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  _formatTime(session.updatedAt),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    session.model,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _deleteSession(session);
                break;
              case 'rename':
                _renameSession(session);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Đổi tên'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _openSession(context, session),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  Future<void> _createNewSession(BuildContext context) async {
    // Check API key first
    try {
      final aiService = ref.read(aiServiceProvider);
      final settings = await aiService.getSettings();

      if (!settings.hasApiKey) {
        await _showApiKeyRequiredDialog();
        return;
      }
    } catch (e) {
      debugPrint('Error checking API key: $e');
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    final controller = ref.read(aiChatSessionsProvider(currentUser?.id).notifier);

    try {
      final session = await controller.createNewSession(model: _selectedModel);
      if (mounted && context.mounted) {
        _openSession(context, session);
      }
    } catch (e) {
      if (mounted && context.mounted) {
        _showErrorDialog(context, e.toString());
      }
    }
  }

  Future<void> _openSession(BuildContext context, AiChatSession session) async {
    // Check API key first
    try {
      final aiService = ref.read(aiServiceProvider);
      final settings = await aiService.getSettings();

      if (!settings.hasApiKey) {
        await _showApiKeyRequiredDialog();
        return;
      }
    } catch (e) {
      debugPrint('Error checking API key: $e');
      return;
    }

    if (mounted && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AiChatDetailScreen(session: session),
        ),
      );
    }
  }

  Future<void> _deleteSession(AiChatSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa cuộc trò chuyện'),
        content: Text('Bạn có chắc chắn muốn xóa "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final currentUser = ref.read(currentUserProvider);
      final controller = ref.read(aiChatSessionsProvider(currentUser?.id).notifier);
      await controller.deleteSession(session.id!);
    }
  }

  Future<void> _renameSession(AiChatSession session) async {
    final controller = TextEditingController(text: session.title);
    
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên cuộc trò chuyện'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên mới',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && mounted) {
      final currentUser = ref.read(currentUserProvider);
      final sessionsController = ref.read(aiChatSessionsProvider(currentUser?.id).notifier);
      final updatedSession = session.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      await sessionsController.updateSession(updatedSession);
    }
  }

  Future<void> _showErrorDialog(BuildContext context, String error) async {
    await showDialog(
      context: context,
      builder: (context) => AiErrorDialog(
        error: error,
        onRetry: () {
          Navigator.of(context).pop();
          // Could retry the last action here if needed
        },
        onSettings: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AiSettingsScreen(),
            ),
          );
        },
      ),
    );
  }
}
