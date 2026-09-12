import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

const Color kPrimary = Color(0xFF159A9C);
const Color kBlue = Color(0xFF3F78A8);
const Color kGold = Color(0xFFE5B84B);
const Color kBackground = Color(0xFFF5F9FA);
const Color kText = Color(0xFF20343D);
const Color kSecondaryText = Color(0xFF6B7C85);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('fuel_passes');
  runApp(const FuelPassLibraryApp());
}

class FuelPassLibraryApp extends StatefulWidget {
  const FuelPassLibraryApp({super.key});

  @override
  State<FuelPassLibraryApp> createState() => _FuelPassLibraryAppState();
}

class _FuelPassLibraryAppState extends State<FuelPassLibraryApp> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FuelPass Library',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      home: MainShell(
        darkMode: darkMode,
        onDarkModeChanged: (value) => setState(() => darkMode = value),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: kBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackground,
        foregroundColor: kText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFDCE7EA)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: kSecondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE7EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE7EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 1.8),
        ),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.dark,
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onOpenPasses: () => setState(() => index = 1)),
      const PassesPage(),
      const AddPassPage(),
      const StatisticsPage(),
      SettingsPage(
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.qr_code_2_outlined), selectedIcon: Icon(Icons.qr_code_2), label: 'Passes'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenPasses});

  final VoidCallback onOpenPasses;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('fuel_passes');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        final passes = box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        passes.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                pinned: false,
                title: Text(
                  'FuelPass Library',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _welcomeCard(context),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddPassPage()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Fuel Pass'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Fuel Passes',
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                        ),
                        TextButton(
                          onPressed: onOpenPasses,
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    if (passes.isEmpty)
                      _emptyState(context)
                    else
                      ...passes.take(3).map(
                        (pass) => PassCard(
                          pass: pass,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PassDetailsPage(passKey: _findKey(box, pass)),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _findKey(Box box, Map<String, dynamic> pass) {
    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map && value['id'] == pass['id']) return key as int;
    }
    return box.keys.first as int;
  }

  Widget _welcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F6F7), Color(0xFFEAF1F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Your Fuel Passes\\nIn One Place',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: kText,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Store, organize and access your fuel pass QR codes offline.',
                  style: TextStyle(color: kSecondaryText, height: 1.35),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/icon/app_icon.png',
            width: 88,
            height: 88,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          children: [
            const Icon(Icons.qr_code_2, size: 54, color: kPrimary),
            const SizedBox(height: 12),
            const Text(
              'No fuel passes yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add your first QR image and keep it ready when you need it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kSecondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class PassesPage extends StatefulWidget {
  const PassesPage({super.key});

  @override
  State<PassesPage> createState() => _PassesPageState();
}

class _PassesPageState extends State<PassesPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('fuel_passes');

    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          final all = box.values
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          final passes = all.where((pass) {
            final text = '${pass['name']} ${pass['plate']}'.toLowerCase();
            return text.contains(query.toLowerCase());
          }).toList();

          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                title: Text('My Fuel Passes', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    TextField(
                      onChanged: (value) => setState(() => query = value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search passes...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (passes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 70),
                        child: Center(child: Text('No matching fuel passes.')),
                      )
                    else
                      ...passes.map(
                        (pass) => PassCard(
                          pass: pass,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PassDetailsPage(passKey: _findKey(box, pass)),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _findKey(Box box, Map<String, dynamic> pass) {
    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map && value['id'] == pass['id']) return key as int;
    }
    return box.keys.first as int;
  }
}

class PassCard extends StatelessWidget {
  const PassCard({super.key, required this.pass, required this.onTap});

  final Map<String, dynamic> pass;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = pass['active'] == true;

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8F6F7),
          child: Icon(
            _vehicleIcon(pass['vehicleType'] as String?),
            color: kPrimary,
          ),
        ),
        title: Text(
          pass['name']?.toString().isNotEmpty == true ? pass['name'] : 'Fuel Pass',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(pass['plate']?.toString() ?? 'No plate number'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(active ? 'Active' : 'Inactive'),
              backgroundColor: active ? const Color(0xFFE0F4EA) : const Color(0xFFFFF1D6),
              labelStyle: TextStyle(
                color: active ? const Color(0xFF247C54) : const Color(0xFF8A6200),
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  IconData _vehicleIcon(String? type) {
    switch (type) {
      case 'Motorcycle':
        return Icons.two_wheeler;
      case 'Van':
        return Icons.airport_shuttle;
      case 'Truck':
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }
}

class AddPassPage extends StatefulWidget {
  const AddPassPage({super.key, this.passKey});

  final int? passKey;

  @override
  State<AddPassPage> createState() => _AddPassPageState();
}

class _AddPassPageState extends State<AddPassPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _name = TextEditingController();
  final _plate = TextEditingController();
  final _notes = TextEditingController();

  Uint8List? imageBytes;
  bool active = true;
  String vehicleType = 'Car';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.passKey != null) {
      final box = Hive.box('fuel_passes');
      final map = Map<String, dynamic>.from(box.get(widget.passKey) as Map);
      _name.text = map['name']?.toString() ?? '';
      _plate.text = map['plate']?.toString() ?? '';
      _notes.text = map['notes']?.toString() ?? '';
      vehicleType = map['vehicleType']?.toString() ?? 'Car';
      active = map['active'] == true;
      imageBytes = map['image'] as Uint8List?;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _plate.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() => imageBytes = bytes);
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    if (imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your QR code image.')),
      );
      return;
    }

    setState(() => loading = true);

    final box = Hive.box('fuel_passes');
    final old = widget.passKey == null
        ? null
        : Map<String, dynamic>.from(box.get(widget.passKey) as Map);

    final data = {
      'id': old?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _name.text.trim(),
      'plate': _plate.text.trim(),
      'vehicleType': vehicleType,
      'notes': _notes.text.trim(),
      'active': active,
      'image': imageBytes,
      'createdAt': old?['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
    };

    if (widget.passKey == null) {
      await box.add(data);
    } else {
      await box.put(widget.passKey, data);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.passKey != null;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(editing ? 'Edit Fuel Pass' : 'Add Fuel Pass'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 210,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFBFD4D9),
                    style: BorderStyle.solid,
                  ),
                ),
                child: imageBytes == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 48, color: kBlue),
                          SizedBox(height: 10),
                          Text(
                            'Upload QR Code Image',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap to select from gallery',
                            style: TextStyle(color: kSecondaryText),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.memory(
                          imageBytes!,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                labelText: 'Vehicle name',
                hintText: 'e.g. My Car',
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter a vehicle name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _plate,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.badge_outlined),
                labelText: 'License plate number',
                hintText: 'e.g. ABC 1234',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: vehicleType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.directions_car_outlined),
                labelText: 'Vehicle type',
              ),
              items: const [
                DropdownMenuItem(value: 'Car', child: Text('Car')),
                DropdownMenuItem(value: 'Van', child: Text('Van')),
                DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcycle')),
                DropdownMenuItem(value: 'Truck', child: Text('Truck')),
              ],
              onChanged: (value) => setState(() => vehicleType = value ?? 'Car'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.notes_outlined),
                labelText: 'Notes (optional)',
                hintText: 'e.g. Personal vehicle',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pass is active'),
              subtitle: const Text('Show this pass as available to use'),
              value: active,
              activeThumbColor: kPrimary,
              onChanged: (value) => setState(() => active = value),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: loading ? null : save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: kPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: loading
                  ? const CircularProgressIndicator()
                  : Text(editing ? 'Save Changes' : 'Save Pass'),
            ),
          ],
        ),
      ),
    );
  }
}

