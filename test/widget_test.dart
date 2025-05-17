import 'package:demo/widgets/places_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const NearbyPlacesApp());

    // Verify the app title is present
    expect(find.text('Discover Nearby'), findsOneWidget);

    // Verify the initial loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Finding nearby places...'), findsOneWidget);

    // Wait for the initial load to complete
    await tester.pumpAndSettle();

    // Verify either places are shown or error message appears
    final foundPlaces = find.byType(PlacesScrollView).evaluate().isNotEmpty;
    final foundError = find.textContaining('No places found').evaluate().isNotEmpty;
    
    expect(foundPlaces || foundError, isTrue);
  });
}