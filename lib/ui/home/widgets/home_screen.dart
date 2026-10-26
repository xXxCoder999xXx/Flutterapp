import 'package:flutter/material.dart';

import 'package:identity_client/ui/home/view_models/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.viewModel, super.key});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Client')),
      body: Center(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, child) {
            return Column(
              mainAxisSize: .min,
              children: [
                Text(
                  'Walking Skeleton',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'Zählerstand: ${viewModel.counter}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.incrementCounter,
        tooltip: 'Zähler erhöhen',
        child: const Icon(Icons.add),
      ),
    );
  }
}
