/// Model representing a Player in a game room.
class PlayerModel {
  final String id;
  final String roomId;
  final String userId;
  final String displayName;
  final String? photoUrl; // The photo assigned TO this player to guess
  final int score;
  final bool isHost;
  final DateTime joinedAt;

  const PlayerModel({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.score,
    required this.isHost,
    required this.joinedAt,
  });

  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  PlayerModel copyWith({
    String? id,
    String? roomId,
    String? userId,
    String? displayName,
    String? photoUrl,
    int? score,
    bool? isHost,
    DateTime? joinedAt,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      score: score ?? this.score,
      isHost: isHost ?? this.isHost,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'display_name': displayName,
      'photo_url': photoUrl,
      'score': score,
      'is_host': isHost,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String? ?? '',
      roomId: json['room_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Player',
      photoUrl: json['photo_url'] as String?,
      score: (json['score'] as num?)?.toInt() ?? 0,
      isHost: json['is_host'] as bool? ?? false,
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          roomId == other.roomId &&
          userId == other.userId &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          score == other.score &&
          isHost == other.isHost &&
          joinedAt == other.joinedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      roomId.hashCode ^
      userId.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      score.hashCode ^
      isHost.hashCode ^
      joinedAt.hashCode;

  @override
  String toString() {
    return 'PlayerModel(id: $id, roomId: $roomId, userId: $userId, displayName: $displayName, photoUrl: $photoUrl, score: $score, isHost: $isHost, joinedAt: $joinedAt)';
  }
}
