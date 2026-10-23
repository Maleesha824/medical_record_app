import 'package:flutter/material.dart';
class SectionCard extends StatelessWidget {
  final String title; final String subtitle; final IconData icon; final VoidCallback? onTap;
  const SectionCard({super.key, required this.title, required this.subtitle, required this.icon, this.onTap});
  @override Widget build(BuildContext context) => Card(child: ListTile(contentPadding: const EdgeInsets.all(14), leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle)), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
