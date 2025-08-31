import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme_provider.dart';
import 'age_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) => const ResultScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Age & Birthday Calculator',
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dob = ref.watch(dobProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Date of Birth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => themeNotifier.toggleTheme(),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Studio: Omniversify'),
                        Text('Developer: Phaylali'),
                        Text('Version: 1.0.1'),
                        SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Made with '),
                              WidgetSpan(
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ),
                              TextSpan(text: ' in Morocco'),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Powered by Flutter'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Licenses'),
              onTap: () {
                Navigator.pop(context);
                showLicensePage(context: context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Privacy Policy'),
                    content: const Text(
                      'This is a simple age calculator app that does not collect any personal data.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    ref.read(dobProvider.notifier).state = pickedDate;
                  }
                },
                child: Text(dob != null
                    ? 'Selected Date: ${dob.toString().split(' ')[0]}'
                    : 'Pick Your Date of Birth'),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  if (dob != null) {
                    context.go('/result');
                  }
                },
                child: const Text('Calculate Age'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dob = ref.watch(dobProvider);
    if (dob == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(
          child: Text('Invalid date of birth'),
        ),
      );
    }

    final now = DateTime.now();
    final ageDuration = now.difference(dob);
    final years = ageDuration.inDays ~/ 365;
    final months = (ageDuration.inDays % 365) ~/ 30;
    final days = (ageDuration.inDays % 365) % 30;
    final hours = ageDuration.inHours;
    final minutes = ageDuration.inMinutes;
    final seconds = ageDuration.inSeconds;

    // Calculate the next birthday
    DateTime nextBirthday = DateTime(now.year, dob.month, dob.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, dob.month, dob.day);
    }
    final daysUntilNextBirthday = nextBirthday.difference(now).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Age'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          'Years:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            '$years',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          'Months:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            '$months',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          'Days:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            '$days',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                ],
              ),
              Divider(height: 32.0, thickness: 2.0),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                },
                children: [
                  
                  
                  
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          'In Hours:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            '$hours',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          'In Minutes:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            '$minutes',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          'In Seconds:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            '$seconds',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Days until next birthday:',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              Text(
                '$daysUntilNextBirthday',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  context.go('/');
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
