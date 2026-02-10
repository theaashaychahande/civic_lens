import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_model.dart';
import '../models/user_model.dart';

class CivicProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<News> _news = [];
  int _totalIssues = 0;
  int _verifiedIssues = 0;
  bool _isLoading = false;

  List<News> get news => _news;
  int get totalIssues => _totalIssues;
  int get verifiedIssues => _verifiedIssues;
  bool get isLoading => _isLoading;

  Future<void> fetchHomeData() async {
    _setLoading(true);
    try {
      // Fetch News
      final newsRes = await _supabase
          .from('news')
          .select()
          .order('created_at', ascending: false)
          .limit(5);
      _news = (newsRes as List).map((e) => News.fromMap(e)).toList();

      // Fetch Stats
      final issuesCount = await _supabase
          .from('issues')
          .select('id', const FetchOptions(count: CountOption.exact));
      _totalIssues = issuesCount.count ?? 0;

  List<Issue> _issues = [];

  List<Issue> get issues => _issues;

  Future<void> fetchIssues({String? category, String? status}) async {
    _setLoading(true);
    try {
      dynamic query = _supabase.from('issues').select('''
        *,
        verifications_count:verifications(count)
      ''').order('created_at', ascending: false);

      if (category != null && category != 'All') {
        query = query.eq('category', category);
      }
      if (status != null && status != 'All') {
        query = query.eq('status', status.toLowerCase());
      }

      final res = await query;
      _issues = (res as List).map((e) {
        // Handle the count from Supabase response
        final map = Map<String, dynamic>.from(e);
        map['verifications_count'] = (e['verifications_count'] as List).isNotEmpty 
            ? e['verifications_count'][0]['count'] 
            : 0;
        return Issue.fromMap(map);
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching issues: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyIssue(String issueId, bool isValid) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('verifications').upsert({
        'issue_id': issueId,
        'user_id': userId,
        'is_valid': isValid,
      });
      // Optionally update local state or re-fetch
      await fetchIssues();
    } catch (e) {
      debugPrint('Error verifying issue: $e');
    }
  }

  List<Announcement> _announcements = [];

  List<Announcement> get announcements => _announcements;

  Future<void> fetchAnnouncements({String? ward}) async {
    _setLoading(true);
    try {
      dynamic query = _supabase
          .from('announcements')
          .select()
          .order('created_at', ascending: false);

      if (ward != null && ward != 'All') {
        query = query.eq('ward', ward);
      }

      final res = await query;
      _announcements = (res as List).map((e) => Announcement.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<Voucher> _vouchers = [];

  List<Voucher> get vouchers => _vouchers;

  Future<void> fetchVouchers() async {
    _setLoading(true);
    try {
      final res = await _supabase
          .from('rewards_vouchers')
          .select()
          .order('created_at', ascending: false);
      _vouchers = (res as List).map((e) => Voucher.fromMap(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching vouchers: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> redeemVoucher(Voucher voucher) async {
    try {
      final userRes = await _supabase.from('users').select('points').single();
      final currentPoints = userRes['points'] as int;

      if (currentPoints < voucher.pointsRequired) {
        return 'Insufficient points.';
      }

      await _supabase.from('rewards_vouchers').update({
        'status': 'redeemed',
      }).eq('id', voucher.id);

      await _supabase.rpc('increment_user_points', params: {
        'points_to_add': -voucher.pointsRequired
      });

      await fetchVouchers();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  RealtimeChannel? _issuesChannel;

  void subscribeToIssues() {
    _issuesChannel = _supabase
        .channel('public:issues')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'issues',
          callback: (payload) {
            fetchIssues(); // Refresh list on any change
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _issuesChannel?.unsubscribe();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
