import 'remote_provider_repository.dart';
import 'series_provider.dart';

class ProviderRegistry {
  ProviderRegistry(
    List<SeriesProvider> providers, {
    Map<String, RemoteProviderDescriptor> metadata = const {},
  })  : _providers = {for (final provider in providers) provider.id: provider},
        _metadata = Map.unmodifiable(metadata);

  final Map<String, SeriesProvider> _providers;
  final Map<String, RemoteProviderDescriptor> _metadata;

  List<SeriesProvider> get all => List.unmodifiable(_providers.values);

  SeriesProvider? byId(String id) => _providers[id];

  RemoteProviderDescriptor? metadataFor(String id) => _metadata[id];
}
