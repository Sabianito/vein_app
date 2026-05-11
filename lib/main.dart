import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'src/app.dart';
import 'src/theme/vein_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Allows premium font pairing via Google Fonts. If you need strict offline
  // fonts, we can bundle font files instead.
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(
    VeinApp(
      theme: VeinTheme.premiumDark(),
    ),
  );
}
