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

  Map<String, Object?> toJson() => {
        'id': id,
        'seasonId': seasonId,
        'number': number,
        'title': title,
        'overview': overview,
        'durationMs': duration?.inMilliseconds,
      };

  factory Episode.fromJson(Map<String, Object?> json) {
    final durationMs = json['durationMs'] as int?;
    return Episode(
      id: json['id']! as String,
      seasonId: json['seasonId']! as String,
      number: json['number']! as int,
      title: json['title']! as String,
      overview: json['overview'] as String?,
      duration: durationMs == null ? null : Duration(milliseconds: durationMs),
    );
  }
}
