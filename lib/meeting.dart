import 'user.dart';

class Meeting {
    final int id;
    final DateTime time;
    final String topic;
    final User creator;
    final List<User> attendees;
    final String status; // أضفنا خاصية status

    Meeting({
        required this.id,
        required this.time,
        required this.topic,
        required this.creator,
        required this.attendees,
        required this.status,
    });

    factory Meeting.fromJson(Map<String, dynamic> json) {
        return Meeting(
            id: json['id'],
            time: DateTime.parse(json['time']), // time بيجي كـ String في JSON، فبنحوّله لـ DateTime
            topic: json['topic'],
            creator: User.fromJson(json['creator']),
            attendees: (json['attendees'] as List)
                .map((data) => User.fromJson(data))
                .toList(),
            status: json['status'] ?? 'PENDING', // لو status مش موجود في JSON، بنستخدم قيمة افتراضية
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'time': time.toIso8601String(), // نحوّل DateTime لـ String في JSON
            'topic': topic,
            'creator': creator.toJson(),
            'attendees': attendees.map((user) => user.toJson()).toList(),
            'status': status,
        };
    }
}