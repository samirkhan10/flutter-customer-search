import 'package:flutter/material.dart';

import 'data/customer_api.dart';
import 'data/customer_repository.dart';
import 'screens/customer_search_screen.dart';

void main() {
  final repository = CustomerRepository(CustomerApi());
  runApp(CustomerSearchApp(repository: repository));
}

class CustomerSearchApp extends StatelessWidget {
  const CustomerSearchApp({super.key, required this.repository});

  final CustomerRepository repository;

  @override
  Widget build(BuildContext context) {
    const buttonSize = Size.fromHeight(48);

    return MaterialApp(
      title: 'Customer Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: buttonSize),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(minimumSize: buttonSize),
        ),
      ),
      home: CustomerSearchScreen(repository: repository),
    );
  }
}
