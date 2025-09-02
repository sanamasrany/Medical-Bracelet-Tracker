import 'package:ar_bracelet/preformance.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controller.dart';


class HomePage extends StatelessWidget {
   HomePage({super.key});

  Widget buildCard(String label, String value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 20, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HealthController>();
    controller.scanAndConnect();

    final box = GetStorage(); // 👈 Move it here
    final userName = box.read('userName') ?? "User";

    return Scaffold(
      appBar: AppBar(title: Text("Hello, $userName!")),
      body: Column(
        children: [
          // Expanded grid
          Expanded(
            child: Obx(() => GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(12),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                buildCard("Heart Rate", controller.heartRate.value, Icons.favorite),
                buildCard("SpO₂", controller.spo2.value, Icons.bloodtype),
                buildCard("Temperature", controller.temp.value, Icons.thermostat),
                buildCard("Activity", controller.activity.value, Icons.directions_walk),
                buildCard("Fall", controller.fall.value, Icons.warning),
                buildCard("Temp Alert", controller.tempAlert.value, Icons.thermostat_auto),
                buildCard("Steps", controller.steps.value, Icons.directions_run),
                buildCard("Calories", controller.caloriesBurned.value.toStringAsFixed(2), Icons.local_fire_department),
              ],
            )),
          ),

          // Weekly performance button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => const PerformancePage()),
                icon: const Icon(Icons.bar_chart, size: 28 , color: Colors.white),
                label: const Text(
                  "Weekly Performance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold , color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
