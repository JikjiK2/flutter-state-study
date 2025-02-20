import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Range Picker',
      home: DateRangePickerScreen1(),
    );
  }
}

class DateRangePickerScreen1 extends StatefulWidget {
  @override
  _DateRangePickerScreenState createState() => _DateRangePickerScreenState();
}

class _DateRangePickerScreenState extends State<DateRangePickerScreen1> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  void _selectDateRange(BuildContext context) async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: selectedStartDate != null && selectedEndDate != null
          ? DateTimeRange(start: selectedStartDate!, end: selectedEndDate!)
          : DateTimeRange(start: DateTime.now(), end: DateTime.now().add(Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 120)), // 120일 후까지 선택 가능
    );

    if (pickedRange != null) {
      setState(() {
        selectedStartDate = pickedRange.start;
        selectedEndDate = pickedRange.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Date Range Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 날짜 선택 안내 텍스트
            if (selectedStartDate == null && selectedEndDate == null)
              Text(
                '날짜를 선택하세요',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            // 시작 날짜와 종료 날짜 각각 표시
            if (selectedStartDate != null)
              Text(
                '시작 날짜: ${selectedStartDate!.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 20),
              ),
            if (selectedEndDate != null)
              Text(
                '종료 날짜: ${selectedEndDate!.toLocal().toString().split(' ')[0]}',
                style: TextStyle(fontSize: 20),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDateRange(context),
              child: Text('Select Date Range'),
            ),
          ],
        ),
      ),
    );
  }
}
