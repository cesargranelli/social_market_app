import 'package:camera/camera.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'config/providers_remote.dart';
import 'firebase_options.dart';
import 'social_market_app.dart';

void main() async {
  final logger = Logger('main');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaEnterpriseProvider(
      "6LfhkzcrAAAAAP9-_ehA-yI7GlH_QxCmRl_EjLTv",
    ),
    androidProvider: AndroidProvider.debug,
  );
  try {
    await availableCameras();
  } on CameraException catch (e) {
    logger.severe(e.code, e.description);
  }
  runApp(MultiProvider(providers: providersRemote, child: SocialMarketApp()));
}
