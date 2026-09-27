import 'series_provider.dart';

class ProviderRegistry {
  ProviderRegistry(List<SeriesProvider> providers)
      : _providers = {for (final provider in providers) provider.id: provider};

  final Map<String, SeriesProvider> _providers;

  List<SeriesProvider> get all => List.unmodifiable(_providers.values);

  SeriesProvider? byId(String id) => _providers[id];
}
