import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  final VoidCallback onConfigReload;
  final String title;
  final bool showSettingsIcon;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leadingWidget;

  const TitleBar({
    super.key,
    required this.isDark,
    required this.onConfigReload,
    this.title = 'BuyTime',
    this.showSettingsIcon = true,
    this.showBackButton = false,
    this.actions,
    this.leadingWidget,

  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
        onPressed: () => Navigator.pop(context),
      )
          : null, // 👈 YA NO USAMOS leadingWidget AQUÍ

      centerTitle: false,
      title: Row(
        children: [
          if (leadingWidget != null)
            Expanded(
              child: SizedBox(
                height: 20,
                child: leadingWidget!,
              ),
            ),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
      actions: [
        ...?actions,
        if (showSettingsIcon)
          IconButton(
            icon: Icon(Icons.settings, color: isDark ? Colors.white : Colors.black),
            tooltip: 'Ajustes',
            onPressed: () {
              Navigator.pushNamed(context, '/settings').then((_) {
                onConfigReload();
              });
            },
          ),
      ],
    );
  }

}