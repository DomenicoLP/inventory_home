import 'package:flutter/material.dart';

class DailyPlanPage extends StatefulWidget {
  final String day;

  const DailyPlanPage({
    super.key,
    required this.day,
  });

  @override
  State<DailyPlanPage> createState() => _DailyPlanPageState();
}

class _DailyPlanPageState extends State<DailyPlanPage> {
  final TextEditingController _breakfastController =
      TextEditingController();

  final TextEditingController _lunchController =
      TextEditingController();

  final TextEditingController _snackController =
      TextEditingController();

  final TextEditingController _dinnerController =
      TextEditingController();

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _snackController.dispose();
    _dinnerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.day,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            100,
          ),
          children: [
            Text(
              'Piano alimentare',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Inserisci cosa mangiare e quanto per ogni pasto.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 24),

            _MealSection(
              title: 'Colazione',
              icon: Icons.free_breakfast_outlined,
              controller: _breakfastController,
              hintText: 'Es. Yogurt 200 g, cereali 40 g, caffè',
            ),

            const SizedBox(height: 16),

            _MealSection(
              title: 'Pranzo',
              icon: Icons.lunch_dining_outlined,
              controller: _lunchController,
              hintText: 'Es. Pasta 80 g, pollo 150 g, verdure',
            ),

            const SizedBox(height: 16),

            _MealSection(
              title: 'Merenda',
              icon: Icons.apple_outlined,
              controller: _snackController,
              hintText: 'Es. Frutta 150 g',
            ),

            const SizedBox(height: 16),

            _MealSection(
              title: 'Cena',
              icon: Icons.dinner_dining_outlined,
              controller: _dinnerController,
              hintText: 'Es. Pesce 200 g, pane 50 g, verdure',
            ),
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final TextEditingController controller;
  final String hintText;

  const _MealSection({
    required this.title,
    required this.icon,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            TextField(
              controller: controller,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}