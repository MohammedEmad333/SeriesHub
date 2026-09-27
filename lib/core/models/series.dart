enum SeriesLanguage { arabic, subtitled, dubbed }

class Series {
  const Series({
    required this.id,
    required this.title,
    required this.overview,
    required this.language,
    this.posterUrl,
    this.year,
    this.rating,
  });

  final String id;
  final String title;
  final String overview;
  final SeriesLanguage language;
  final String? posterUrl;
  final int? year;
  final double? rating;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'language': language.name,
        'posterUrl': posterUrl,
        'year': year,
        'rating': rating,
      };

  factory Series.fromJson(Map<String, Object?> json) {
    return Series(
      id: json['id']! as String,
      title: json['title']! as String,
      overview: json['overview']! as String,
      language: SeriesLanguage.values.byName(json['language']! as String),
      posterUrl: json['posterUrl'] as String?,
      year: json['year'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}
