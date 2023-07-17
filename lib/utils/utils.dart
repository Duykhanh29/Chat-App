import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static Widget showCacheImage(
      {required String url, required double height, required double width}) {
    return CachedNetworkImage(
      height: height,
      width: width,
      fit: BoxFit.fitWidth,
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
            // colorFilter:
            //     const ColorFilter.mode(
            //         Colors.red,
            //         BlendMode
            //             .colorBurn)
          ),
        ),
      ),
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  static Widget showSVGImage(
      {required String url, required double height, required double width}) {
    return SvgPicture.network(
      height: height,
      width: 260,
      url,
      placeholderBuilder: (BuildContext context) => SizedBox(
          width: width,
          height: height,
          child: const Center(child: CircularProgressIndicator())),
      // You can also provide a placeholder SVG image while loading
      // placeholderSvg: 'assets/placeholder.svg',
      // fit: BoxFit.contain,
    );
  }
}
