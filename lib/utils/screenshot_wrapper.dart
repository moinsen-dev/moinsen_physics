import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moinsen_physics/newton_cradle/controls/simulation_controls.dart';

Widget getScreenWrapper({
  required Widget child,
  required Locale locale,
  required bool isAndroid,
  List<Override> overrides = const [],
}) {
  // Create test controls with sound disabled if in test mode

  return ProviderScope(
    overrides: [],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [const Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: locale,
      theme: ThemeData(
        platform: (isAndroid ? TargetPlatform.android : TargetPlatform.iOS),
      ),
      home: Column(
        children: [
          Container(
              color: Colors.black,
              height: 24), // fake, black and empty status bar
          Expanded(child: child),
        ],
      ),
    ),
  );
}

// Add this provider to control simulation settings
final simulationControlsProvider =
    Provider<SimulationControls>((ref) => SimulationControls.defaultControls);
