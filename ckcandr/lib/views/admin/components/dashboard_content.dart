import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ckcandr/models/user_model.dart';
import 'package:ckcandr/providers/user_provider.dart';
import 'package:ckcandr/widgets/dashboard/universal_dashboard.dart';

class DashboardContent extends ConsumerWidget {
  const DashboardContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return UniversalDashboard(
      userRole: currentUser?.quyen ?? UserRole.admin,
      userName: currentUser?.hoVaTen,
    );
  }
}