class PassDetailsPage extends StatelessWidget {
  const PassDetailsPage({super.key, required this.passKey});

  final int passKey;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('fuel_passes');

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: [passKey]),
      builder: (context, Box box, _) {
        final raw = box.get(passKey);
        if (raw == null) {
          return const Scaffold(body: Center(child: Text('Pass not found.')));
        }

        final pass = Map<String, dynamic>.from(raw as Map);
        final image = pass['image'] as Uint8List;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Fuel Pass Details', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddPassPage(passKey: passKey)),
                    );
                  } else if (value == 'delete') {
                    _delete(context, box);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE8F6F7),
                        child: Icon(Icons.local_gas_station, color: kPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pass['name']?.toString().isNotEmpty == true
                                  ? pass['name']
                                  : 'Fuel Pass',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(pass['plate']?.toString() ?? 'No plate number'),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(pass['active'] == true ? 'Active' : 'Inactive'),
                        backgroundColor: pass['active'] == true
                            ? const Color(0xFFE0F4EA)
                            : const Color(0xFFFFF1D6),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.memory(
                          image,
                          width: double.infinity,
                          height: 330,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keep your screen bright when scanning.',
                        style: TextStyle(color: kSecondaryText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenQrPage(image: image),
                    ),
                  );
                },
                icon: const Icon(Icons.fullscreen),
                label: const Text('Show Full Screen'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddPassPage(passKey: passKey)),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Details'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: kPrimary),
                  foregroundColor: kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => _delete(context, box),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                label: const Text('Delete Pass', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, Box box) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete fuel pass?'),
        content: const Text('This removes the saved QR image and details from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await box.delete(passKey);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class FullScreenQrPage extends StatelessWidget {
  const FullScreenQrPage({super.key, required this.image});

  final Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.7,
          maxScale: 4,
          child: Image.memory(image, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('fuel_passes');

    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          final passes = box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          final total = passes.length;
          final active = passes.where((p) => p['active'] == true).length;
          final inactive = total - active;

          final counts = <String, int>{};
          for (final p in passes) {
            final type = p['vehicleType']?.toString() ?? 'Car';
            counts[type] = (counts[type] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
            children: [
              const Text('Statistics', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                'A quick view of your saved fuel passes.',
                style: TextStyle(color: kSecondaryText),
              ),
              const SizedBox(height: 18),
              _statCard('Total Passes', '$total', Icons.qr_code_2_rounded, kBlue),
              Row(
                children: [
                  Expanded(child: _smallStat('Active', '$active', Icons.check_circle_outline, const Color(0xFF4CB98A))),
                  const SizedBox(width: 12),
                  Expanded(child: _smallStat('Inactive', '$inactive', Icons.schedule_outlined, kGold)),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Passes by Vehicle Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...counts.entries.map(
                (entry) => Card(
                  child: ListTile(
                    leading: Icon(_icon(entry.key), color: kPrimary),
                    title: Text(entry.key),
                    trailing: Text(
                      '${entry.value}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: kSecondaryText)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallStat(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: kSecondaryText)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'Motorcycle':
        return Icons.two_wheeler;
      case 'Van':
        return Icons.airport_shuttle;
      case 'Truck':
        return Icons.local_shipping;
      default:
        return Icons.directions_car;
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.darkMode,
    required this.onDarkModeChanged,
  });

  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          const Text('Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          _sectionTitle('App'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  subtitle: Text('FuelPass Library • Offline QR storage'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Help & Support'),
                  subtitle: Text('For future app support information'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  subtitle: Text(darkMode ? 'On' : 'Off'),
                  value: darkMode,
                  onChanged: onDarkModeChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionTitle('About this version'),
          Card(
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FuelPass Library', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('Version 1.0.0'),
                  SizedBox(height: 6),
                  Text(
                    'Designed to keep your fuel pass QR codes easy to find and available offline.',
                    style: TextStyle(color: kSecondaryText),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: kSecondaryText,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
