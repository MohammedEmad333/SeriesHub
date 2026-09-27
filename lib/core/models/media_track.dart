enum MediaTrackType { audio, subtitle }

class MediaTrack {
  const MediaTrack({
    required this.id,
    required this.label,
    required this.language,
    required this.type,
    this.url,
  });

  final String id;
  final String label;
  final String language;
  final MediaTrackType type;
  final String? url;
}
