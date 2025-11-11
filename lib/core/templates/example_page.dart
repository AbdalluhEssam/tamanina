import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

/// Example page template showing the correct structure
/// with SafeArea, Scaffold, CustomScrollView, and CustomAppBar
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const CustomAppBar(title: 'Example'),
            SliverFillRemaining(
              child: Center(
                child: Text('Page Content'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
