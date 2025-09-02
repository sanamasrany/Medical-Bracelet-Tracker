import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'notification_service.dart';

class HealthController extends GetxController {
  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;

  // User weight
  RxDouble userWeight = 70.0.obs;

  // Sensor values
  RxString heartRate = "-".obs;
  RxString spo2 = "-".obs;
  RxString temp = "-".obs;
  RxString activity = "Stationary".obs;
  RxString fall = "-".obs;
  RxString tempAlert = "-".obs;
  RxString steps = "-".obs;

  // Calories
  RxDouble caloriesBurned = 0.0.obs;

  // Activity tracking
  String previousActivityStatus = "Stationary";
  DateTime lastActivityChangeTime = DateTime.now();

  // 🌀 Dizziness detection
  double? heartRateAtLastChange;
  static const int monitoringPeriodMs = 10000; // 10 seconds
  static const double heartRateDropThreshold = 15.0;

  @override
  void onInit() {
    super.onInit();
    scanAndConnect();
  }

  void scanAndConnect() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      for (var r in results) {
        if (r.device.name == "HC-05" || r.device.name == "HM-10") {
          await FlutterBluePlus.stopScan();
          device = r.device;
          await device!.connect();

          List<BluetoothService> services = await device!.discoverServices();
          for (var service in services) {
            for (var c in service.characteristics) {
              if (c.properties.notify) {
                characteristic = c;
                await c.setNotifyValue(true);
                c.value.listen((value) {
                  String raw = utf8.decode(value);
                  parseData(raw);
                });
              }
            }
          }
        }
      }
    });
  }

  void parseData(String raw) {
    List<String> parts = raw.split(",");
    for (var p in parts) {
      if (p.startsWith("HR:")) {
        heartRate.value = p.split(":")[1];

        double? hr = double.tryParse(heartRate.value);
        if (hr != null) {
          // 🔔 Heart rate notifications
          if (hr > 100) {
            NotificationService.showNotification(
              "High Heart Rate ⚠️",
              "Your heart rate is $hr bpm. Please rest.",
            );
          } else if (hr < 60) {
            NotificationService.showNotification(
              "Low Heart Rate ⚠️",
              "Your heart rate is $hr bpm. Please be cautious.",
            );
          }

          // 🌀 Dizziness detection check
          checkDizziness(hr);
        }
      }

      if (p.startsWith("SpO2:")) spo2.value = p.split(":")[1];
      if (p.startsWith("Temp:")) temp.value = p.split(":")[1];
      if (p.startsWith("Activity:")) activity.value = p.split(":")[1];

      // --- Fall detection ---
      if (p.startsWith("Fall:")) {
        fall.value = p.split(":")[1];

        // 🔔 Send notification if fall detected
        if (fall.value == "PossibleFall" || fall.value == "Fall") {
          NotificationService.showNotification(
            "Fall Alert ⚠️",
            "A possible fall has been detected. Please be careful!",
          );
        }
      }

      if (p.startsWith("TempAlert:")) tempAlert.value = p.split(":")[1];
      if (p.startsWith("Steps:")) steps.value = p.split(":")[1];
    }

    // 👉 Update calories
    calculateCalories();
    trackActivity();
  }


  void checkDizziness(double currentHr) {
    String currentActivity = activity.value;

    // 1️⃣ User starts moving after being stationary
    if (previousActivityStatus == "Stationary" &&
        (currentActivity == "Light Movement" ||
            currentActivity == "Walking" ||
            currentActivity == "Running/Jumping")) {
      heartRateAtLastChange = currentHr;
      lastActivityChangeTime = DateTime.now();
      previousActivityStatus = currentActivity;
      return;
    }

    // 2️⃣ Check for HR drop during monitoring window
    if (heartRateAtLastChange != null) {
      final elapsed = DateTime.now().difference(lastActivityChangeTime).inMilliseconds;
      if (elapsed < monitoringPeriodMs) {
        final drop = heartRateAtLastChange! - currentHr;
        if (drop > heartRateDropThreshold) {
          NotificationService.showNotification(
            "Dizziness Alert 🌀",
            "We noticed a sudden heart rate drop after moving. Take care!",
          );

          // reset to avoid multiple alerts
          heartRateAtLastChange = null;
        }
      } else {
        // Monitoring window expired
        heartRateAtLastChange = null;
      }
    }

    // 3️⃣ Update previous activity
    if (currentActivity != previousActivityStatus) {
      previousActivityStatus = currentActivity;
    }
  }

  void calculateCalories() {
    String currentActivity = activity.value;
    if (currentActivity != previousActivityStatus) {
      final durationMs = DateTime.now().difference(lastActivityChangeTime).inMilliseconds;
      final durationHours = durationMs / 3600000.0;

      double mets = 0.0;
      if (previousActivityStatus == "Stationary") mets = 1.0;
      else if (previousActivityStatus == "Light Movement") mets = 2.5;
      else if (previousActivityStatus == "Walking") mets = 3.5;
      else if (previousActivityStatus == "Running/Jumping") mets = 8.0;

      if (mets > 0) {
        caloriesBurned.value += mets * userWeight.value * durationHours;
      }

      previousActivityStatus = currentActivity;
      lastActivityChangeTime = DateTime.now();
    }
  }

  // --- Weekly activity tracking ---
  // Stores minutes spent in each activity per day (simplified)
  RxMap<String, Map<String, double>> weeklyActivity = <String, Map<String, double>>{}.obs;

  void trackActivity() {
    // Example: track activity every minute or every update
    String today = DateTime.now().weekday.toString(); // 1=Mon, 7=Sun
    String currentActivity = activity.value; // "Stationary", "Light Movement", "Walking", "Running/Jumping"

    if (!weeklyActivity.containsKey(today)) {
      weeklyActivity[today] = {
        "Stationary": 0,
        "Light Movement": 0,
        "Walking": 0,
        "Running/Jumping": 0
      };
    }

    weeklyActivity[today]![currentActivity] =
        (weeklyActivity[today]![currentActivity] ?? 0) + 1; // increment 1 min
  }

  double getTotalActivity(String day, String type) {
    return weeklyActivity[day]?[type] ?? 0.0;
  }

  double getWeeklyRunningTime() {
    double total = 0;
    for (var day in weeklyActivity.values) {
      total += day["Running/Jumping"] ?? 0;
    }
    return total;
  }

}
