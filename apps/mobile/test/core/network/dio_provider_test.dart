import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hafidz_app/core/device/device_id_provider.dart';
import 'package:hafidz_app/core/network/dio_provider.dart';
import 'package:hafidz_app/core/persistence/persistence_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('device id is stable UUID and attached to dio headers', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    final first = container.read(deviceIdProvider);
    final second = container.read(deviceIdProvider);
    expect(first, second);
    expect(
      first,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );

    final dio = container.read(dioProvider);
    expect(dio.options.headers['X-Device-Id'], first);
    expect(dio.options.headers['Accept-Language'], 'id');
    expect(dio.options.headers['X-App-Version'], appVersion);
  });
}
