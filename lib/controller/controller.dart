import 'dart:convert';
import 'package:pray_time/model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class PrayerTimeController {
  static const String _apiKey = "264b293a6c7424ee75fe1511839f4992";
  static const String _baseUrl = "https://muslimsalat.com/";
  static const String _sharedPreferencesKey = "prayerTimes";

  List<PrayerTime> prayerTimes = [];

  // Fetch prayer times from the API and save them in the list
  Future<void> fetchPrayerTimes(String city) async {
    final url = "$_baseUrl$city.json?key=$_apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // Parse the items into a list of PrayerTime
      prayerTimes = (jsonData['items'] as List)
          .map((item) => PrayerTime.fromJson(item))
          .toList();

      // Save the list to shared preferences
      await savePrayerTimesToPreferences();
    } else {
      throw Exception("Failed to fetch prayer times");
    }
  }

  // Save the prayer times list to shared preferences
  Future<void> savePrayerTimesToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(prayerTimes.map((e) => e.toJson()).toList());
    await prefs.setString(_sharedPreferencesKey, jsonString);
  }

  // Load prayer times from shared preferences
  Future<void> loadPrayerTimesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sharedPreferencesKey);

    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      prayerTimes = jsonList.map((item) => PrayerTime.fromJson(item)).toList();
    }
  }
}
