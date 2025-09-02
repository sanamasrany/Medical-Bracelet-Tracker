import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controller.dart';
import 'homepage.dart';

class WeightPage extends StatelessWidget {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  WeightPage({super.key});

  final box = GetStorage(); // Storage instance

  @override
  Widget build(BuildContext context) {
    final healthController = Get.put(HealthController());

    // If name is already saved, skip this page
    final savedName = box.read('userName');
    if (savedName != null && savedName.isNotEmpty) {
      Future.microtask(() => Get.off(() =>  HomePage())); // Skip setup
    }

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text("Welcome 💚"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 80, color: Colors.teal.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "Set Up Your Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Please enter your name and weight to personalize your experience.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // Name input
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.teal.shade50,
                      prefixIcon: Icon(Icons.person, color: Colors.teal.shade400),
                      hintText: "Your Name",
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.teal.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weight input
                  TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.teal.shade50,
                      prefixIcon: Icon(Icons.monitor_weight_outlined, color: Colors.teal.shade400),
                      hintText: "e.g. 70",
                      labelText: "Weight (kg)",
                      labelStyle: TextStyle(color: Colors.teal.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty && weightController.text.isNotEmpty) {
                          // Save name to storage
                          box.write('userName', nameController.text);

                          // Save weight
                          healthController.userWeight.value =
                              double.parse(weightController.text);

                          // Navigate to Home
                          Get.off(() =>  HomePage());
                        }
                      },
                      child: const Text(
                        "Continue →",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold , color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
