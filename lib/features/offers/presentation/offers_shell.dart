import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/presentation/profile_tab.dart';
import 'new_offer_screen.dart';

/// Shell pós-login com navegação inferior de três abas:
/// Ofertas | Nova Oferta | Perfil.
///
/// Usa [IndexedStack] para preservar o estado de cada aba entre trocas
/// (formulário em andamento e scroll não são perdidos ao navegar).
class OffersShell extends ConsumerStatefulWidget {
  const OffersShell({super.key});

  @override
  ConsumerState<OffersShell> createState() => _OffersShellState();
}

class _OffersShellState extends ConsumerState<OffersShell> {
  int _currentIndex = 0;

  static const List<String> _tabTitles = <String>[
    'Ofertas',
    'Nova Oferta',
    'Perfil',
  ];

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_currentIndex]),
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          const _OffersFeedPlaceholder(),
          NewOfferScreen(onOfferSaved: () => _selectTab(0)),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectTab,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Ofertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Nova Oferta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

/// Placeholder elegante do feed de ofertas (Fase 3).
class _OffersFeedPlaceholder extends StatelessWidget {
  const _OffersFeedPlaceholder();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.storefront,
              size: 72,
              color: theme.colorScheme.primary,
              semanticLabel: 'Lojas',
            ),
            const SizedBox(height: 16),
            Text(
              'Feed de ofertas em breve!',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Em breve você acompanha aqui as melhores ofertas '
              'compartilhadas pela comunidade.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
