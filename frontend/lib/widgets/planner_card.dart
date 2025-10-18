// frontend/lib/widgets/planner_card.dart
import 'package:flutter/material.dart';

class PlannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  PlannerCard({required this.title, required this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
