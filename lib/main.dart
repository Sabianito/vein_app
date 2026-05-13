import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'services/firebase_service.dart';
import 'core/theme/vein_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(
    VeinApp(
      theme: VeinTheme.premiumDark(),
    ),
  );
}
