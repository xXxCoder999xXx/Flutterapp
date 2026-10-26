import 'package:flutter/material.dart';

import 'package:identity_client/ui/core/identity_client_app.dart';
import 'package:identity_client/ui/home/view_models/home_view_model.dart';

void main() {
  runApp(IdentityClientApp(homeViewModel: HomeViewModel()));
}
