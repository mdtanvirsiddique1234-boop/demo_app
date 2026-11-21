import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_gate.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String? gender;
  String? activityLevel;
  String? goal;

  bool isLoading = false;

  static const green = Color(0xFF27843B);
  static const darkGreen = Color(0xFF164D2A);
  static const cream = Color(0xFFFFFDF4);

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  // SAVE PROFILE TO FIRESTORE
  Future<void> saveProfile() async {
    final age = int.tryParse(ageController.text.trim());
    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());

    if (age == null || age <= 0 ||
        height == null || height <= 0 ||
        weight == null || weight <= 0) {
      showMessage('Please enter valid age, height and weight.');
      return;
    }

    if (gender == null || activityLevel == null || goal == null) {
      showMessage('Please complete all fields.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in.');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'name': user.displayName ?? '',
        'email': user.email,
        'age': age,
        'gender': gender,
        'height_cm': height,
        'weight_kg': weight,
        'activity_level': activityLevel,
        'goal': goal,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthGate(),
        ),
        (route) => false,
      );
    } catch (e) {
      showMessage('Failed to save profile: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // TEXT INPUT FIELD
  Widget inputField({
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5E5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: green,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // DROPDOWN FIELD
  Widget dropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5E5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: green,
            width: 1.5,
          ),
        ),
      ),
      hint: Text(hint),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // FIELD LABEL
  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: darkGreen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 25,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.eco,
                color: green,
                size: 45,
              ),

              const SizedBox(height: 20),

              const Text(
                "Let's get to know you!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Tell us a little about yourself so Pushti Bondhu '
                'can personalize your nutrition journey.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              fieldLabel('Age'),

              inputField(
                hint: 'Your age',
                controller: ageController,
              ),

              const SizedBox(height: 22),

              fieldLabel('Gender'),

              dropdownField(
                hint: 'Select gender',
                value: gender,
                items: ['Male', 'Female', 'Other'],
                onChanged: (value) {
                  setState(() => gender = value);
                },
              ),

              const SizedBox(height: 22),

              fieldLabel('Height (cm)'),

              inputField(
                hint: 'Height in centimeters',
                controller: heightController,
              ),

              const SizedBox(height: 22),

              fieldLabel('Weight (kg)'),

              inputField(
                hint: 'Weight in kilograms',
                controller: weightController,
              ),

              const SizedBox(height: 22),

              fieldLabel('Activity level'),

              dropdownField(
                hint: 'Select activity level',
                value: activityLevel,
                items: [
                  'Sedentary',
                  'Lightly active',
                  'Moderately active',
                  'Very active',
                ],
                onChanged: (value) {
                  setState(() => activityLevel = value);
                },
              ),

              const SizedBox(height: 22),

              fieldLabel('Your goal'),

              dropdownField(
                hint: 'Select your goal',
                value: goal,
                items: [
                  'Lose weight',
                  'Gain weight',
                  'Maintain weight',
                  'Build muscle',
                ],
                onChanged: (value) {
                  setState(() => goal = value);
                },
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
