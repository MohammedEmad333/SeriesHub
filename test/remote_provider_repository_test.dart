import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serieshub/core/providers/remote_provider_repository.dart';

void main() {
  test('loads Aniyomi-style provider array and exposes status', () async {
    final repository = RemoteProviderRepository(
      client: MockClient(
        (_) async => http.Response(
          '['
          '{"id":"official-youtube","name":"SeriesHub: Official YouTube",'
          '"pkg":"serieshub.provider.officialyoutube","enabled":true,'
          '"status":"working","playback":true,"sources":[]},'
          '{"id":"roya","name":"SeriesHub: Roya","pkg":"serieshub.provider.roya",'
          '"enabled":false,"status":"disabled","playback":false,"sources":[]}'
          ']',
          200,
        ),
      ),
      indexUri: Uri.parse('https://example.test/index.json'),
    );

    final index = await repository.load();

    expect(index, isNotNull);
    expect(index!.providers, hasLength(2));
    expect(index.providers.first.isUsable, isTrue);
    expect(index.providers.last.isUsable, isFalse);
  });

  test('returns null when remote repository is unavailable', () async {
    final repository = RemoteProviderRepository(
      client: MockClient((_) async => http.Response('nope', 500)),
      indexUri: Uri.parse('https://example.test/index.json'),
    );

    expect(await repository.load(), isNull);
  });

  test('still accepts legacy object indexes', () {
  final index = RemoteProviderIndex.fromDecoded({
    'version': 1,
    'providers': [
      {
        'id': 'legacy',
        'name': 'Legacy',
        'enabled': true,
        'status': 'working',
        'playback': true,
      },
    ],
  });

    expect(index.providers.single.id, 'legacy');
  });
}
