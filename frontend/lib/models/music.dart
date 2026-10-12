class Music {
  final int id;
  final String title;
  final String? artist;
  final String? description;
  final String? coverImage;
  final String audioUrl;
  final int price;
  final bool isPublished;

  Music({
    required this.id,
    required this.title,
    this.artist,
    this.description,
    this.coverImage,
    required this.audioUrl,
    required this.price,
    required this.isPublished,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString(),
      description: json['description']?.toString(),
      coverImage: json['coverImage']?.toString(),
      audioUrl: json['audioUrl']?.toString() ?? '',
      price: json['price'] as int? ?? 700,
      isPublished: json['isPublished'] as bool? ?? true,
    );
  }
}