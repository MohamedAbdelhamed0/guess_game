/// Model representing a Game Room.
class RoomModel {
  final String id;
  final String roomCode;
  final String hostId;
  final String status; // 'waiting' | 'playing' | 'ended'
  final bool revealed; // true = both photos visible to both players
  final DateTime createdAt;

  const RoomModel({
    required this.id,
    required this.roomCode,
    required this.hostId,
    required this.status,
    this.revealed = false,
    required this.createdAt,
  });

  bool get isWaiting => status == 'waiting';
  bool get isPlaying => status == 'playing';
  bool get isEnded => status == 'ended';

  RoomModel copyWith({
    String? id,
    String? roomCode,
    String? hostId,
    String? status,
    bool? revealed,
    DateTime? createdAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      roomCode: roomCode ?? this.roomCode,
      hostId: hostId ?? this.hostId,
      status: status ?? this.status,
      revealed: revealed ?? this.revealed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_code': roomCode,
      'host_id': hostId,
      'status': status,
      'revealed': revealed,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String? ?? '',
      roomCode: json['room_code'] as String? ?? '',
      hostId: json['host_id'] as String? ?? '',
      status: json['status'] as String? ?? 'waiting',
      revealed: json['revealed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          roomCode == other.roomCode &&
          hostId == other.hostId &&
          status == other.status &&
          revealed == other.revealed &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      roomCode.hashCode ^
      hostId.hashCode ^
      status.hashCode ^
      revealed.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'RoomModel(id: $id, roomCode: $roomCode, hostId: $hostId, status: $status, revealed: $revealed, createdAt: $createdAt)';
  }
}
