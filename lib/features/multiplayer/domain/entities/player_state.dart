import 'package:flutter/material.dart';

/// Player state for multiplayer synchronization
class PlayerState {
  final String id;
  final String name;
  final String? avatar;
  final int skillRating;
  final PlayerStatus status;
  final Map<String, dynamic> stats;
  final DateTime lastSeen;
  
  // In-game state
  int score = 0;
  int lives = 3;
  bool isReady = false;
  Color playerColor = Colors.blue;
  
  PlayerState({
    required this.id,
    required this.name,
    this.avatar,
    this.skillRating = 1000,
    this.status = PlayerStatus.connected,
    Map<String, dynamic>? stats,
    DateTime? lastSeen,
  }) : stats = stats ?? {},
        lastSeen = lastSeen ?? DateTime.now();
  
  /// Update player stats
  void updateStats(Map<String, dynamic> newStats) {
    stats.addAll(newStats);
  }
  
  /// Get win rate
  double get winRate {
    final wins = stats['wins'] ?? 0;
    final games = stats['gamesPlayed'] ?? 0;
    return games > 0 ? wins / games : 0.0;
  }
  
  /// Get rank tier based on skill rating
  RankTier get rankTier {
    if (skillRating < 1000) return RankTier.bronze;
    if (skillRating < 1500) return RankTier.silver;
    if (skillRating < 2000) return RankTier.gold;
    if (skillRating < 2500) return RankTier.platinum;
    if (skillRating < 3000) return RankTier.diamond;
    if (skillRating < 3500) return RankTier.master;
    return RankTier.grandmaster;
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar': avatar,
    'skillRating': skillRating,
    'status': status.toString(),
    'stats': stats,
    'lastSeen': lastSeen.toIso8601String(),
    'score': score,
    'lives': lives,
    'isReady': isReady,
    'playerColor': playerColor.value,
  };
  
  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      skillRating: json['skillRating'] ?? 1000,
      status: PlayerStatus.values.firstWhere(
        (s) => s.toString() == json['status'],
        orElse: () => PlayerStatus.connected,
      ),
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      lastSeen: DateTime.parse(json['lastSeen']),
    )
      ..score = json['score'] ?? 0
      ..lives = json['lives'] ?? 3
      ..isReady = json['isReady'] ?? false
      ..playerColor = Color(json['playerColor'] ?? Colors.blue.value);
  }
}

/// Player status
enum PlayerStatus {
  connected,
  disconnected,
  reconnecting,
  spectating,
  playing,
  eliminated,
}

/// Rank tiers for competitive play
enum RankTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  master,
  grandmaster,
}

/// Get rank tier color
Color getRankColor(RankTier tier) {
  switch (tier) {
    case RankTier.bronze:
      return Colors.brown;
    case RankTier.silver:
      return Colors.grey;
    case RankTier.gold:
      return Colors.amber;
    case RankTier.platinum:
      return Colors.blueGrey;
    case RankTier.diamond:
      return Colors.lightBlue;
    case RankTier.master:
      return Colors.purple;
    case RankTier.grandmaster:
      return Colors.red;
  }
}

/// Get rank tier icon
IconData getRankIcon(RankTier tier) {
  switch (tier) {
    case RankTier.bronze:
    case RankTier.silver:
      return Icons.shield_outlined;
    case RankTier.gold:
    case RankTier.platinum:
      return Icons.shield;
    case RankTier.diamond:
      return Icons.diamond;
    case RankTier.master:
      return Icons.stars;
    case RankTier.grandmaster:
      return Icons.military_tech;
  }
}