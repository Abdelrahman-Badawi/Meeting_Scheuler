import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'api_service.dart';
import 'meeting.dart';
import 'notification.dart' as AppNotification;
import 'edit_meeting_screen.dart';
import 'create_meeting_screen.dart';

class UpcomingMeetingsScreen extends StatefulWidget {
  final int userId;

  const UpcomingMeetingsScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _UpcomingMeetingsScreenState createState() => _UpcomingMeetingsScreenState();
}

class _UpcomingMeetingsScreenState extends State<UpcomingMeetingsScreen> {
  List<Meeting> _meetings = [];
  List<AppNotification.Notification> _notifications = [];
  final ApiService _apiService = ApiService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchMeetings();
    _fetchNotifications();
  }

  void _fetchMeetings() async {
    try {
      _meetings = await _apiService.getUpcomingMeetings(widget.userId);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _fetchNotifications() async {
    try {
      _notifications = await _apiService.getUnreadNotifications(widget.userId);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _acceptMeeting(int meetingId) async {
    try {
      await _apiService.acceptMeeting(meetingId, widget.userId);
      _fetchMeetings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _declineMeeting(int meetingId) async {
    try {
      await _apiService.declineMeeting(meetingId, widget.userId);
      _fetchMeetings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _cancelMeeting(int meetingId) async {
    try {
      await _apiService.cancelMeeting(meetingId);
      _fetchMeetings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _markNotificationAsRead(int notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      _fetchNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Meetings'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_notifications.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_notifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Notifications'),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: _notifications.isEmpty
                        ? const Center(child: Text('No notifications'))
                        : ListView.builder(
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return ListTile(
                                title: Text(notification.message),
                                trailing: IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () {
                                    _markNotificationAsRead(notification.id);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime(2101),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return _meetings
                  .where((meeting) => isSameDay(meeting.time, day))
                  .toList();
            },
          ),
          Expanded(
            child: _meetings.isEmpty
                ? const Center(child: Text('No upcoming meetings'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = _meetings[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            meeting.topic,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${meeting.time} - Status: ${meeting.status}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditMeetingScreen(
                                        meeting: meeting,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      _fetchMeetings();
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  _acceptMeeting(meeting.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _declineMeeting(meeting.id);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _cancelMeeting(meeting.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateMeetingScreen(userId: widget.userId),
            ),
          ).then((value) {
            if (value == true) {
              _fetchMeetings();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

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