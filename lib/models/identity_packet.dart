import 'dart:convert';

class IdentityPacket {
  final String userId;
  final String name;
  final int timestamp;

  IdentityPacket({
    required this.userId,
    required this.name,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    "type": "identity",
    "userId": userId,
    "name": name,
    "timestamp": timestamp,
  };

  factory IdentityPacket.fromJson(Map<String, dynamic> json) {
    return IdentityPacket(
      userId: json["userId"],
      name: json["name"],
      timestamp: json["timestamp"],
    );
  }

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));

  static IdentityPacket? fromBytes(List<int> bytes) {
    try {
      final json = jsonDecode(utf8.decode(bytes));
      if (json["type"] == "identity") {
        return IdentityPacket.fromJson(json);
      }
    } catch (_) {}
    return null;
  }
}