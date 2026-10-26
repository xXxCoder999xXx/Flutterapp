import 'package:flutter_test/flutter_test.dart';

import 'package:identity_client/ui/home/view_models/home_view_model.dart';

void main() {
  test('starts with a zero counter', () {
    final viewModel = HomeViewModel();
    addTearDown(viewModel.dispose);

    expect(viewModel.counter, 0);
  });

  test('increments the counter and notifies listeners', () {
    final viewModel = HomeViewModel();
    addTearDown(viewModel.dispose);
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    viewModel.incrementCounter();

    expect(viewModel.counter, 1);
    expect(notifications, 1);
  });
}
