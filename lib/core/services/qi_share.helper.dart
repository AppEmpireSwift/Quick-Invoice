import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class QIShareHelper {
  static Future<void> shareUri({
    required Uri uri,
    Rect? sharePosition,
  }) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          uri: uri,
          sharePositionOrigin: sharePosition,
        ),
      );
    } on PlatformException catch (e) {
      if (e.message?.contains('sharePositionOrigin') ?? false) {
        await SharePlus.instance.share(
          ShareParams(
            uri: uri,
            sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
          ),
        );
      }
    }
  }

  static Future<void> shareFiles({
    required List<XFile> files,
    Rect? sharePosition,
  }) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: files,
          sharePositionOrigin: sharePosition,
        ),
      );
    } on PlatformException catch (e) {
      if (e.message?.contains('sharePositionOrigin') ?? false) {
        await SharePlus.instance.share(
          ShareParams(
            files: files,
            sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
          ),
        );
      }
    }
  }
}
