import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownMessageWidget extends StatelessWidget {
  final String message;
  final bool isUser;
  final Color? backgroundColor;
  final Color? textColor;

  const MarkdownMessageWidget({
    super.key,
    required this.message,
    required this.isUser,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showCopyOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Message content
            if (isUser)
              // User messages: simple text
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  message,
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: 14,
                  ),
                ),
              )
            else
              // AI messages: markdown rendering
              _buildMarkdownContent(context),
            
            // Copy button for AI messages
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => _copyMessage(context),
                      icon: const Icon(Icons.copy, size: 16),
                      iconSize: 16,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[600],
                      ),
                      tooltip: 'Copy message',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: MarkdownBody(
        data: message,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          // Paragraph style
          p: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
          // Headers
          h1: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h2: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h3: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          // Bold and italic
          strong: TextStyle(
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          em: TextStyle(
            color: textColor ?? Colors.black87,
            fontStyle: FontStyle.italic,
          ),
          // Code
          code: TextStyle(
            backgroundColor: Colors.grey[100],
            color: Colors.red[700],
            fontSize: 13,
            fontFamily: 'monospace',
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          codeblockPadding: const EdgeInsets.all(12),
          // Lists
          listBullet: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 14,
          ),
          // Links
          a: TextStyle(
            color: Colors.blue[600],
            decoration: TextDecoration.underline,
          ),
          // Blockquotes
          blockquote: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          blockquoteDecoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              left: BorderSide(
                color: Colors.grey[400]!,
                width: 4,
              ),
            ),
          ),
          blockquotePadding: const EdgeInsets.all(12),
        ),
        onTapLink: (text, href, title) {
          if (href != null) {
            _launchUrl(href);
          }
        },
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Đã sao chép tin nhắn'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCopyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Sao chép toàn bộ tin nhắn'),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Sao chép văn bản thuần'),
              onTap: () {
                Navigator.pop(context);
                _copyPlainText(context);
              },
            ),
            if (!isUser) ...[
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Sao chép markdown'),
                onTap: () {
                  Navigator.pop(context);
                  _copyMarkdown(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _copyPlainText(BuildContext context) {
    // Remove markdown formatting for plain text
    String plainText = message
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Bold
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1') // Italic
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1') // Inline code
        .replaceAll(RegExp(r'^#+\s*', multiLine: true), '') // Headers
        .replaceAll(RegExp(r'^\s*[-*+]\s*', multiLine: true), '• ') // Lists
        .replaceAll(RegExp(r'^\s*\d+\.\s*', multiLine: true), ''); // Numbered lists
    
    Clipboard.setData(ClipboardData(text: plainText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Đã sao chép văn bản thuần'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyMarkdown(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Đã sao chép markdown'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
