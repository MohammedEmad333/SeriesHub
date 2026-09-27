import 'package:flutter_test/flutter_test.dart';
import 'package:serieshub/core/providers/mock_series_provider.dart';
import 'package:serieshub/core/providers/provider_registry.dart';
import 'package:serieshub/core/providers/remote_provider_repository.dart';

void main() {
  test('remote index immediately changes active providers', () {
    final first = MockSeriesProvider();
    final second = _NamedProvider('second');

    final registry = ProviderRegistry(
      [first, second],
      activeIds: {'second'},
    );

    expect(registry.all.map((item) => item.id), containsAll(['mock', 'second']));

    registry.applyRemoteIndex(
      const RemoteProviderIndex(
        version: 1,
        providers: [
          RemoteProviderDescriptor(
            id: 'second',
            name: 'Second',
            enabled: false,
            status: 'disabled',
            playback: false,
          ),
        ],
      ),
    );

    expect(registry.all.map((item) => item.id), equals(['mock']));
  });
}

class _NamedProvider extends MockSeriesProvider {
  _NamedProvider(this._id);

  final String _id;

  @override
  String get id => _id;
}
