import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart'; // أضفنا الـ import
import 'api_service.dart';
import 'meeting.dart';
import 'user.dart';

class EditMeetingScreen extends StatefulWidget {
  final Meeting meeting;
  final int userId;

  const EditMeetingScreen({required this.meeting, required this.userId, Key? key}) : super(key: key);

  @override
  _EditMeetingScreenState createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends State<EditMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  DateTime? _selectedDateTime;
  List<User> _allUsers = [];
  List<User> _selectedAttendees = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _topicController.text = widget.meeting.topic;
    _selectedDateTime = widget.meeting.time; // عدّلنا هنا، لأن time هو DateTime
    _selectedAttendees = widget.meeting.attendees;
    _fetchUsers();
  }

  void _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _allUsers = await _apiService.getAllUsers();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: $e';
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _updateMeeting() async {
    if (_formKey.currentState!.validate() && _selectedDateTime != null && _selectedAttendees.isNotEmpty) {
      try {
        await _apiService.updateMeeting(
          widget.meeting.id,
          _selectedDateTime!,
          _topicController.text,
          _selectedAttendees,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meeting updated successfully')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating meeting: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select attendees')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meeting'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _topicController,
                          decoration: const InputDecoration(labelText: 'Meeting Topic'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a topic';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDateTime == null
                                    ? 'Select Date & Time'
                                    : _selectedDateTime!.toString().substring(0, 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _selectDateTime(context),
                              child: const Text('Pick Date & Time'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        MultiSelectChipField<User?>(
                          items: _allUsers
                              .map((user) => MultiSelectItem<User?>(user, user.name))
                              .toList(),
                          initialValue: _selectedAttendees,
                          title: const Text('Select Attendees'),
                          headerColor: Colors.blue.withOpacity(0.1),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          selectedChipColor: Colors.blue.withOpacity(0.5),
                          selectedTextStyle: const TextStyle(color: Colors.white),
                          onTap: (List<User?> selected) {
                            setState(() {
                              _selectedAttendees = selected.whereType<User>().toList();
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateMeeting,
                          child: const Text('Update Meeting'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }
}