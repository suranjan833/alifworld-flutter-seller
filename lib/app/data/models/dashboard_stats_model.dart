class KpiMetric {
  final num value;
  final double? deltaPct;

  KpiMetric({required this.value, this.deltaPct});

  factory KpiMetric.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return KpiMetric(
        value: json['value'] is num ? json['value'] as num : 0,
        deltaPct: json['deltaPct'] != null ? (json['deltaPct'] as num).toDouble() : null,
      );
    }
    if (json is num) {
      return KpiMetric(value: json);
    }
    return KpiMetric(value: 0);
  }
}

class DashboardSeriesPoint {
  final String date; // YYYY-MM-DD
  final int revenueMinor; // minor units (poisha)
  final int orders;

  DashboardSeriesPoint({
    required this.date,
    required this.revenueMinor,
    required this.orders,
  });

  factory DashboardSeriesPoint.fromJson(Map<String, dynamic> json) {
    return DashboardSeriesPoint(
      date: json['date']?.toString() ?? '',
      revenueMinor: (json['revenue'] as num?)?.toInt() ?? (json['revenueMinor'] as num?)?.toInt() ?? 0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
    );
  }

  double get revenueTaka => revenueMinor / 100.0;
}

class DashboardFunnelItem {
  final String status;
  final int count;

  DashboardFunnelItem({
    required this.status,
    required this.count,
  });

  factory DashboardFunnelItem.fromJson(Map<String, dynamic> json) {
    return DashboardFunnelItem(
      status: json['status']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  String get displayStatus {
    if (status.isEmpty) return 'Unknown';
    return status.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }
}

class DashboardTopProduct {
  final String productId;
  final String name;
  final int revenueMinor;
  final int units;

  DashboardTopProduct({
    required this.productId,
    required this.name,
    required this.revenueMinor,
    required this.units,
  });

  factory DashboardTopProduct.fromJson(Map<String, dynamic> json) {
    final rawName = json['name']?.toString() ?? json['productName']?.toString();
    final pid = json['productId']?.toString() ?? json['id']?.toString() ?? '';
    return DashboardTopProduct(
      productId: pid,
      name: (rawName != null && rawName.isNotEmpty) ? rawName : (pid.isNotEmpty ? pid : 'Product'),
      revenueMinor: (json['revenue'] as num?)?.toInt() ?? (json['revenueMinor'] as num?)?.toInt() ?? 0,
      units: (json['units'] as num?)?.toInt() ?? (json['unitsSold'] as num?)?.toInt() ?? 0,
    );
  }

  double get revenueTaka => revenueMinor / 100.0;
}

class DashboardStatsModel {
  final String range;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final KpiMetric revenue;
  final KpiMetric orders;
  final KpiMetric unitsSold;
  final KpiMetric avgOrderValue;
  final List<DashboardSeriesPoint> series;
  final List<DashboardFunnelItem> funnel;
  final List<DashboardTopProduct> topProducts;
  final String currency;
  final String currencySymbol;
  final String currencySymbolPlacement;

  DashboardStatsModel({
    this.range = '30d',
    this.periodStart,
    this.periodEnd,
    required this.revenue,
    required this.orders,
    required this.unitsSold,
    required this.avgOrderValue,
    this.series = const [],
    this.funnel = const [],
    this.topProducts = const [],
    this.currency = 'BDT',
    this.currencySymbol = '৳',
    this.currencySymbolPlacement = 'left',
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final kpis = json['kpis'] as Map<String, dynamic>? ?? {};
    final period = json['period'] as Map<String, dynamic>? ?? {};

    final rawSeries = json['series'] as List<dynamic>? ?? [];
    final rawFunnel = json['funnel'] as List<dynamic>? ?? [];
    final rawTop = json['topProducts'] as List<dynamic>? ?? [];

    return DashboardStatsModel(
      range: json['range']?.toString() ?? '30d',
      periodStart: period['start'] != null ? DateTime.tryParse(period['start'].toString()) : null,
      periodEnd: period['end'] != null ? DateTime.tryParse(period['end'].toString()) : null,
      revenue: KpiMetric.fromJson(kpis['revenue']),
      orders: KpiMetric.fromJson(kpis['orders']),
      unitsSold: KpiMetric.fromJson(kpis['unitsSold']),
      avgOrderValue: KpiMetric.fromJson(kpis['avgOrderValue']),
      series: rawSeries.map((s) => DashboardSeriesPoint.fromJson(s as Map<String, dynamic>)).toList(),
      funnel: rawFunnel.map((f) => DashboardFunnelItem.fromJson(f as Map<String, dynamic>)).toList(),
      topProducts: rawTop.map((t) => DashboardTopProduct.fromJson(t as Map<String, dynamic>)).toList(),
      currency: json['currency']?.toString() ?? 'BDT',
      currencySymbol: json['currencySymbol']?.toString() ?? '৳',
      currencySymbolPlacement: json['currencySymbolPlacement']?.toString() ?? 'left',
    );
  }

  /// Formats any minor-unit amount using Call 1's currencySymbol and placement
  String formatMoney(num minorUnits) {
    final taka = minorUnits / 100.0;
    final formatted = taka.toStringAsFixed(taka.truncateToDouble() == taka ? 0 : 2);
    if (currencySymbolPlacement.toLowerCase() == 'right') {
      return '$formatted $currencySymbol';
    }
    return '$currencySymbol$formatted';
  }

  String get formattedRevenue => formatMoney(revenue.value);

  String get formattedAvgOrderValue => formatMoney(avgOrderValue.value);

  bool get hasSales => series.any((p) => p.revenueMinor > 0) || revenue.value > 0;

  bool get hasOrders => orders.value > 0 || funnel.any((f) => f.count > 0);
}

class AnalyticsSummaryModel {
  final int productsTotal;
  final int productsLive;
  final int productsPending;
  final int lowStockCount;
  final int couponsActive;
  final int reviewsPending;
  final int announcementsUnread;

  AnalyticsSummaryModel({
    this.productsTotal = 0,
    this.productsLive = 0,
    this.productsPending = 0,
    this.lowStockCount = 0,
    this.couponsActive = 0,
    this.reviewsPending = 0,
    this.announcementsUnread = 0,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      productsTotal: (json['productsTotal'] as num?)?.toInt() ?? 0,
      productsLive: (json['productsLive'] as num?)?.toInt() ?? 0,
      productsPending: (json['productsPending'] as num?)?.toInt() ?? 0,
      lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 0,
      couponsActive: (json['couponsActive'] as num?)?.toInt() ?? 0,
      reviewsPending: (json['reviewsPending'] as num?)?.toInt() ?? 0,
      announcementsUnread: (json['announcementsUnread'] as num?)?.toInt() ?? 0,
    );
  }
}
