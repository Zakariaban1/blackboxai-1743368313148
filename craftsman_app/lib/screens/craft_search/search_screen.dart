import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/localization/app_localizations.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/providers/craft_search_provider.dart';
import 'package:craftsman_app/widgets/craftsman_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _currentSearch = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a craft',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() => _currentSearch = _searchController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                setState(() => _currentSearch = value);
              },
            ),
          ),
          Expanded(
            child: _currentSearch.isEmpty
                ? const Center(child: Text('Enter a craft to search'))
                : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final craftsmenAsync = ref.watch(craftSearchProvider(_currentSearch));
    
    return craftsmenAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (craftsmen) {
        if (craftsmen.isEmpty) {
          return const Center(child: Text('No craftsmen found'));
        }
        
        return ListView.builder(
          itemCount: craftsmen.length,
          itemBuilder: (context, index) {
            final craftsman = craftsmen[index];
            return CraftsmanCard(
              craftsman: craftsman,
              onTap: () {
                // TODO: Navigate to craftsman profile
              },
            );
          },
        );
      },
    );
  }
}