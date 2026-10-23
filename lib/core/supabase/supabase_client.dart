import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static final SupabaseClient db = Supabase.instance.client;
}