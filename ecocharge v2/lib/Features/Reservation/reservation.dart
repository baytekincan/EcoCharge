import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationPage extends StatefulWidget {
  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void sendFirebaseReservationDate(String date, String time) {
    FirebaseAuth auth = FirebaseAuth.instance;

    String currentUserID = auth.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    CollectionReference usersCollection = firestore.collection("users");

    // user ıd alıyor
    DocumentReference userDocRef = usersCollection.doc(currentUserID);

    // reservasyon collectionu oluşturuyor userın içinde
    CollectionReference userReservationsCollection = userDocRef.collection("reservations");

    userReservationsCollection.add({
      'reservation Date': date,
      'reservation Time': time,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Reservation Date and Time'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Select Time'),
                subtitle: Text(_selectedTime.format(context)),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final DateTime now = DateTime.now();
                        final DateTime selectedDateTime = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        );

                        if (selectedDateTime.isBefore(now)) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Invalid Reservation Date'),
                              content: const Text(
                                  'You cannot make a reservation for a past date or time.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          final String formattedDate =
                              DateFormat('yyyy-MM-dd').format(_selectedDate);
                          final String formattedTime =
                              _selectedTime.format(context);
                          sendFirebaseReservationDate(
                              formattedDate, formattedTime);

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Reservation Confirmed'),
                              content: Text(
                                  'Your reservation for $formattedDate at $formattedTime has been confirmed.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Confirm Reservation'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Exit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
