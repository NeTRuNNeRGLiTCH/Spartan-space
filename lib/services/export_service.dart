import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/titan_id_card.dart';

class ExportService {
  static final ScreenshotController _controller = ScreenshotController();

  static Future<void> generateAndShareId({
    required BuildContext context,
    required Map<String, dynamic> bodyData,
    required String combatClass,
    required Color classColor,
    required double ffmi,
    required String chassis,
    required String rarity,
  }) async {
    Widget card = TitanIdCard(
      bodyData: bodyData,
      combatClass: combatClass,
      classColor: classColor,
      ffmi: ffmi,
      chassis: chassis,
      rarity: rarity,
    );

    final image = await _controller.captureFromWidget(
      Material(child: card),
      delay: const Duration(milliseconds: 100),
    );

    final directory = await getTemporaryDirectory();
    final imagePath = await File('${directory.path}/titan_id.png').create();
    await imagePath.writeAsBytes(image);
    await Share.shareXFiles([XFile(imagePath.path)], text: 'TITAN ASSET CREDENTIALS VERIFIED.');
  }
}