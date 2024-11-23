import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:pray_time/controller/controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PrayerTimeController().loadPrayerTimesFromPreferences();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Prayer Times',
      debugShowCheckedModeBanner: false,
      home: PrayerTimesScreen(),
    );
  }
}

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  _PrayerTimesScreenState createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimeController _controller = PrayerTimeController();
  late Timer _timer;
  late String _countdown = 'Loading...';
  late DateTime _nextPrayerTime;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    await _controller.loadPrayerTimesFromPreferences();
    if (_controller.prayerTimes.isEmpty) {
      await _controller.fetchPrayerTimes("dhaka");
    }
    _setNextPrayerTime();
    _startCountdown();
    setState(() {});
  }

  // Set the time for the next prayer (e.g., Asr to Maghrib)
void _setNextPrayerTime() {
  _currentTime = DateTime.now();
  print("Current Time: $_currentTime");

  for (var prayer in _controller.prayerTimes) {
    List<String> prayerTimes = [
      prayer.asr, // Asr time
      prayer.maghrib, // Maghrib time
      prayer.isha, // Isha time
    ];

    for (var prayerTime in prayerTimes) {
      DateTime prayerDateTime = _convertToDateTime(prayerTime);
      print("Checking Prayer Time: $prayerTime, Parsed DateTime: $prayerDateTime");

      if (prayerDateTime.isAfter(_currentTime)) {
        _nextPrayerTime = prayerDateTime;
        print("Next Prayer Time: $_nextPrayerTime");
        break;
      }
    }

    if (_nextPrayerTime.isAfter(_currentTime)) break;
  }

  if (_nextPrayerTime.isBefore(_currentTime)) {
    _countdown = 'No more prayers today';
    setState(() {});
    return;
  }
}

void _startCountdown() {
  // ignore: prefer_const_constructors
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    setState(() {
      _countdown = _getTimeUntilNextPrayer();
      print("Countdown Updated: $_countdown");
    });
  });
}




  // Get the time remaining until the next prayer (e.g., Asr to Maghrib)
  String _getTimeUntilNextPrayer() {
    Duration remainingTime = _nextPrayerTime.difference(_currentTime);

    // If the time remaining is less than or equal to 0, stop the timer
    if (remainingTime.inSeconds <= 0) {
      _timer.cancel();
      return 'Time for prayer!';
    }

    return _formatDuration(remainingTime);
  }

  // Convert the time string to DateTime
  DateTime _convertToDateTime(String timeString) {
    DateFormat format = DateFormat('h:mm a'); // 'h:mm a' for format like 3:35 pm or 5:27 am
    try {
      // Try to parse the timeString into a DateTime
      DateTime parsedTime = format.parse(timeString);
      DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
    } catch (e) {
      // Handle errors if the time string is in an unexpected format
      print("Error parsing time: $e");
      return DateTime.now(); // Return current time if parsing fails
    }
  }

  // Format the duration as hours:minutes:seconds
  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prayer Times"),
      ),
      body: _controller.prayerTimes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Countdown Display
                Text(
                  "Next Prayer Countdown: $_countdown",
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Prayer Times
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _controller.prayerTimes.length,
                  itemBuilder: (context, index) {
                    final prayer = _controller.prayerTimes[index];
                    return ListTile(
                      title: Text("Date: ${prayer.dateFor}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Fajr: ${prayer.fajr}"),
                          Text("Dhuhr: ${prayer.dhuhr}"),
                          Text("Asr: ${prayer.asr}"),
                          Text("Maghrib: ${prayer.maghrib}"),
                          Text("Isha: ${prayer.isha}"),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _controller.fetchPrayerTimes("dhaka");
          setState(() {});
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
