import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:craftsman_app/models/user_model.dart';
import 'package:craftsman_app/services/user_repository.dart';

final craftSearchProvider = FutureProvider.family<List<AppUser>, String>(
  (ref, craft) async {
    final repository = UserRepository();
    return await repository.searchCraftsmen(craft);
  },
);