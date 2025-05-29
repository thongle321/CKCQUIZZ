import 'package:ckcandr/config/routes/app_routes.dart';
import 'package:ckcandr/config/themes/app_theme.dart';
import 'package:ckcandr/config/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'CKC QUIZZ',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
          debugShowCheckedModeBanner: false,
          builder: (context, pageContent) {
            // pageContent is the widget for the current route
            return Directionality(
              textDirection: TextDirection.ltr, // Or TextDirection.rtl as needed
              child: Stack(
                children: [
                  pageContent!, // The actual page content
                  Positioned(
                    bottom: 16.0,
                    right: 16.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                      child: Icon(
                        themeProvider.themeMode == ThemeMode.light
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
} 