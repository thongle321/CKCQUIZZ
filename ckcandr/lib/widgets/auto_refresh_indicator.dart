import 'package:flutter/material.dart';
import 'package:ckcandr/services/auto_refresh_service.dart';

/// Widget hiển thị trạng thái auto-refresh
class AutoRefreshIndicator extends StatefulWidget {
  final String refreshKey;
  final Widget child;
  final bool showIndicator;
  final Color? indicatorColor;
  final double? indicatorSize;

  const AutoRefreshIndicator({
    super.key,
    required this.refreshKey,
    required this.child,
    this.showIndicator = true,
    this.indicatorColor,
    this.indicatorSize = 12.0,
  });

  @override
  State<AutoRefreshIndicator> createState() => _AutoRefreshIndicatorState();
}

class _AutoRefreshIndicatorState extends State<AutoRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final AutoRefreshService _autoRefreshService = AutoRefreshService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    // Start animation if auto-refresh is active
    if (_autoRefreshService.isAutoRefreshing(widget.refreshKey)) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRefreshing = _autoRefreshService.isAutoRefreshing(widget.refreshKey);
    
    // Update animation based on refresh state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isRefreshing && !_animationController.isAnimating) {
        _animationController.repeat();
      } else if (!isRefreshing && _animationController.isAnimating) {
        _animationController.stop();
      }
    });

    if (!widget.showIndicator || !isRefreshing) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(
                  turns: _animation,
                  child: Icon(
                    Icons.refresh,
                    size: widget.indicatorSize,
                    color: widget.indicatorColor ?? Colors.green,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Auto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.indicatorSize! * 0.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget button để toggle auto-refresh
class AutoRefreshToggleButton extends StatefulWidget {
  final String refreshKey;
  final VoidCallback onRefresh;
  final int intervalSeconds;
  final IconData? icon;
  final String? tooltip;
  final Color? activeColor;
  final Color? inactiveColor;

  const AutoRefreshToggleButton({
    super.key,
    required this.refreshKey,
    required this.onRefresh,
    this.intervalSeconds = 30,
    this.icon = Icons.autorenew,
    this.tooltip = 'Toggle Auto Refresh',
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<AutoRefreshToggleButton> createState() => _AutoRefreshToggleButtonState();
}

class _AutoRefreshToggleButtonState extends State<AutoRefreshToggleButton> {
  final AutoRefreshService _autoRefreshService = AutoRefreshService();

  @override
  Widget build(BuildContext context) {
    final isActive = _autoRefreshService.isAutoRefreshing(widget.refreshKey);

    return IconButton(
      icon: Icon(
        widget.icon,
        color: isActive ? widget.activeColor : widget.inactiveColor,
      ),
      tooltip: widget.tooltip,
      onPressed: () {
        setState(() {
          if (isActive) {
            _autoRefreshService.stopAutoRefresh(widget.refreshKey);
          } else {
            _autoRefreshService.startAutoRefresh(
              key: widget.refreshKey,
              callback: widget.onRefresh,
              intervalSeconds: widget.intervalSeconds,
            );
          }
        });
      },
    );
  }
}

/// Widget hiển thị thông tin auto-refresh status
class AutoRefreshStatusWidget extends StatefulWidget {
  final List<String> refreshKeys;
  final bool showDetails;

  const AutoRefreshStatusWidget({
    super.key,
    required this.refreshKeys,
    this.showDetails = false,
  });

  @override
  State<AutoRefreshStatusWidget> createState() => _AutoRefreshStatusWidgetState();
}

class _AutoRefreshStatusWidgetState extends State<AutoRefreshStatusWidget> {
  final AutoRefreshService _autoRefreshService = AutoRefreshService();

  @override
  Widget build(BuildContext context) {
    final activeKeys = widget.refreshKeys
        .where((key) => _autoRefreshService.isAutoRefreshing(key))
        .toList();

    if (activeKeys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.autorenew,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            widget.showDetails
                ? 'Auto-refresh: ${activeKeys.length} active'
                : 'Auto',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
