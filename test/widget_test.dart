import 'package:flutter_test/flutter_test.dart';

import 'package:identity_client/ui/core/identity_client_app.dart';
import 'package:identity_client/ui/home/view_models/home_view_model.dart';

void main() {
  testWidgets('increments the counter after a tap', (tester) async {
    final viewModel = HomeViewModel();
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(IdentityClientApp(homeViewModel: viewModel));

    expect(find.text('Identity Client'), findsOneWidget);
    expect(find.text('Walking Skeleton'), findsOneWidget);
    expect(find.text('Zählerstand: 0'), findsOneWidget);

    await tester.tap(find.byTooltip('Zähler erhöhen'));
    await tester.pump();

    expect(find.text('Zählerstand: 0'), findsNothing);
    expect(find.text('Zählerstand: 1'), findsOneWidget);
  });
}
