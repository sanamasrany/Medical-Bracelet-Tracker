import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class PerformancePage extends StatelessWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HealthController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Performance Analysis 💪")),
      body: Obx(() {
        double runningTime = controller.getWeeklyRunningTime();
        double goal = 200.0; // Example: goal 200 min running this week
        double progress = (runningTime / goal).clamp(0, 1);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Weekly Activity Comparison 📊",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Weekly Running Time 🏃‍♂️: ${runningTime.toStringAsFixed(0)} min",
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: Colors.teal,
                        minHeight: 10,
                      ),
                      const SizedBox(height: 10),
                      if (progress >= 1.0)
                        Text(
                          "Congratulations! You've reached your weekly goal! 🎉",
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      if (progress < 1.0)
                        Text(
                          "Keep going! Your weekly goal is ${goal.toInt()} min",
                          style: const TextStyle(color: Colors.black87),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Daily activity comparison
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    String day = (index + 1).toString();
                    double walking = controller.getTotalActivity(day, "Walking");
                    double running = controller.getTotalActivity(day, "Running/Jumping");
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text("Day $day"),
                        subtitle: Text(
                          "Walking: ${walking.toInt()} min, Running: ${running.toInt()} min",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
