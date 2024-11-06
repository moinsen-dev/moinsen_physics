import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:moinsen_physics/_index.dart';

class ScreenshotTest {
  Widget widget;
  String name;

  ScreenshotTest({
    required this.widget,
    required this.name,
  });
}

// Device configurations based on store requirements
const devices = {
  'android_smartphone': DeviceConfig(
    size: Size(1107, 1968),
    name: 'android_smartphone',
    density: 3.0,
    isAndroid: true,
  ),
  'android_tablet_7': DeviceConfig(
    size: Size(1206, 2144),
    name: 'android_tablet_7',
    density: 2.0,
    isAndroid: true,
  ),
  'android_tablet_10': DeviceConfig(
    size: Size(1449, 2576),
    name: 'android_tablet_10',
    density: 2.0,
    isAndroid: true,
  ),
  'ipad_pro_2': DeviceConfig(
    size: Size(2048, 2732),
    name: 'ipad_pro_2',
    density: 2.0,
    isAndroid: false,
  ),
  'ipad_pro_6': DeviceConfig(
    size: Size(2048, 2732),
    name: 'IPAD_PRO_3GEN_129', // Special name for App Store
    density: 2.0,
    isAndroid: false,
  ),
  'iphone_8_plus': DeviceConfig(
    size: Size(1242, 2208),
    name: 'iphone_8_plus',
    density: 3.0,
    isAndroid: false,
  ),
  'iphone_xs_max': DeviceConfig(
    size: Size(1242, 2688),
    name: 'iphone_xs_max',
    density: 3.0,
    isAndroid: false,
  ),
};

class DeviceConfig {
  final Size size;
  final String name;
  final double density;
  final bool isAndroid;

  const DeviceConfig({
    required this.size,
    required this.name,
    required this.density,
    required this.isAndroid,
  });
}

void main() {
  group('Screenshots', () {
    setUpAll(() async {
      await loadAppFonts();
    });

    final testLocales = ['en'];

    final testWidgets = [
      ScreenshotTest(
        widget: const SplashScreen(),
        name: 'splash',
      ),
      ScreenshotTest(
        widget: const NewtonCradleWidget(showControls: false),
        name: 'newton_cradle',
      ),
      ScreenshotTest(
        widget: const NewtonCradleWidget(showControls: true),
        name: 'newton_cradle_controls',
      ),
    ];

    for (var locale in testLocales) {
      for (var device in devices.entries) {
        testGoldens('${locale}_${device.key}', (tester) async {
          for (var sw in testWidgets) {
            // First take screenshot of the app
            await _captureScreen(
              tester: tester,
              locale: locale,
              device: device.value,
              isFinal: false,
              screenshotTest: sw,
            );

            // Load the screenshot and create decorated version
            final screenFile = File(
              'test/goldens/$locale.${device.key}.${sw.name}.screen.png',
            );
            debugPrint('screenFile: $screenFile');

            if (screenFile.existsSync()) {
              final decoratedWidget = await _createDecoratedScreenshot(
                screenFile,
                device.value,
                locale,
              );

              // Take final screenshot with decorations
              await _captureScreen(
                tester: tester,
                locale: locale,
                device: device.value,
                isFinal: true,
                screenshotTest: sw,
                widget: decoratedWidget,
              );

              // Clean up the initial screenshot
              screenFile.deleteSync();
            }
          }
        });
      }
    }
  });
}

Future<void> _captureScreen({
  required WidgetTester tester,
  required String locale,
  required DeviceConfig device,
  required bool isFinal,
  required ScreenshotTest screenshotTest,
  Widget? widget,
}) async {
  final targetWidget = widget ??
      getScreenWrapper(
        child: screenshotTest.widget,
        locale: Locale(locale),
        isAndroid: device.isAndroid,
      );

  await tester.pumpWidgetBuilder(targetWidget);

  await multiScreenGolden(
    tester,
    '$locale.${device.name}.${screenshotTest.name}',
    devices: [
      Device(
        name: isFinal ? "final" : "screen",
        size: Size(
          device.size.width / device.density,
          device.size.height / device.density,
        ),
        textScale: 1,
        devicePixelRatio: device.density,
      ),
    ],
  );
}

Future<Widget> _createDecoratedScreenshot(
  File screenFile,
  DeviceConfig device,
  String locale,
) async {
  // Pre-cache the image to avoid rebuilds
  final imageProvider = FileImage(screenFile);
  await precacheImage(imageProvider,
      TestWidgetsFlutterBinding.ensureInitialized().rootElement!);

  // Use Image.memory instead of Image.file for better performance
  final bytes = await screenFile.readAsBytes();
  final image = Image.memory(
    bytes,
    filterQuality:
        FilterQuality.medium, // Balance between quality and performance
    gaplessPlayback: true, // Prevent flickering during updates
  );

  // Use white text for Android, black for iOS
  final textColor = device.isAndroid ? Colors.white : Colors.black;

  return Container(
    width: device.size.width / device.density,
    height: device.size.height / device.density,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: device.isAndroid
            ? [Colors.blue[900]!, Colors.blue[700]!]
            : [Colors.white, Colors.grey[100]!],
      ),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Device frame
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: image,
        ),
        const SizedBox(height: 32),
        // Screenshot description with platform-specific text color
        Text(
          locale == 'en'
              ? 'Interactive Physics Simulation'
              : 'Interaktive Physiksimulation',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
