import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DynamicImageWidget extends StatelessWidget {
  final String imageUrl;
  const DynamicImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.fill,
      imageUrl: imageUrl,
      progressIndicatorBuilder: (
        BuildContext context,
        String url,
        DownloadProgress dp,
      ) =>
          CircularProgressIndicator(value: dp.progress),
      errorWidget: (context, url, error) => Image.asset(
        width: 135,
        height: 90,
        "assets/img/bike2.png",
        fit: BoxFit.fill,
      ),
    );
  }
}
