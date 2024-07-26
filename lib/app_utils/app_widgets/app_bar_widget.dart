import 'package:flutter/material.dart';

import '../../app_config/app_constants.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget? rightWidget;
  // final IconButton? menu;
  final bool leadingIcon;

  const AppBarWidget({super.key, this.rightWidget, this.leadingIcon = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: leadingIcon
          ? IconButton(
              icon: Image.asset(Constants.backButton),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : IconButton(
              icon: Image.asset(Constants.nav),
              onPressed: () {},
            ),
      actions: rightWidget != null ? [rightWidget!] : null,
    );
  }
}
