import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/dashboard_model.dart';
import 'package:ckcandr/services/dashboard_service.dart';
import 'package:ckcandr/services/api_service.dart';

/// Provider cho Dashboard Service
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DashboardService(apiService);
});

/// Provider cho Dashboard Statistics
final dashboardStatisticsProvider = FutureProvider<DashboardStatistics>((ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return await dashboardService.getDashboardStatistics();
});

/// Provider cho Recent Activities
final recentActivitiesProvider = FutureProvider<List<RecentActivityItem>>((ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return await dashboardService.getRecentActivities();
});


/// Provider cho Dashboard refresh
final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

/// Method để refresh dashboard data
void refreshDashboard(WidgetRef ref) {
  ref.invalidate(dashboardStatisticsProvider);
  ref.invalidate(recentActivitiesProvider);
  ref.read(dashboardRefreshProvider.notifier).state++;
}
