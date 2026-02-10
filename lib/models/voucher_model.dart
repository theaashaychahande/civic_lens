enum VoucherStatus { available, redeemed, expired }

class Voucher {
  final String id;
  final String? userId;
  final String name;
  final int pointsRequired;
  final VoucherStatus status;
  final DateTime createdAt;

  Voucher({
    required this.id,
    this.userId,
    required this.name,
    required this.pointsRequired,
    required this.status,
    required this.createdAt,
  });

  factory Voucher.fromMap(Map<String, dynamic> map) {
    return Voucher(
      id: map['id'],
      userId: map['user_id'],
      name: map['voucher_name'],
      pointsRequired: map['points_required'],
      status: VoucherStatus.values.firstWhere((e) => e.name == map['status']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
