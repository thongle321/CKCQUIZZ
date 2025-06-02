import 'package:ckcandr/config/routes/router_provider.dart';
import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:ckcandr/config/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'CKC QUIZZ',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.value ?? ThemeMode.light, // Sử dụng giá trị từ AsyncValue
      debugShowCheckedModeBanner: false,
    );
  }
}