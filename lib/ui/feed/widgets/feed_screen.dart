import 'package:flutter/material.dart';

import '../../offer/widgets/offer_item.dart';
import '../../publish/widgets/publish_screen.dart';
import '../view_models/feed_viewmodel.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.viewModel});

  final FeedViewModel viewModel;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Future<void> _publishScreen(BuildContext context) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const PublishScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );

    if (!context.mounted) return;

    if (result != null) {
      setState(() {
        widget.viewModel.addOffer(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Market")),
      body: FutureBuilder(
        future: widget.viewModel.getFeedOffers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No offers available'));
          }
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              return OfferItem(item: snapshot.data![index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _publishScreen(context),
        child: const Icon(Icons.electric_bolt_rounded, color: Colors.black),
      ),
    );
  }
}
