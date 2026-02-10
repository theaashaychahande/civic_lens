import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/civic_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      Provider.of<CivicProvider>(context, listen: false).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final civic = Provider.of<CivicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Hub'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1F3B57),
          indicatorColor: const Color(0xFF1F3B57),
          tabs: const [
            Tab(text: 'Announcements'),
            Tab(text: 'Discussions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnnouncementsTab(civic),
          _buildDiscussionsTab(),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsTab(CivicProvider civic) {
    if (civic.isLoading) return const Center(child: CircularProgressIndicator());
    if (civic.announcements.isEmpty) return const Center(child: Text('No announcements yet.'));

    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: civic.announcements.length,
        itemBuilder: (context, index) {
          final announcement = civic.announcements[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          announcement.ward ?? 'City-Wide',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(announcement.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    announcement.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    announcement.description ?? '',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscussionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDiscussionThread('General Discussion', 'Talk about anything related to the city.', 45),
        _buildDiscussionThread('Ward 5 Cleanup', 'Planning the weekend cleanup drive.', 12),
        _buildDiscussionThread('New Metro Line', 'Feedback on the new metro schedule.', 89),
        _buildDiscussionThread('Street Paving', 'Updates on the road work on Main St.', 5),
      ],
    );
  }

  Widget _buildDiscussionThread(String title, String subtitle, int commentCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.comment, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(commentCount.toString(), style: const TextStyle(color: Colors.grey)),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
