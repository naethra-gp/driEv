import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app_config/app_constants.dart';
import '../../../app_themes/app_colors.dart';

class ListWidget extends StatelessWidget {
  final List list;
  const ListWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: AppColors.primary,
              blurRadius: 0.1,
              spreadRadius: 0.1,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: CachedNetworkImage(
            width: 40,
            height: 40,
            imageUrl: list[0]['logoUrl'].toString(),
            errorWidget: (context, url, error) => Image.asset(
              "assets/app/no-img.png",
              height: 50,
              width: 50,
            ),
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          title: Text(
            list[0]['collegeName'].toString(),
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Image.asset(
            Constants.frwdArrow,
            fit: BoxFit.contain,
            height: 20,
            width: 20,
          ),
        ),
      ),
    );
  }
}
