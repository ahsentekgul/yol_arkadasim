import 'package:flutter/material.dart';
import 'package:yol_arkadasim/core/theme/app_colors.dart';
import 'package:yol_arkadasim/core/theme/app_text_styles.dart';

enum _AppNavigationBarKind { home, subPage }

/// AppBar-based navigation bar with accessible actions.
class AppNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  static const String _defaultTitle = 'YolArkadaşım';

  final _AppNavigationBarKind _kind;
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSettingsPressed;

  const AppNavigationBar._({
    super.key,
    required _AppNavigationBarKind kind,
    this.title = _defaultTitle,
    this.onBackPressed,
    this.onSettingsPressed,
  }) : _kind = kind;

  const AppNavigationBar.home({
    Key? key,
    String title = _defaultTitle,
    VoidCallback? onSettingsPressed,
  }) : this._(
          key: key,
          kind: _AppNavigationBarKind.home,
          title: title,
          onSettingsPressed: onSettingsPressed,
        );

  const AppNavigationBar.subPage({
    Key? key,
    String title = _defaultTitle,
    VoidCallback? onBackPressed,
    VoidCallback? onSettingsPressed,
  }) : this._(
          key: key,
          kind: _AppNavigationBarKind.subPage,
          title: title,
          onBackPressed: onBackPressed,
          onSettingsPressed: onSettingsPressed,
        );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleSettingsPressed() {
    if (onSettingsPressed != null) {
      onSettingsPressed!();
    } else {
      debugPrint('Erişilebilirlik ayarları');
    }
  }

  Widget _buildLogoLeading() {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 8),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: 42,
            height: 42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF2A5CC4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -0.6,
                  child: const Icon(
                    Icons.navigation_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isHome = _kind == _AppNavigationBarKind.home;

    final Widget leading = isHome
        ? _buildLogoLeading()
        : IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Geri dön',
            onPressed: () {
              if (onBackPressed != null) {
                onBackPressed!();
              } else {
                Navigator.maybePop(context);
              }
            },
          );

    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: leading,
      title: Text(title, style: AppTextStyles.headerTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Erişilebilirlik ayarları',
          onPressed: _handleSettingsPressed,
        ),
      ],
    );
  }
}
