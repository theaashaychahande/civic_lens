import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/civic_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CivicProvider>(context, listen: false).fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final civic = Provider.of<CivicProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () => civic.fetchHomeData(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF1F3B57),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Hello, ${user?.name ?? 'Citizen'}!',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                background: Container(color: const Color(0xFF1F3B57)),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(civic, user?.points ?? 0),
                    const SizedBox(height: 24),
                    _buildSectionHeader('City News', () {}),
                    const SizedBox(height: 12),
                    _buildNewsList(civic),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Upcoming Initiatives', () {}),
                    const SizedBox(height: 12),
                    _buildSponsoredCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(CivicProvider civic, int points) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 0.8,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard('Issues', civic.totalIssues.toString(), Icons.report_problem, Colors.orange),
        _buildStatCard('Verified', civic.verifiedIssues.toString(), Icons.verified_user, Colors.green),
        _buildStatCard('Points', points.toString(), Icons.stars, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildNewsList(CivicProvider civic) {
    if (civic.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (civic.news.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('No news available right now.')),
      );
    }
    return Column(
      children: civic.news.map((n) => _buildNewsItem(n)).toList(),
    );
  }

  Widget _buildNewsItem(dynamic news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            image: news.imageUrl != null
                ? DecorationImage(image: NetworkImage(news.imageUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: news.imageUrl == null ? const Icon(Icons.newspaper) : null,
        ),
        title: Text(
          news.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          news.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildSponsoredCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F3B57), Color(0xFF2C537B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clean City, Green City',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Join our weekend cleanup drive in Ward 5 and earn 50 bonus points!',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F8A3D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Join Now'),
          ),
        ],
      ),
    );
  }
}
