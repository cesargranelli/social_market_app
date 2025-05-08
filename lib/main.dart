import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'firebase_options.dart';
import 'social_market_app.dart';

void main() async {
  final logger = Logger('main');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await availableCameras();
  } on CameraException catch (e) {
    logger.severe(e.code, e.description);
  }
  runApp(MultiProvider(providers: providersRemote, child: SocialMarketApp()));
}
