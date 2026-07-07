import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void mockPlatformChannels() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock device_info_plus channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/device_info'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'getDeviceInfo') {
            return {
              // Android keys
              'version': {'sdkInt': 34},
              'board': 'mock_board',
              'brand': 'mock_brand',
              'device': 'mock_device',
              'display': 'mock_display',
              'fingerprint': 'mock_fingerprint',
              'hardware': 'mock_hardware',
              'host': 'mock_host',
              'id': 'mock_id',
              'manufacture': 'mock_manufacture',
              'model': 'mock_model',
              'product': 'mock_product',
              'supported32BitAbis': <String>[],
              'supported64BitAbis': <String>[],
              'supportedAbis': <String>[],
              'tags': 'mock_tags',
              'type': 'mock_type',
              'isPhysicalDevice': false,
              'systemFeatures': <String>[],

              // iOS keys
              'name': 'mock_ios_device',
              'systemName': 'iOS',
              'systemVersion': '17.0',
              'modelName': 'iPhone',
              'localizedModel': 'iPhone',
              'freeDiskSize': 10000000,
              'totalDiskSize': 10000000,
              'physicalRamSize': 4000,
              'availableRamSize': 2000,
              'isiOSAppOnMac': false,
              'isiOSAppOnVision': false,
              'utsname': {
                'sysname': 'mock_sysname',
                'nodename': 'mock_nodename',
                'release': 'mock_release',
                'version': 'mock_version',
                'machine': 'mock_machine',
              },
            };
          }
          return null;
        },
      );

  // Mock health plugin channel
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('flutter_health'), (
        MethodCall methodCall,
      ) async {
        switch (methodCall.method) {
          case 'getHealthConnectSdkStatus':
            return 3; // SDK installed/available
          case 'hasPermissions':
            return true;
          case 'requestAuthorization':
            return true;
          case 'getData':
            return [];
          case 'writeData':
          case 'writeMeal':
            return true;
          case 'getTotalStepsInInterval':
            return 0;
          case 'installHealthConnect':
          case 'configure':
            return true;
          default:
            return null;
        }
      });
}
