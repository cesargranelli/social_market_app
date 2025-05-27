import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../routing/routes.dart';
import '../widgets/feed_viewmodel.dart';
import '../widgets/feed_item.dart';

class FeedScreen extends StatefulWidget {
  final FeedViewModel viewModel;

  const FeedScreen({super.key, required this.viewModel});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rede de Ofertas")),
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
              return FeedItem(
                offer: snapshot.data![index],
                viewModel: widget.viewModel,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(Routes.publish);
        },
        child: const Icon(Icons.electric_bolt_rounded, color: Colors.black),
      ),
    );
  }
}
