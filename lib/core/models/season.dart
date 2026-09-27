class Season {
  const Season({
    required this.id,
    required this.seriesId,
    required this.number,
    required this.title,
    this.episodeCount,
  });

  final String id;
  final String seriesId;
  final int number;
  final String title;
  final int? episodeCount;
}
