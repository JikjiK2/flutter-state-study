import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Date Range Picker',
      home: DateRangePickerScreen1(),
    );
  }
}

class DateRangePickerScreen1 extends StatefulWidget {
  const DateRangePickerScreen1({super.key});

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
          : DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 1))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 120)), // 120일 후까지 선택 가능
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
        title: const Text('Date Range Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 날짜 선택 안내 텍스트
            if (selectedStartDate == null && selectedEndDate == null)
              const Text(
                '날짜를 선택하세요',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            // 시작 날짜와 종료 날짜 각각 표시
            if (selectedStartDate != null)
              Text(
                '시작 날짜: ${selectedStartDate!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 20),
              ),
            if (selectedEndDate != null)
              Text(
                '종료 날짜: ${selectedEndDate!.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 20),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDateRange(context),
              child: const Text('Select Date Range'),
            ),
          ],
        ),
      ),
    );
  }
}
