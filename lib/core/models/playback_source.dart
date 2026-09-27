class PlaybackSource {
  const PlaybackSource({
    required this.url,
    required this.label,
    this.mimeType,
    this.headers = const {},
  });

  final String url;
  final String label;
  final String? mimeType;
  final Map<String, String> headers;
}
