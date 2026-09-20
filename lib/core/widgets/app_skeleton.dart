import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../theme/app_colors.dart';

/// Reusable shimmer-loading wrapper — the single place `skeletonizer` is
/// configured for the whole app, so every loading state gets the same
/// brand-consistent shimmer (earth-tone palette from `app_colors.dart`)
/// instead of each feature reaching for the package — and picking its own
/// colors — directly.
///
/// `skeletonizer` needs an actual layout to reduce to bones (it can't
/// shimmer nothing — see the package's "The need for fake data" docs): wrap
/// a *fake* version of the real content with this, not the real content
/// itself:
/// ```dart
/// AppSkeleton(child: MyFakeContentLayout())
/// ```
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({required this.child, this.enabled = true, super.key});

  /// A fake/placeholder layout shaped like the real content that will
  /// eventually replace it.
  final Widget child;

  /// Set to `false` to render [child] normally instead of shimmering it —
  /// lets callers keep a single widget tree and just flip this once the
  /// real data arrives, rather than swapping widgets entirely.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: const ShimmerEffect(
        baseColor: AppColors.neutral,
        highlightColor: AppColors.background,
      ),
      child: child,
    );
  }
}
