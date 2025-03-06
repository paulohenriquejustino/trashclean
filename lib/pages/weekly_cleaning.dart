import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class WeeklyCleaningPage extends StatefulWidget {
  const WeeklyCleaningPage({Key? key}) : super(key: key);

  @override
  State<WeeklyCleaningPage> createState() => _WeeklyCleaningPageState();
}

class _WeeklyCleaningPageState extends State<WeeklyCleaningPage> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, bool> _selectedBins = {
    'Blue Bin (Recycling)': false,
    'Brown Bin (Organic Waste)': false,
    'Green Bin (Garden Waste)': false,
  };

  void _scheduleCleaning() {
    if (_selectedBins.values.every((isSelected) => !isSelected)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one bin.')),
      );
      return;
    }

    final selectedBins = _selectedBins.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Schedule'),
        content: Text(
          'You have scheduled cleaning on ${_selectedDate.toLocal()} for:\n${selectedBins.join('\n')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cleaning scheduled successfully!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Cleaning'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.green[700],
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Bins:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _selectedBins.keys.map((bin) {
                  return CheckboxListTile(
                    title: Text(bin),
                    value: _selectedBins[bin],
                    activeColor: Colors.green[700],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedBins[bin] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _scheduleCleaning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Schedule Cleaning',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
