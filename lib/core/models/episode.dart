class Episode {
  const Episode({
    required this.id,
    required this.seasonId,
    required this.number,
    required this.title,
    this.overview,
    this.duration,
  });

  final String id;
  final String seasonId;
  final int number;
  final String title;
  final String? overview;
  final Duration? duration;
}
