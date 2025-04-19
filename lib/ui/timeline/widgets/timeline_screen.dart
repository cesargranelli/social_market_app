// DeepSeek
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class TimelineScreen extends StatelessWidget {
  TimelineScreen({super.key});

  // Dados fictícios para a timeline
  final List<TimelineItem> items = [
    TimelineItem(
      title: "Evento 1",
      description: "Descrição do primeiro evento.",
      time: "10:00 AM",
      icon: Icons.event,
      color: Colors.blue,
    ),
    TimelineItem(
      title: "Evento 2",
      description: "Descrição do segundo evento.",
      time: "12:30 PM",
      icon: Icons.work,
      color: Colors.green,
    ),
    TimelineItem(
      title: "Evento 3",
      description: "Descrição do terceiro evento.",
      time: "03:15 PM",
      icon: Icons.school,
      color: Colors.orange,
    ),
    TimelineItem(
      title: "Evento 4",
      description: "Descrição do quarto evento.",
      time: "06:45 PM",
      icon: Icons.restaurant,
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder:
                      (context) => ProfileScreen(
                        appBar: AppBar(title: const Text("User Profile")),
                        actions: [
                          SignedOutAction((context) {
                            Navigator.of(context).pop();
                          }),
                        ],
                        children: [
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.asset('flutterfire_300x.png'),
                            ),
                          ),
                        ],
                      ),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return TimelineCard(
            item: items[index],
            isFirst: index == 0,
            isLast: index == items.length - 1,
          );
        },
      ),
      //Center(
      //  child: Column(
      //    children: [
      //Image.asset("dash.png", width: 400),
      //Text("Welcome!", style: Theme.of(context).textTheme.displaySmall),
      //const SignOutButton(variant: ButtonVariant.outlined),
      //    ],
      //  ),
      //),
    );
  }
}

class TimelineItem {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;

  TimelineItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
  });
}

class TimelineCard extends StatelessWidget {
  final TimelineItem item;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha da timeline (esquerda)
        Column(
          children: [
            // Espaço vazio no início (se não for o primeiro item)
            if (!isFirst)
              Container(width: 2, height: 20, color: Colors.grey[300]),
            // Ícone central
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.color,
              ),
              child: Icon(item.icon, color: Colors.white, size: 20),
            ),
            // Espaço vazio no final (se não for o último item)
            if (!isLast)
              Container(width: 2, height: 20, color: Colors.grey[300]),
          ],
        ),
        SizedBox(width: 16),
        // Card do evento
        Expanded(
          child: Card(
            elevation: 2,
            margin: EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 4),
                      Text(item.time),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
