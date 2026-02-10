import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/issue_model.dart';

class ReportProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  Future<String?> submitReport({
    required String title,
    required String description,
    required File image,
    required double lat,
    required double lng,
  }) async {
    _setSubmitting(true);
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = '${const Uuid().v4()}.jpg';
      
      // 1. Upload Image
      await _supabase.storage.from('issue-images').upload(fileName, image);
      final imageUrl = _supabase.storage.from('issue-images').getPublicUrl(fileName);

      // 2. Mock AI Logic (MVP Rule-based)
      final category = _suggestCategory(title + ' ' + description);
      final priority = _suggestPriority(title + ' ' + description);

      // 3. Insert into Supabase
      await _supabase.from('issues').insert({
        'user_id': userId,
        'title': title,
        'description': description,
        'category': category,
        'latitude': lat,
        'longitude': lng,
        'image_url': imageUrl,
        'priority': priority.name,
        'status': 'reported',
      });

      // 4. Update user points (Reward for reporting)
      await _supabase.rpc('increment_user_points', params: {'points_to_add': 10});

      return null;
    } catch (e) {
      debugPrint('Error submitting report: $e');
      return e.toString();
    } finally {
      _setSubmitting(false);
    }
  }

  String _suggestCategory(String text) {
    text = text.toLowerCase();
    if (text.contains('pothole') || text.contains('road') || text.contains('crack')) return 'Roads';
    if (text.contains('garbage') || text.contains('waste') || text.contains('trash')) return 'Waste';
    if (text.contains('water') || text.contains('leak') || text.contains('pipe')) return 'Water';
    if (text.contains('light') || text.contains('electricity') || text.contains('wire')) return 'Electricity';
    return 'Other';
  }

  IssuePriority _suggestPriority(String text) {
    text = text.toLowerCase();
    if (text.contains('urgent') || text.contains('danger') || text.contains('broken pipe')) return IssuePriority.high;
    if (text.contains('smell') || text.contains('blocked')) return IssuePriority.medium;
    return IssuePriority.low;
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }
}
