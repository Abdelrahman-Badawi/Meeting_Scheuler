class Notification {
    final int id;
    final String message;
    final bool read;
    final int userId;
    final int meetingId;

    Notification({
        required this.id,
        required this.message,
        required this.read,
        required this.userId,
        required this.meetingId,
    });

    factory Notification.fromJson(Map<String, dynamic> json) {
        return Notification(
            id: json['id'],
            message: json['message'],
            read: json['read'],
            userId: json['userId'],
            meetingId: json['meetingId'],
        );
    }
}