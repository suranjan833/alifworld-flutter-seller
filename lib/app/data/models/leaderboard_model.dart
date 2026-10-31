class LeaderboardDataModel {
  final int myRank;
  final int totalSellers;
  final double myRevenue;
  final int myOrders;
  final String period;
  final List<LeaderboardSellerItem> sellers;

  LeaderboardDataModel({
    required this.myRank,
    required this.totalSellers,
    required this.myRevenue,
    required this.myOrders,
    this.period = 'weekly',
    required this.sellers,
  });

  String get formattedMyRevenue => '৳${myRevenue.toStringAsFixed(2)}';

  factory LeaderboardDataModel.fromJson(
    Map<String, dynamic> json, {
    String defaultPeriod = 'weekly',
    String currentSellerName = '',
  }) {
    // 1. My Rank
    final rankVal = json['myRank'] ?? json['my_rank'] ?? json['rank'] ?? json['currentRank'] ?? 1;
    final int rank = (rankVal as num?)?.toInt() ?? 1;

    // 2. Sellers list
    final rawList = (json['sellers'] ??
            json['topSellers'] ??
            json['top_sellers'] ??
            json['rankings'] ??
            json['leaderboard'] ??
            json['items'] ??
            json['rows'] ??
            []) as List<dynamic>;

    // 3. Total Sellers
    final totalVal = json['totalSellers'] ??
        json['total_sellers'] ??
        json['total'] ??
        json['sellersCount'] ??
        rawList.length;
    final int total = (totalVal as num?)?.toInt() ?? (rawList.isNotEmpty ? rawList.length : 1);

    // 4. Revenue (In Alifworld API contract, money is in minor units e.g. 84000 = ৳840.00)
    final revVal = json['myRevenueMinor'] ??
        json['my_revenue_minor'] ??
        json['myRevenue'] ??
        json['my_revenue'] ??
        json['revenueMinor'] ??
        json['revenue'] ??
        json['totalRevenue'] ??
        json['sales'] ??
        0;
    double revDouble = (revVal as num?)?.toDouble() ?? 0.0;
    if (revVal is int && revVal >= 100) {
      revDouble = revVal / 100.0;
    }

    // 5. Orders
    final ordersVal = json['myOrders'] ??
        json['my_orders'] ??
        json['orders'] ??
        json['totalOrders'] ??
        json['orderCount'] ??
        0;
    final int orders = (ordersVal as num?)?.toInt() ?? 0;

    final sellersList = rawList.asMap().entries.map((entry) {
      final index = entry.key;
      final map = entry.value;
      if (map is Map<String, dynamic>) {
        return LeaderboardSellerItem.fromJson(map, index + 1, currentSellerName: currentSellerName);
      }
      return LeaderboardSellerItem(
        rank: index + 1,
        shopName: map.toString(),
        isYou: false,
        orders: 0,
        revenue: 0.0,
      );
    }).toList();

    return LeaderboardDataModel(
      myRank: rank,
      totalSellers: total > 0 ? total : (sellersList.isNotEmpty ? sellersList.length : 1),
      myRevenue: revDouble,
      myOrders: orders,
      period: json['period']?.toString() ?? defaultPeriod,
      sellers: sellersList,
    );
  }
}

class LeaderboardSellerItem {
  final int rank;
  final String shopName;
  final bool isYou;
  final int orders;
  final double revenue;

  LeaderboardSellerItem({
    required this.rank,
    required this.shopName,
    required this.isYou,
    required this.orders,
    required this.revenue,
  });

  String get formattedRevenue => '৳${revenue.toStringAsFixed(2)}';

  factory LeaderboardSellerItem.fromJson(
    Map<String, dynamic> json,
    int defaultRank, {
    String currentSellerName = '',
  }) {
    final name = json['shopName']?.toString() ??
        json['shop_name']?.toString() ??
        json['shop']?['name']?.toString() ??
        json['name']?.toString() ??
        json['sellerName']?.toString() ??
        json['seller']?['shopName']?.toString() ??
        'Shop';

    final isCurrent = json['isYou'] == true ||
        json['is_you'] == true ||
        json['isCurrent'] == true ||
        json['isCurrentSeller'] == true ||
        (currentSellerName.isNotEmpty &&
            name.toLowerCase().trim() == currentSellerName.toLowerCase().trim()) ||
        (currentSellerName.isNotEmpty &&
            name.toLowerCase().contains(currentSellerName.toLowerCase()));

    final revVal = json['revenue'] ??
        json['revenueMinor'] ??
        json['revenue_minor'] ??
        json['sales'] ??
        json['amount'] ??
        0;

    double revDouble = (revVal as num?)?.toDouble() ?? 0.0;
    if (revVal is int && revVal >= 100) {
      revDouble = revVal / 100.0;
    }

    final ordersVal = json['orders'] ??
        json['orderCount'] ??
        json['ordersCount'] ??
        json['orders_count'] ??
        json['totalOrders'] ??
        0;

    return LeaderboardSellerItem(
      rank: (json['rank'] as num?)?.toInt() ?? defaultRank,
      shopName: name,
      isYou: isCurrent,
      orders: (ordersVal as num?)?.toInt() ?? 0,
      revenue: revDouble,
    );
  }
}
