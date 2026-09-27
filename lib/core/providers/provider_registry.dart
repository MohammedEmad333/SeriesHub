import 'package:flutter/foundation.dart';

import 'remote_provider_repository.dart';
import 'series_provider.dart';

class ProviderRegistry extends ChangeNotifier {
  ProviderRegistry(
    List<SeriesProvider> providers, {
    Map<String, RemoteProviderDescriptor> metadata = const {},
    Set<String>? activeIds,
  })  : _providers = {for (final provider in providers) provider.id: provider},
        _metadata = Map.of(metadata),
        _activeIds = activeIds == null
            ? {for (final provider in providers) provider.id}
            : {...activeIds};

  final Map<String, SeriesProvider> _providers;
  final Map<String, RemoteProviderDescriptor> _metadata;
  Set<String> _activeIds;

  List<SeriesProvider> get all => List.unmodifiable(
        _providers.values.where(
          (provider) => provider.id == 'mock' || _activeIds.contains(provider.id),
        ),
      );

  List<SeriesProvider> get known => List.unmodifiable(_providers.values);

  Map<String, RemoteProviderDescriptor> get metadata =>
      Map.unmodifiable(_metadata);

  SeriesProvider? byId(String id) => _providers[id];

  RemoteProviderDescriptor? metadataFor(String id) => _metadata[id];

  void applyRemoteIndex(RemoteProviderIndex index) {
    _metadata
      ..clear()
      ..addEntries(
        index.providers.map((descriptor) => MapEntry(descriptor.id, descriptor)),
      );

    final nextActiveIds = <String>{};
    for (final descriptor in index.providers) {
      if (!descriptor.isUsable) continue;
      if (_providers.containsKey(descriptor.id)) {
        nextActiveIds.add(descriptor.id);
      }
    }

    _activeIds = nextActiveIds;
    notifyListeners();
  }
}
