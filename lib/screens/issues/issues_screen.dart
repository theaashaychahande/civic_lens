import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/civic_provider.dart';
import '../../models/issue_model.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final List<String> _categories = ['All', 'Waste', 'Roads', 'Water', 'Electricity', 'Other'];
  final List<String> _statuses = ['All', 'Reported', 'Verified', 'In_progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _loadIssues();
    Future.microtask(() {
      Provider.of<CivicProvider>(context, listen: false).subscribeToIssues();
    });
  }

  void _loadIssues() {
    Future.microtask(() {
      Provider.of<CivicProvider>(context, listen: false).fetchIssues(
        category: _selectedCategory,
        status: _selectedStatus,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final civic = Provider.of<CivicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('City Issues'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadIssues(),
        child: civic.isLoading
            ? const Center(child: CircularProgressIndicator())
            : civic.issues.isEmpty
                ? const Center(child: Text('No issues found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: civic.issues.length,
                    itemBuilder: (context, index) {
                      return _buildIssueCard(civic.issues[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterDropdown('Category', _categories, _selectedCategory, (val) {
            setState(() => _selectedCategory = val!);
            _loadIssues();
          }),
          const SizedBox(width: 12),
          _buildFilterDropdown('Status', _statuses, _selectedStatus, (val) {
            setState(() => _selectedStatus = val!);
            _loadIssues();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> items, String currentVal, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentVal,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildIssueCard(Issue issue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (issue.imageUrl != null)
            Image.network(
              issue.imageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            Container(
              height: 120,
              color: Colors.grey[200],
              width: double.infinity,
              child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
            ),
          Padding(
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
                        color: _getStatusColor(issue.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        issue.status.name.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(issue.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat.yMMMd().format(issue.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  issue.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  issue.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${issue.verificationsCount} verifications',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showVerifyDialog(issue),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Verify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3B57),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.reported: return Colors.orange;
      case IssueStatus.verified: return Colors.blue;
      case IssueStatus.in_progress: return Colors.purple;
      case IssueStatus.resolved: return Colors.green;
    }
  }

  void _showVerifyDialog(Issue issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Issue'),
        content: const Text('Do you believe this report is valid?'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<CivicProvider>(context, listen: false).verifyIssue(issue.id, false);
              Navigator.pop(context);
            },
            child: const Text('Fake', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<CivicProvider>(context, listen: false).verifyIssue(issue.id, true);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Valid'),
          ),
        ],
      ),
    );
  }
}
