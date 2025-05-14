import 'package:flutter/foundation.dart';
import 'meeting.dart';

class MeetingProvider with ChangeNotifier {
    List<Meeting> _meetings = [];

    List<Meeting> get meetings => _meetings;

    void setMeetings(List<Meeting> meetings) {
        _meetings = meetings;
        notifyListeners();
    }

    void addMeeting(Meeting meeting) {
        _meetings.add(meeting);
        notifyListeners();
    }

    void updateMeeting(Meeting updatedMeeting) {
        final index = _meetings.indexWhere((m) => m.id == updatedMeeting.id);
        if (index != -1) {
            _meetings[index] = updatedMeeting;
            notifyListeners();
        }
    }

    void removeMeeting(int meetingId) {
        _meetings.removeWhere((m) => m.id == meetingId);
        notifyListeners();
    }
}