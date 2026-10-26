import 'package:flutter/material.dart';

import 'package:identity_client/ui/home/view_models/home_view_model.dart';
import 'package:identity_client/ui/home/widgets/home_screen.dart';

class IdentityClientApp extends StatelessWidget {
  const IdentityClientApp({required this.homeViewModel, super.key});

  final HomeViewModel homeViewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Identity Client',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.indigo)),
      home: HomeScreen(viewModel: homeViewModel),
    );
  }
}
