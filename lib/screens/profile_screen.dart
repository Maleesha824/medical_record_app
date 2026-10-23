import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final ValueChanged<bool>? onDarkModeChanged;
  const ProfileScreen({super.key, this.onDarkModeChanged});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController(),
      blood = TextEditingController(),
      allergy = TextEditingController(),
      emergency = TextEditingController();
  bool dark = false, lock = false, isEditing = true, hasSavedProfile = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    name.text = p.getString('name') ?? '';
    blood.text = p.getString('blood') ?? '';
    allergy.text = p.getString('allergy') ?? '';
    emergency.text = p.getString('emergency') ?? '';
    hasSavedProfile =
        p.getBool('profile_saved') ??
        [
          name.text,
          blood.text,
          allergy.text,
          emergency.text,
        ].any((value) => value.trim().isNotEmpty);
    isEditing = !hasSavedProfile;
    dark = p.getBool('dark_mode') ?? false;
    lock = await AuthService.enabled();
    if (mounted) setState(() {});
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('name', name.text);
    await p.setString('blood', blood.text);
    await p.setString('allergy', allergy.text);
    await p.setString('emergency', emergency.text);
    await p.setBool('profile_saved', true);
    if (mounted) {
      setState(() {
        hasSavedProfile = true;
        isEditing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  @override
  void dispose() {
    name.dispose();
    blood.dispose();
    allergy.dispose();
    emergency.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile & Settings')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 45)),
        const SizedBox(height: 18),
        _f(name, 'Full name', Icons.person),
        _f(blood, 'Blood group', Icons.bloodtype),
        _f(allergy, 'Allergies', Icons.warning_amber),
        _f(emergency, 'Emergency contact', Icons.phone),
        if (isEditing)
          FilledButton(onPressed: save, child: const Text('Save Profile'))
        else
          OutlinedButton.icon(
            onPressed: () => setState(() => isEditing = true),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
          ),
        const SizedBox(height: 18),
        const Text(
          'App settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text('Use a dark interface'),
                value: dark,
                onChanged: (v) async {
                  final p = await SharedPreferences.getInstance();
                  await p.setBool('dark_mode', v);
                  if (mounted) {
                    setState(() => dark = v);
                    widget.onDarkModeChanged?.call(v);
                  }
                },
                secondary: const Icon(Icons.dark_mode),
              ),
              SwitchListTile(
                title: const Text('Biometric / device lock'),
                subtitle: const Text('Protect the app when it opens'),
                value: lock,
                onChanged: (v) async {
                  if (v) {
                    final ok = await AuthService.authenticate();
                    if (!context.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Authentication was not completed.'),
                        ),
                      );
                      return;
                    }
                  }
                  await AuthService.setEnabled(v);
                  if (mounted) setState(() => lock = v);
                },
                secondary: const Icon(Icons.fingerprint),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Privacy: your records, images and settings are stored locally on the device.',
            ),
          ),
        ),
      ],
    ),
  );
  Widget _f(TextEditingController c, String l, IconData i) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      readOnly: !isEditing,
      decoration: InputDecoration(
        labelText: l,
        prefixIcon: Icon(i),
        suffixIcon: hasSavedProfile && !isEditing
            ? const Icon(Icons.lock_outline, size: 18)
            : null,
      ),
    ),
  );
}
