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
    this.country,
    this.genres = const [],
  });

  final String id;
  final String title;
  final String overview;
  final SeriesLanguage language;
  final String? posterUrl;
  final int? year;
  final double? rating;
  final String? country;
  final List<String> genres;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'language': language.name,
        'posterUrl': posterUrl,
        'year': year,
        'rating': rating,
        'country': country,
        'genres': genres,
      };

  factory Series.fromJson(Map<String, Object?> json) {
    final rawGenres = json['genres'] as List<dynamic>?;

    return Series(
      id: json['id']! as String,
      title: json['title']! as String,
      overview: json['overview']! as String,
      language: SeriesLanguage.values.byName(json['language']! as String),
      posterUrl: json['posterUrl'] as String?,
      year: json['year'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      country: json['country'] as String?,
      genres: rawGenres?.cast<String>() ?? const [],
    );
  }
}
