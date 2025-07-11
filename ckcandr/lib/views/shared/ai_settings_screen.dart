import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ckcandr/providers/ai_provider.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/core/theme/role_theme.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/services/ai_service.dart';

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _showApiKey = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.quyen ?? UserRole.sinhVien;
    final primaryColor = RoleTheme.getPrimaryColor(role);
    
    final aiSettings = ref.watch(aiSettingsControllerProvider);
    final aiStatsProvider = ref.watch(currentUserAiStatsProvider);
    final aiStats = ref.watch(aiStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cài đặt AI',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quản lý AI Assistant và dữ liệu',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // API Key Section
              aiSettings.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorCard('Lỗi tải cài đặt: $error'),
                data: (settings) => _buildApiKeySection(context, primaryColor, settings),
              ),

              const SizedBox(height: 16),

              // Statistics Section
              aiStats.when(
                loading: () => _buildStatsLoadingCard(),
                error: (error, stack) => _buildErrorCard('Lỗi tải thống kê: $error'),
                data: (stats) => _buildStatsSection(context, primaryColor, stats),
              ),

              const SizedBox(height: 16),

              // Data Management Section
              _buildDataManagementSection(context, primaryColor),

              const SizedBox(height: 32),

              // App Info
              _buildAppInfoSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeySection(BuildContext context, Color primaryColor, dynamic settings) {
    return _buildSettingsSection(
      context,
      title: 'API Key',
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.key,
          title: 'Google AI API Key',
          subtitle: settings.hasApiKey 
              ? 'API key đã được cấu hình' 
              : 'Chưa có API key',
          trailing: settings.hasApiKey 
              ? Icon(Icons.check_circle, color: Colors.green)
              : Icon(Icons.warning, color: Colors.orange),
          onTap: () => _showApiKeyDialog(context, primaryColor, settings),
          color: primaryColor,
        ),
        _buildSettingsItem(
          context,
          icon: Icons.help_outline,
          title: 'Hướng dẫn lấy API Key',
          subtitle: 'Xem hướng dẫn chi tiết',
          onTap: () => _openApiKeyUrl(),
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, Color primaryColor, Map<String, dynamic> stats) {
    return _buildSettingsSection(
      context,
      title: 'Thống kê',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatRow('Số tin nhắn:', '${stats['messageCount']}'),
              const SizedBox(height: 8),
              _buildStatRow('Dung lượng dữ liệu:', stats['formattedSize']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(BuildContext context, Color primaryColor) {
    return _buildSettingsSection(
      context,
      title: 'Quản lý dữ liệu',
      children: [
        _buildSettingsItem(
          context,
          icon: Icons.delete_outline,
          title: 'Xóa lịch sử chat',
          subtitle: 'Xóa toàn bộ lịch sử trò chuyện',
          onTap: () => _showClearChatDialog(context),
          color: Colors.orange,
        ),
        _buildSettingsItem(
          context,
          icon: Icons.delete_forever,
          title: 'Xóa tất cả dữ liệu AI',
          subtitle: 'Xóa API key và toàn bộ dữ liệu',
          onTap: () => _showClearAllDataDialog(context),
          color: Colors.red,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 32,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'AI Assistant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Powered by Google Gemini 2.5 Flash',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openApiKeyUrl() async {
    const url = 'https://aistudio.google.com/apikey';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Copy URL to clipboard
        await Clipboard.setData(const ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở trình duyệt. URL đã được sao chép vào clipboard!\nVui lòng dán vào trình duyệt: https://aistudio.google.com/apikey'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      // Fallback: Copy URL to clipboard
      try {
        await Clipboard.setData(const ClipboardData(text: url));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('URL đã được sao chép vào clipboard!\nVui lòng dán vào trình duyệt: https://aistudio.google.com/apikey'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (clipboardError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi mở link: $e\nVui lòng truy cập: https://aistudio.google.com/apikey'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _showApiKeyDialog(BuildContext context, Color primaryColor, dynamic settings) async {
    _apiKeyController.text = settings.hasApiKey ? '••••••••••••••••••••••••••••••••••••••••' : '';
    _showApiKey = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cấu hình API Key'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (settings.hasApiKey) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'API key đã được cấu hình',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _apiKeyController,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'AIza...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setDialogState(() {
                        _showApiKey = !_showApiKey;
                        if (_showApiKey && settings.hasApiKey) {
                          _loadActualApiKey();
                        } else if (!_showApiKey && settings.hasApiKey) {
                          _apiKeyController.text = '••••••••••••••••••••••••••••••••••••••••';
                        }
                      });
                    },
                  ),
                ),
                obscureText: !_showApiKey,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hướng dẫn:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1. Truy cập https://aistudio.google.com/apikey\n'
                      '2. Nhấn "Create API Key"\n'
                      '3. Sao chép và dán vào ô trên',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _saveApiKeyFromDialog(dialogContext),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadActualApiKey() async {
    try {
      final settings = await ref.read(aiServiceProvider).getSettings();
      if (settings.hasApiKey) {
        _apiKeyController.text = settings.apiKey!;
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveApiKeyFromDialog(BuildContext dialogContext) async {
    final apiKey = _apiKeyController.text.trim();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(dialogContext);

    if (apiKey.isEmpty || apiKey.contains('•')) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập API key hợp lệ')),
      );
      return;
    }

    if (!AiService.isValidApiKeyFormat(apiKey)) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('API key không đúng định dạng')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(aiSettingsControllerProvider.notifier).updateApiKey(apiKey);

      if (mounted) {
        navigator.pop();

        if (success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Lưu API key thành công!')),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('API key không hợp lệ. Vui lòng kiểm tra lại.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        navigator.pop();
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showClearChatDialog(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử chat'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ lịch sử chat? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final currentUser = ref.read(currentUserProvider);
        await ref.read(aiChatControllerProvider(currentUser?.id).notifier).clearHistory();

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Đã xóa lịch sử chat')),
          );
          // Refresh stats
          ref.invalidate(currentUserAiStatsProvider);
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Lỗi xóa lịch sử: $e')),
          );
        }
      }
    }
  }

  Future<void> _showClearAllDataDialog(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả dữ liệu AI'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu AI bao gồm:\n'
          '• API Key\n'
          '• Lịch sử chat\n'
          '• Tất cả cài đặt AI\n\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(aiServiceProvider).clearAllData();

        if (mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Đã xóa tất cả dữ liệu AI')),
          );
          // Refresh all providers
          ref.invalidate(aiSettingsControllerProvider);
          ref.invalidate(currentUserAiStatsProvider);
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Lỗi xóa dữ liệu: $e')),
          );
        }
      }
    }
  }
}
