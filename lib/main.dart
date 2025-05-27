import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'src/configuration/providers_remote.dart';
import 'firebase_options.dart';
import 'src/social_market_app.dart';

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
  logger.info("Initialized Firebase App Check");
  logger.info("Firebase initialized successfully");
  runApp(MultiProvider(providers: providersRemote, child: SocialMarketApp()));
}
