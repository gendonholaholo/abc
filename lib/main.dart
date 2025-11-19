import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', fallback: const {"API_BASE_URL": "https://api.example.com"});
  runApp(const ProviderScope(child: HrisAttendanceApp()));
}
