
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodLogPage extends StatefulWidget {
  const FoodLogPage({super.key});

  @override
  State<FoodLogPage> createState() => _FoodLogPageState();
}

class _FoodLogPageState extends State<FoodLogPage> {
  final foodController = TextEditingController();
  final caloriesController = TextEditingController();
  final proteinController = TextEditingController();
  final carbsController = TextEditingController();
  final fatController = TextEditingController();

  String selectedMeal = 'Breakfast';
  bool isSaving = false;

  final meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  String get today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  CollectionReference<Map<String, dynamic>> get foodCollection {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('food_logs');
  }

  Future<void> addFood() async {
    final name = foodController.text.trim();
    final calories = double.tryParse(caloriesController.text.trim());

    if (name.isEmpty || calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a food name and valid calories.'),
        ),
      );
      return;
    }

    if (isSaving) return;

    setState(() => isSaving = true);

    try {
      await foodCollection.add({
        'foodName': name,
        'meal': selectedMeal,
        'calories': calories,
        'protein': double.tryParse(proteinController.text.trim()) ?? 0,
        'carbs': double.tryParse(carbsController.text.trim()) ?? 0,
        'fat': double.tryParse(fatController.text.trim()) ?? 0,
        'date': today,
        'createdAt': FieldValue.serverTimestamp(),
      });

      foodController.clear();
      caloriesController.clear();
      proteinController.clear();
      carbsController.clear();
      fatController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food added successfully!')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving food: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> deleteFood(String id) async {
    try {
      await foodCollection.doc(id).delete();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting food: $e')),
      );
    }
  }

  @override
  void dispose() {
    foodController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    super.dispose();
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    String hint = '0',
    bool isFoodName = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isFoodName
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F7EF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget nutritionCard(String label, double value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7EF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF164D2A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$label ($unit)',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in first.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF4),
      appBar: AppBar(
        title: const Text(
          'Food Diary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF164D2A),
          ),
        ),
        backgroundColor: const Color(0xFFFFFDF4),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF164D2A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track your nutrition',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF164D2A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add what you have eaten today.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Food entry form
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8E8DC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add food',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF164D2A),
                    ),
                  ),
                  const SizedBox(height: 18),

                  inputField(
                    'Food name',
                    foodController,
                    hint: 'e.g. Rice, egg, chicken',
                    isFoodName: true,
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: selectedMeal,
                    decoration: InputDecoration(
                      labelText: 'Meal',
                      filled: true,
                      fillColor: const Color(0xFFF8F7EF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: meals.map((meal) {
                      return DropdownMenuItem(
                        value: meal,
                        child: Text(meal),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedMeal = value);
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  inputField('Calories (kcal)', caloriesController),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(child: inputField('Protein (g)', proteinController)),
                      const SizedBox(width: 10),
                      Expanded(child: inputField('Carbs (g)', carbsController)),
                      const SizedBox(width: 10),
                      Expanded(child: inputField('Fat (g)', fatController)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : addFood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27843B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Add Food',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Today's nutrition",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF164D2A),
              ),
            ),

            const SizedBox(height: 14),

            // Real-time Firestore food logs
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: foodCollection
                  .where('date', isEqualTo: today)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Firestore error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                double totalCalories = 0;
                double totalProtein = 0;
                double totalCarbs = 0;
                double totalFat = 0;

                for (final doc in docs) {
                  final data = doc.data();

                  totalCalories += (data['calories'] as num?)?.toDouble() ?? 0;
                  totalProtein += (data['protein'] as num?)?.toDouble() ?? 0;
                  totalCarbs += (data['carbs'] as num?)?.toDouble() ?? 0;
                  totalFat += (data['fat'] as num?)?.toDouble() ?? 0;
                }

                final sortedDocs = [...docs];
                sortedDocs.sort((a, b) {
                  final aTime = a.data()['createdAt'] as Timestamp?;
                  final bTime = b.data()['createdAt'] as Timestamp?;

                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F1E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total calories',
                            style: TextStyle(
                              color: Color(0xFF164D2A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${totalCalories.toStringAsFixed(0)} kcal',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF164D2A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              nutritionCard('Protein', totalProtein, 'g'),
                              const SizedBox(width: 8),
                              nutritionCard('Carbs', totalCarbs, 'g'),
                              const SizedBox(width: 8),
                              nutritionCard('Fat', totalFat, 'g'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (docs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No food added yet today.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                    ...sortedDocs.map((doc) {
                      final data = doc.data();

                      final foodName = data['foodName'] ?? 'Unknown food';
                      final meal = data['meal'] ?? 'Meal';
                      final calories =
                          (data['calories'] as num?)?.toDouble() ?? 0;
                      final protein =
                          (data['protein'] as num?)?.toDouble() ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Color(0xFFE8E8DC),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE8F1E5),
                            child: const Icon(
                              Icons.restaurant,
                              color: Color(0xFF27843B),
                            ),
                          ),
                          title: Text(
                            foodName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '$meal • ${protein.toStringAsFixed(1)} g protein',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${calories.toStringAsFixed(0)} kcal',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF164D2A),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => deleteFood(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
