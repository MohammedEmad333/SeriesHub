import 'dart:convert';

import 'package:http/http.dart' as http;

class RemoteProviderDescriptor {
  const RemoteProviderDescriptor({
    required this.id,
    required this.name,
    required this.enabled,
    required this.status,
    required this.playback,
  });

  final String id;
  final String name;
  final bool enabled;
  final String status;
  final bool playback;

  bool get isUsable =>
      enabled && status != 'broken' && status != 'disabled';

  factory RemoteProviderDescriptor.fromJson(Map<String, dynamic> json) {
    return RemoteProviderDescriptor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? false,
      status: json['status'] as String? ?? 'broken',
      playback: json['playback'] as bool? ?? false,
    );
  }
}

class RemoteProviderIndex {
  const RemoteProviderIndex({
    required this.version,
    required this.providers,
  });

  final int version;
  final List<RemoteProviderDescriptor> providers;

  factory RemoteProviderIndex.fromJson(Map<String, dynamic> json) {
    final values = json['providers'];
    if (json['version'] != 1 || values is! List) {
      throw const FormatException('Unsupported provider index.');
    }

    final providers = values
        .whereType<Map>()
        .map(
          (value) => RemoteProviderDescriptor.fromJson(
            Map<String, dynamic>.from(value),
          ),
        )
        .where((provider) => provider.id.isNotEmpty)
        .toList(growable: false);

    return RemoteProviderIndex(version: 1, providers: providers);
  }
}

class RemoteProviderRepository {
  RemoteProviderRepository({
    http.Client? client,
    Uri? indexUri,
  })  : _client = client ?? http.Client(),
        indexUri = indexUri ?? defaultIndexUri;

  static final Uri defaultIndexUri = Uri.parse(
    'https://raw.githubusercontent.com/'
    'MohammedEmad333/SeriesHub-Providers/main/index.min.json',
  );

  final http.Client _client;
  final Uri indexUri;

  Future<RemoteProviderIndex?> load() async {
    try {
      final response = await _client
          .get(indexUri)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
      if (decoded is! Map<String, dynamic>) return null;

      return RemoteProviderIndex.fromJson(decoded);
    } on Object {
      return null;
    }
  }
}
