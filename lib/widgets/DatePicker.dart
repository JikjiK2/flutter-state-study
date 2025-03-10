import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DatePicker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DateRangePickerScreen(),
    );
  }
}

class DateRangePickerScreen extends StatefulWidget {
  const DateRangePickerScreen({super.key});

  @override
  _DateRangePickerScreenState createState() => _DateRangePickerScreenState();
}

class _DateRangePickerScreenState extends State<DateRangePickerScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay){
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay){
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date Range'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TableCalendar(
            availableCalendarFormats: const {
              CalendarFormat.month: '한 달',
            },
            firstDay: DateTime.now().subtract(const Duration(days: 120)),
            lastDay: DateTime.now().add(const Duration(days: 120)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: _onDaySelected,
            rangeStartDay: _rangeStart,
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            onRangeSelected: _onRangeSelected,
            rangeEndDay: _rangeEnd,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
            onFormatChanged: (format) {
              if(_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay){
              _focusedDay = focusedDay;
            },
          ),
        ],
      ),
    );
  }
}
