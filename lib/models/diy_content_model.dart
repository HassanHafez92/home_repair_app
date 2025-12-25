// File: lib/models/diy_content_model.dart
// Purpose: Models for DIY tips, articles, and community Q&A content.

import 'package:equatable/equatable.dart';

/// Type of DIY content
enum ContentType { article, video, tip, question }

/// Model for DIY tips and articles
class DiyContentModel extends Equatable {
  /// Unique content ID
  final String id;

  /// Content title
  final String title;

  /// Content summary/description
  final String summary;

  /// Full content body (markdown supported)
  final String? body;

  /// Content type
  final ContentType type;

  /// Category (e.g., plumbing, electrical)
  final String category;

  /// Tags for search
  final List<String> tags;

  /// Thumbnail image URL
  final String? thumbnailUrl;

  /// Video URL (for video content)
  final String? videoUrl;

  /// Author name
  final String authorName;

  /// Author ID (technician or admin)
  final String authorId;

  /// Whether author is a verified expert
  final bool isExpertVerified;

  /// View count
  final int viewCount;

  /// Like count
  final int likeCount;

  /// Comment count
  final int commentCount;

  /// Creation date
  final DateTime createdAt;

  /// Last update date
  final DateTime updatedAt;

  /// Whether content is featured
  final bool isFeatured;

  /// Difficulty level (1-3)
  final int difficultyLevel;

  /// Estimated reading/watching time in minutes
  final int estimatedMinutes;

  const DiyContentModel({
    required this.id,
    required this.title,
    required this.summary,
    this.body,
    required this.type,
    required this.category,
    this.tags = const [],
    this.thumbnailUrl,
    this.videoUrl,
    required this.authorName,
    required this.authorId,
    this.isExpertVerified = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isFeatured = false,
    this.difficultyLevel = 1,
    this.estimatedMinutes = 5,
  });

  /// Get difficulty label
  String get difficultyLabel {
    switch (difficultyLevel) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Advanced';
      default:
        return 'Easy';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'body': body,
    'type': type.name,
    'category': category,
    'tags': tags,
    'thumbnailUrl': thumbnailUrl,
    'videoUrl': videoUrl,
    'authorName': authorName,
    'authorId': authorId,
    'isExpertVerified': isExpertVerified,
    'viewCount': viewCount,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isFeatured': isFeatured,
    'difficultyLevel': difficultyLevel,
    'estimatedMinutes': estimatedMinutes,
  };

  factory DiyContentModel.fromJson(Map<String, dynamic> json) {
    return DiyContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      body: json['body'] as String?,
      type: ContentType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ContentType.article,
      ),
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      authorName: json['authorName'] as String,
      authorId: json['authorId'] as String,
      isExpertVerified: json['isExpertVerified'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFeatured: json['isFeatured'] as bool? ?? false,
      difficultyLevel: json['difficultyLevel'] as int? ?? 1,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 5,
    );
  }

  @override
  List<Object?> get props => [id, title, type, category, updatedAt];
}

/// Model for Q&A questions
class QuestionModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final String category;
  final List<String> tags;
  final String askerName;
  final String askerId;
  final DateTime createdAt;
  final int answerCount;
  final bool isResolved;
  final String? acceptedAnswerId;

  const QuestionModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.tags = const [],
    required this.askerName,
    required this.askerId,
    required this.createdAt,
    this.answerCount = 0,
    this.isResolved = false,
    this.acceptedAnswerId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'category': category,
    'tags': tags,
    'askerName': askerName,
    'askerId': askerId,
    'createdAt': createdAt.toIso8601String(),
    'answerCount': answerCount,
    'isResolved': isResolved,
    'acceptedAnswerId': acceptedAnswerId,
  };

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      askerName: json['askerName'] as String,
      askerId: json['askerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      answerCount: json['answerCount'] as int? ?? 0,
      isResolved: json['isResolved'] as bool? ?? false,
      acceptedAnswerId: json['acceptedAnswerId'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, title, category, isResolved];
}

/// Model for answers to questions
class AnswerModel extends Equatable {
  final String id;
  final String questionId;
  final String body;
  final String authorName;
  final String authorId;
  final bool isExpertAnswer;
  final DateTime createdAt;
  final int upvotes;
  final bool isAccepted;

  const AnswerModel({
    required this.id,
    required this.questionId,
    required this.body,
    required this.authorName,
    required this.authorId,
    this.isExpertAnswer = false,
    required this.createdAt,
    this.upvotes = 0,
    this.isAccepted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'questionId': questionId,
    'body': body,
    'authorName': authorName,
    'authorId': authorId,
    'isExpertAnswer': isExpertAnswer,
    'createdAt': createdAt.toIso8601String(),
    'upvotes': upvotes,
    'isAccepted': isAccepted,
  };

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      body: json['body'] as String,
      authorName: json['authorName'] as String,
      authorId: json['authorId'] as String,
      isExpertAnswer: json['isExpertAnswer'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      upvotes: json['upvotes'] as int? ?? 0,
      isAccepted: json['isAccepted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, questionId, isAccepted];
}
