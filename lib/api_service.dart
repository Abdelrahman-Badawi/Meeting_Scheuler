import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'meeting.dart';
import 'user.dart';
import 'notification.dart' as AppNotification;

class ApiService {
  final String baseUrl = 'http://localhost:8080/api/meetings';

  Future<List<Meeting>> getUpcomingMeetings(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/upcoming?userId=$userId'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Meeting.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load meetings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getUpcomingMeetings: $e');
      rethrow;
    }
  }

  Future<Meeting> createMeeting(DateTime time, String topic, List<User> attendees, int creatorId) async {
    try {
      final formattedTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(time);
      print('Sending createMeeting request with: time=$formattedTime, topic=$topic, creatorId=$creatorId, attendees=${attendees.map((u) => u.toJson()).toList()}');
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "time": formattedTime,
          "topic": topic,
          "creatorId": creatorId,
          "attendees": attendees.map((user) => user.toJson()).toList(),
        }),
      );
      if (response.statusCode == 200) {
        return Meeting.fromJson(json.decode(response.body));
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to create meeting: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in createMeeting: $e');
      rethrow;
    }
  }

  Future<Meeting> acceptMeeting(int meetingId, int userId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/$meetingId/accept?userId=$userId'));
      if (response.statusCode == 200) {
        return Meeting.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to accept meeting: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in acceptMeeting: $e');
      rethrow;
    }
  }

  Future<Meeting> declineMeeting(int meetingId, int userId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/$meetingId/decline?userId=$userId'));
      if (response.statusCode == 200) {
        return Meeting.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to decline meeting: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in declineMeeting: $e');
      rethrow;
    }
  }

  Future<Meeting> updateMeeting(int meetingId, DateTime time, String topic, List<User> attendees) async {
    try {
      final formattedTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(time);
      print('Sending updateMeeting request with: meetingId=$meetingId, time=$formattedTime, topic=$topic, attendees=${attendees.map((u) => u.toJson()).toList()}');
      final response = await http.put(
        Uri.parse('$baseUrl/$meetingId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "time": formattedTime,
          "topic": topic,
          "attendees": attendees.map((user) => user.toJson()).toList(),
        }),
      );
      if (response.statusCode == 200) {
        return Meeting.fromJson(json.decode(response.body));
      } else {
        print('Error Response: ${response.body}');
        throw Exception('Failed to update meeting: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in updateMeeting: $e');
      rethrow;
    }
  }

  Future<void> cancelMeeting(int meetingId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$meetingId'));
      if (response.statusCode != 200) {
        throw Exception('Failed to cancel meeting: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in cancelMeeting: $e');
      rethrow;
    }
  }

  Future<List<AppNotification.Notification>> getUnreadNotifications(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications?userId=$userId'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => AppNotification.Notification.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getUnreadNotifications: $e');
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/notifications/$notificationId/read'));
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in markNotificationAsRead: $e');
      rethrow;
    }
  }

  Future<User> createUser(String name, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users?name=$name&email=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in createUser: $e');
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => User.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getAllUsers: $e');
      rethrow;
    }
  }
}