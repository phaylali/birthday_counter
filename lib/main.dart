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
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
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
        ],
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
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          'Hours:',
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
                          'Minutes:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            '$minutes',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const TableCell(
                        child: Text(
                          'Seconds:',
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      TableCell(
                        child: Center(
                          child: Text(
                            '$seconds',
                            style: const TextStyle(fontSize: 14),
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
