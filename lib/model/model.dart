class PrayerTime {
  final String fajr;
  final String shurooq;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String dateFor;

  PrayerTime({
    required this.fajr,
    required this.shurooq,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.dateFor,
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      fajr: json['fajr'],
      shurooq: json['shurooq'],
      dhuhr: json['dhuhr'],
      asr: json['asr'],
      maghrib: json['maghrib'],
      isha: json['isha'],
      dateFor: json['date_for'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'shurooq': shurooq,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'date_for': dateFor,
    };
  }
}
