import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider/app_startup_provider.dart';
import 'widgets/app_startup_error_widget.dart';
import 'widgets/app_startup_loading_widget.dart';

class AppStartupPage extends ConsumerWidget {
  const AppStartupPage({super.key, required this.onLoaded});

  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appStartupProvider);
    return switch (appStartupState) {
      AsyncLoading<void>() => const AppStartupLoadingWidget(),
      AsyncError<void>(:final error) => AppStartupErrorWidget(
        message: () {
          // if (error.toString().contains('Invalid argument(s):') &&
          //     error.toString().contains(
          //       'settings must be set when targeting',
          //     ) &&
          //     error.toString().contains('platform.')) {
          //   return 'This app is not supported on this platform.\nThe supported platforms are Android and Ios.';
          // }
          return error.toString();
        }(),
        onRetry: () => ref.invalidate(appStartupProvider),
      ),
      AsyncData<void>() => onLoaded(context),
    };
  }
}
