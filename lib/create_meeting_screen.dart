import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meet/api_service.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';

import 'user.dart';
import 'meeting.dart';
import 'meeting_provider.dart';

class CreateMeetingScreen extends StatefulWidget {
  final int userId;

  const CreateMeetingScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _CreateMeetingScreenState createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  DateTime? _selectedDateTime;
  List<User?> _selectedAttendees = [];
  List<User> _allUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadUsers());
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _allUsers = await apiService.getAllUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Failed to load users: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  Future<void> _createMeeting() async {
    final validAttendees = _selectedAttendees.whereType<User>().toList();
    if (_formKey.currentState!.validate() &&
        _selectedDateTime != null &&
        validAttendees.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        final meetingProvider = Provider.of<MeetingProvider>(context, listen: false);
        final meeting = await apiService.createMeeting(
          _selectedDateTime!,
          _topicController.text,
          validAttendees,
          widget.userId,
        );
        meetingProvider.addMeeting(meeting);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The Meeting is Created successfuly')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(' Failed to create meeting : $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        String errorMessage = 'Please fill the required fields';
        if (_selectedDateTime == null) {
          errorMessage += 'Chouse the date time';
        }
        if (validAttendees.isEmpty) {
          errorMessage += 'Pleases select one member to attend the meeting at leaste';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Meeting'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: 'Topic',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter the subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => _selectDateTime(context),
                      child: Text(
                        _selectedDateTime == null
                            ? 'Choose DateTiem and Birth Date'
                            : DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime!),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    MultiSelectChipField<User?>(
                      items: _allUsers
                          .map((user) => MultiSelectItem<User?>(user, user.name))
                          .toList(),
                      title: const Text('Attendees'),
                      headerColor: Colors.blue.withOpacity(0.1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      selectedChipColor: Colors.blue.withOpacity(0.5),
                      onTap: (values) {
                        setState(() {
                          _selectedAttendees = values;
                        });
                      },
                      chipColor: Colors.blue.withOpacity(0.1),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createMeeting,
                      child: const Text('Create Meeting' ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}