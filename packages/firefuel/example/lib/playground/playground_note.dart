import 'package:firefuel/firefuel.dart';

class PlaygroundNote extends Serializable {
  const PlaygroundNote({
    required this.rating,
    required this.title,
    required this.views,
    this.docId,
    this.pinned = false,
    this.tags = const [],
  });

  factory PlaygroundNote.fromJson(Map<String, dynamic> json, String docId) {
    return PlaygroundNote(
      docId: docId,
      pinned: json[fieldPinned] as bool? ?? false,
      rating: (json[fieldRating] as num?)?.toDouble() ?? 0,
      tags: (json[fieldTags] as List<dynamic>? ?? const []).cast<String>(),
      title: json[fieldTitle] as String? ?? 'Untitled',
      views: json[fieldViews] as int? ?? 0,
    );
  }

  static const fieldPinned = 'pinned';
  static const fieldRating = 'rating';
  static const fieldTags = 'tags';
  static const fieldTitle = 'title';
  static const fieldUpdatedAt = 'updatedAt';
  static const fieldViews = 'views';

  final String? docId;
  final bool pinned;
  final double rating;
  final List<String> tags;
  final String title;
  final int views;

  PlaygroundNote copyWith({
    bool? pinned,
    double? rating,
    List<String>? tags,
    String? title,
    int? views,
  }) {
    return PlaygroundNote(
      docId: docId,
      pinned: pinned ?? this.pinned,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      views: views ?? this.views,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      fieldPinned: pinned,
      fieldRating: rating,
      fieldTags: tags,
      fieldTitle: title,
      fieldViews: views,
    };
  }
}
