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
}
