import 'package:flutter/material.dart';

import '../../app_config/app_constants.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Image.asset(Constants.backButton),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
