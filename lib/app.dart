import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme.dart';

class SocialMarketApp extends ConsumerWidget {
  const SocialMarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Social Market',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
