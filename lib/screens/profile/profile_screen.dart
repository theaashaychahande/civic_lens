import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/civic_provider.dart';
import '../../models/voucher_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      Provider.of<CivicProvider>(context, listen: false).fetchVouchers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final civic = Provider.of<CivicProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Civic Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildPointsWallet(user?.points ?? 0),
              const SizedBox(height: 24),
              _buildSectionHeader('Available Rewards'),
              const SizedBox(height: 12),
              _buildVouchersList(civic),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => auth.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFF1F3B57),
          child: user?.profilePicture != null
              ? ClipOval(child: Image.network(user.profilePicture!, fit: BoxFit.cover))
              : const Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'Loading...',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user?.email ?? '',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPointsWallet(int points) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F3B57),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Civic Points Balance', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 4),
              Text('Points Earning Member', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(
                points.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildVouchersList(CivicProvider civic) {
    if (civic.isLoading) return const Center(child: CircularProgressIndicator());
    if (civic.vouchers.isEmpty) return const Center(child: Text('Check back later for rewards!'));

    return Column(
      children: civic.vouchers.map((v) => _buildVoucherCard(v)).toList(),
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    final bool isRedeemed = voucher.status == VoucherStatus.redeemed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isRedeemed ? Colors.grey[100] : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isRedeemed ? Icons.local_activity : Icons.card_giftcard,
            color: isRedeemed ? Colors.grey : Colors.green,
          ),
        ),
        title: Text(
          voucher.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isRedeemed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${voucher.pointsRequired} Points required'),
        trailing: isRedeemed
            ? const Text('REDEEMED', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))
            : ElevatedButton(
                onPressed: () => _redeemVoucher(voucher),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8A3D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Redeem'),
              ),
      ),
    );
  }

  void _redeemVoucher(Voucher voucher) async {
    final civic = Provider.of<CivicProvider>(context, listen: false);
    final error = await civic.redeemVoucher(voucher);

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voucher redeemed successfully!')),
        );
      }
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              trailing: Switch(value: Theme.of(context).brightness == Brightness.dark, onChanged: (val) {
                // In a real app, this would be handled by a ThemeProvider
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme logic would be toggled here.')));
                Navigator.pop(context);
              }),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none_outlined),
              title: const Text('Notifications'),
              trailing: Switch(value: true, onChanged: (val) {}),
            ),
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Language (Auto-Detect)'),
              trailing: const Text('English', style: TextStyle(color: Colors.blue)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
