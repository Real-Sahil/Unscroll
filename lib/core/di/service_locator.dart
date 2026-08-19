import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service locator setup for dependency injection
/// All services and repositories should be registered here

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final authProvider = Provider((ref) {
  return ref.watch(supabaseProvider).auth;
});

/// Example of a service provider setup
/// Add more providers here as services are implemented
