class DailyRevenuePoint {
  final String date;
  final double revenue;

  DailyRevenuePoint({required this.date, required this.revenue});

  factory DailyRevenuePoint.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final rawDate = json['date'] ?? json['day'] ?? json['label'] ?? '';
      String formattedDate = rawDate.toString();
      if (formattedDate.contains('T')) {
        formattedDate = formattedDate.split('T').first;
      }
      if (formattedDate.length >= 10 && formattedDate.contains('-')) {
        final parts = formattedDate.split('-');
        if (parts.length >= 3) {
          formattedDate = '${parts[1]}-${parts[2]}';
        }
      }

      final rev = json['revenueMinor'] ??
          json['revenue_minor'] ??
          json['revenue'] ??
          json['amount'] ??
          json['total'] ??
          json['value'] ??
          0;
      double revVal = (rev as num?)?.toDouble() ?? 0.0;
      if (rev is int && rev >= 100) {
        revVal = rev / 100.0;
      } else if (json.containsKey('revenueMinor') || json.containsKey('revenue_minor')) {
        revVal = revVal / 100.0;
      }

      return DailyRevenuePoint(date: formattedDate, revenue: revVal);
    }
    return DailyRevenuePoint(date: '', revenue: 0.0);
  }
}

class TopProductItem {
  final String name;
  final int units;
  final double revenue;

  TopProductItem({
    required this.name,
    required this.units,
    required this.revenue,
  });

  String get formattedRevenue => '৳${revenue.toStringAsFixed(2)}';

  factory TopProductItem.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ??
        json['title'] ??
        json['productName'] ??
        json['product_name'] ??
        'Product';

    final units = json['units'] ??
        json['unitsSold'] ??
        json['units_sold'] ??
        json['quantity'] ??
        json['count'] ??
        0;

    final rev = json['revenueMinor'] ??
        json['revenue_minor'] ??
        json['revenue'] ??
        json['amount'] ??
        json['totalRevenue'] ??
        0;
    double revVal = (rev as num?)?.toDouble() ?? 0.0;
    if (rev is int && rev >= 100) {
      revVal = rev / 100.0;
    } else if (json.containsKey('revenueMinor') || json.containsKey('revenue_minor')) {
      revVal = revVal / 100.0;
    }

    return TopProductItem(
      name: name.toString(),
      units: (units as num?)?.toInt() ?? 0,
      revenue: revVal,
    );
  }
}

class OrderFunnelData {
  final int pending;
  final int delivered;
  final int cancelled;

  OrderFunnelData({
    this.pending = 0,
    this.delivered = 0,
    this.cancelled = 0,
  });

  int get total => pending + delivered + cancelled;

  factory OrderFunnelData.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return OrderFunnelData(
        pending: (json['pending'] as num?)?.toInt() ??
            (json['processing'] as num?)?.toInt() ??
            (json['placed'] as num?)?.toInt() ??
            0,
        delivered: (json['delivered'] as num?)?.toInt() ??
            (json['completed'] as num?)?.toInt() ??
            0,
        cancelled: (json['cancelled'] as num?)?.toInt() ??
            (json['canceled'] as num?)?.toInt() ??
            0,
      );
    }
    return OrderFunnelData();
  }
}

class PaymentSplitItem {
  final String method;
  final int orders;
  final int revenueMinor;

  PaymentSplitItem({
    required this.method,
    required this.orders,
    required this.revenueMinor,
  });

  factory PaymentSplitItem.fromJson(Map<String, dynamic> json) {
    return PaymentSplitItem(
      method: json['method']?.toString().toLowerCase() ?? 'unknown',
      orders: (json['orders'] as num?)?.toInt() ?? 0,
      revenueMinor: (json['revenueMinor'] as num?)?.toInt() ?? (json['revenue'] as num?)?.toInt() ?? 0,
    );
  }

  String get displayMethod {
    switch (method.toLowerCase()) {
      case 'cod':
      case 'cash':
        return 'COD';
      case 'bkash':
        return 'bKash';
      case 'nagad':
        return 'Nagad';
      case 'wallet':
        return 'Wallet';
      default:
        return method.isNotEmpty ? '${method[0].toUpperCase()}${method.substring(1)}' : 'Other';
    }
  }

  double get revenueTaka => revenueMinor / 100.0;
}

class RatingDistItem {
  final int stars;
  final int count;

  RatingDistItem({
    required this.stars,
    required this.count,
  });

  factory RatingDistItem.fromJson(Map<String, dynamic> json) {
    return RatingDistItem(
      stars: (json['stars'] as num?)?.toInt() ?? 5,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class PaymentMethodsData {
  final int codCount;
  final double codPct;
  final int walletCount;
  final double walletPct;
  final int totalCount;

  PaymentMethodsData({
    this.codCount = 0,
    this.codPct = 0.0,
    this.walletCount = 0,
    this.walletPct = 0.0,
    this.totalCount = 0,
  });

  factory PaymentMethodsData.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      int cod = 0;
      int wallet = 0;
      double codPercent = 0.0;
      double walletPercent = 0.0;

      if (json.containsKey('cod') || json.containsKey('wallet')) {
        final codVal = json['cod'];
        if (codVal is Map) {
          cod = (codVal['count'] as num?)?.toInt() ?? 0;
          codPercent = (codVal['percentage'] as num?)?.toDouble() ?? 0.0;
        } else if (codVal is num) {
          cod = codVal.toInt();
        }

        final walletVal = json['wallet'];
        if (walletVal is Map) {
          wallet = (walletVal['count'] as num?)?.toInt() ?? 0;
          walletPercent = (walletVal['percentage'] as num?)?.toDouble() ?? 0.0;
        } else if (walletVal is num) {
          wallet = walletVal.toInt();
        }
      }

      int total = cod + wallet;
      if (json.containsKey('total') && (json['total'] as num?) != null) {
        total = (json['total'] as num).toInt();
      }

      if (total > 0 && codPercent == 0.0 && walletPercent == 0.0) {
        codPercent = ((cod / total) * 100);
        walletPercent = ((wallet / total) * 100);
      }

      return PaymentMethodsData(
        codCount: cod,
        codPct: codPercent,
        walletCount: wallet,
        walletPct: walletPercent,
        totalCount: total > 0 ? total : (cod + wallet),
      );
    } else if (json is List) {
      int cod = 0;
      int wallet = 0;
      for (var item in json) {
        if (item is Map<String, dynamic>) {
          final method = (item['method'] ?? item['name'] ?? '').toString().toLowerCase();
          final count = (item['count'] as num?)?.toInt() ?? 0;
          if (method.contains('cod') || method.contains('cash')) {
            cod = count;
          } else if (method.contains('wallet') || method.contains('online') || method.contains('card')) {
            wallet = count;
          }
        }
      }
      final total = cod + wallet;
      final codP = total > 0 ? (cod / total * 100) : 0.0;
      final walP = total > 0 ? (wallet / total * 100) : 0.0;
      return PaymentMethodsData(
        codCount: cod,
        codPct: codP,
        walletCount: wallet,
        walletPct: walP,
        totalCount: total,
      );
    }
    return PaymentMethodsData();
  }
}

class CouponPerformanceItem {
  final String code;
  final String type; // 'percent' or 'flat'
  final num value;
  final int usedCount;
  final bool isActive;
  final double discountAmount;

  CouponPerformanceItem({
    required this.code,
    this.type = 'percent',
    this.value = 0,
    required this.usedCount,
    this.isActive = true,
    this.discountAmount = 0.0,
  });

  factory CouponPerformanceItem.fromJson(Map<String, dynamic> json) {
    final disc = json['discountMinor'] ??
        json['discount_minor'] ??
        json['discount'] ??
        json['totalDiscount'] ??
        0;
    double discVal = (disc as num?)?.toDouble() ?? 0.0;
    if (disc is int && disc >= 100) {
      discVal = disc / 100.0;
    }

    final rawVal = json['value'] ?? json['discountValue'] ?? json['amount'] ?? 0;
    final numVal = (rawVal as num?) ?? 0;

    return CouponPerformanceItem(
      code: json['code']?.toString() ?? json['couponCode']?.toString() ?? 'COUPON',
      type: json['type']?.toString().toLowerCase() ?? 'percent',
      value: numVal,
      usedCount: (json['usedCount'] ?? json['count'] ?? json['uses'] ?? 0) as int,
      isActive: json['isActive'] == true || json['active'] == true,
      discountAmount: discVal > 0 ? discVal : (numVal is int && numVal >= 100 ? numVal / 100.0 : numVal.toDouble()),
    );
  }

  String formatDiscount([String symbol = '৳']) {
    if (type == 'percent') {
      return '$value%';
    }
    final taka = value / 100.0;
    return '$symbol${taka.toStringAsFixed(taka.truncateToDouble() == taka ? 0 : 2)}';
  }
}

class AnalyticsDashboardModel {
  final String range;
  final double revenue;
  final int orders;
  final int unitsSold;
  final double avgOrderValue;
  final double cancellationRate;
  final double? avgRating;
  final int customers;
  final double repeatCustomersPct;
  final int lowStockVariants;
  final int reviewCount;

  final List<DailyRevenuePoint> revenueOverTime;
  final List<TopProductItem> topProducts;
  final OrderFunnelData orderFunnel;
  final PaymentMethodsData paymentMethods;
  final List<PaymentSplitItem> paymentSplit;
  final List<RatingDistItem> ratingDist;
  final Map<int, int> starRatings;
  final int approvedReviewsCount;
  final List<CouponPerformanceItem> coupons;

  AnalyticsDashboardModel({
    this.range = '30d',
    this.revenue = 0.0,
    this.orders = 0,
    this.unitsSold = 0,
    this.avgOrderValue = 0.0,
    this.cancellationRate = 0.0,
    this.avgRating,
    this.customers = 0,
    this.repeatCustomersPct = 0.0,
    this.lowStockVariants = 0,
    this.reviewCount = 0,
    required this.revenueOverTime,
    required this.topProducts,
    required this.orderFunnel,
    required this.paymentMethods,
    this.paymentSplit = const [],
    this.ratingDist = const [],
    required this.starRatings,
    this.approvedReviewsCount = 0,
    required this.coupons,
  });

  String get formattedRevenue => '৳${revenue.toStringAsFixed(revenue.truncateToDouble() == revenue ? 0 : 2)}';
  String get formattedAvgOrderValue => '৳${avgOrderValue.toStringAsFixed(avgOrderValue.truncateToDouble() == avgOrderValue ? 0 : 2)}';
  String get formattedCancellationRate => '${cancellationRate.toStringAsFixed(cancellationRate.truncateToDouble() == cancellationRate ? 0 : 1)}%';
  String get formattedRepeatCustomers => '${repeatCustomersPct.toStringAsFixed(repeatCustomersPct.truncateToDouble() == repeatCustomersPct ? 0 : 1)}%';
  String get formattedAvgRating => avgRating != null && avgRating! > 0 ? avgRating!.toStringAsFixed(1) : '—';

  int get totalReviews => reviewCount > 0 ? reviewCount : approvedReviewsCount;

  factory AnalyticsDashboardModel.fromJson(Map<String, dynamic> json, {int? fallbackLowStock}) {
    final kpis = json['kpis'] as Map<String, dynamic>? ?? {};

    // 1. Revenue
    double revDouble = 0.0;
    final rawRev = json['revenueMinor'] ??
        json['revenue_minor'] ??
        json['revenue'] ??
        kpis['revenue'] ??
        kpis['revenueMinor'];
    if (rawRev is Map) {
      final v = rawRev['value'];
      if (v is num) {
        revDouble = v >= 100 ? v / 100.0 : v.toDouble();
      }
    } else if (rawRev is num) {
      revDouble = rawRev >= 100 ? rawRev / 100.0 : rawRev.toDouble();
    }

    // 2. Orders
    int ordersVal = 0;
    final rawOrders = json['orders'] ?? json['totalOrders'] ?? kpis['orders'];
    if (rawOrders is Map) {
      ordersVal = (rawOrders['value'] as num?)?.toInt() ?? 0;
    } else if (rawOrders is num) {
      ordersVal = rawOrders.toInt();
    }

    // 3. Units sold
    int unitsVal = 0;
    final rawUnits = json['unitsSold'] ?? json['units_sold'] ?? kpis['unitsSold'];
    if (rawUnits is Map) {
      unitsVal = (rawUnits['value'] as num?)?.toInt() ?? 0;
    } else if (rawUnits is num) {
      unitsVal = rawUnits.toInt();
    }

    // 4. Avg Order Value
    double aovDouble = 0.0;
    final rawAov = json['avgOrderValue'] ??
        json['avg_order_value'] ??
        json['avgOrderValueMinor'] ??
        json['aov'] ??
        kpis['avgOrderValue'] ??
        kpis['avgOrderValueMinor'];
    if (rawAov is Map) {
      final v = rawAov['value'];
      if (v is num) {
        aovDouble = v >= 100 ? v / 100.0 : v.toDouble();
      }
    } else if (rawAov is num) {
      aovDouble = rawAov >= 100 ? rawAov / 100.0 : rawAov.toDouble();
    } else if (ordersVal > 0 && revDouble > 0) {
      aovDouble = revDouble / ordersVal;
    }

    // 5. Cancellation Rate
    double cancelRate = 0.0;
    final rawCancel = json['cancellationRate'] ??
        json['cancellationRatePct'] ??
        json['cancellation_rate'] ??
        kpis['cancellationRate'] ??
        kpis['cancellationRatePct'];
    if (rawCancel is Map) {
      cancelRate = (rawCancel['value'] as num?)?.toDouble() ?? 0.0;
    } else if (rawCancel is num) {
      cancelRate = rawCancel.toDouble();
    }
    if (cancelRate > 0 && cancelRate <= 1.0) {
      cancelRate *= 100;
    }

    // 6. Avg Rating & Review Count
    double? ratingVal;
    final rawRating = json['avgRating'] ?? json['avg_rating'] ?? kpis['avgRating'];
    if (rawRating is Map) {
      ratingVal = (rawRating['value'] as num?)?.toDouble();
    } else if (rawRating is num && rawRating > 0) {
      ratingVal = rawRating.toDouble();
    }

    int revCountVal = 0;
    final rawRevCount = json['reviewCount'] ?? json['reviewsCount'] ?? kpis['reviewCount'];
    if (rawRevCount is Map) {
      revCountVal = (rawRevCount['value'] as num?)?.toInt() ?? 0;
    } else if (rawRevCount is num) {
      revCountVal = rawRevCount.toInt();
    }

    // 7. Customers
    int customersVal = 0;
    final rawCust = json['customers'] ?? json['totalCustomers'] ?? kpis['customers'];
    if (rawCust is Map) {
      customersVal = (rawCust['value'] as num?)?.toInt() ?? 0;
    } else if (rawCust is num) {
      customersVal = rawCust.toInt();
    }

    // 8. Repeat Customers
    double repeatPct = 0.0;
    final rawRepeat = json['repeatCustomers'] ??
        json['repeatCustomerRatePct'] ??
        json['repeat_customers'] ??
        json['repeatCustomerRate'] ??
        kpis['repeatCustomers'] ??
        kpis['repeatCustomerRatePct'];
    if (rawRepeat is Map) {
      repeatPct = (rawRepeat['value'] as num?)?.toDouble() ?? 0.0;
    } else if (rawRepeat is num) {
      repeatPct = rawRepeat.toDouble();
    }
    if (repeatPct > 0 && repeatPct <= 1.0) {
      repeatPct *= 100;
    }

    // Low stock count
    final lowStock = (json['lowStockVariants'] ??
            json['low_stock_variants'] ??
            json['lowStockCount'] ??
            kpis['lowStockCount'] ??
            fallbackLowStock ??
            0) as num;

    // Revenue over time
    final rawSeries = json['revenueSeries'] ??
        json['revenueOverTime'] ??
        json['revenue_over_time'] ??
        json['dailyRevenue'] ??
        json['chart'] ??
        json['series'] ??
        [];
    final seriesList = <DailyRevenuePoint>[];
    if (rawSeries is List) {
      for (var p in rawSeries) {
        seriesList.add(DailyRevenuePoint.fromJson(p));
      }
    }

    // Top products
    final rawTop = json['topProducts'] ??
        json['top_products'] ??
        json['bestSellers'] ??
        [];
    final topList = <TopProductItem>[];
    if (rawTop is List) {
      for (var item in rawTop) {
        if (item is Map<String, dynamic>) {
          topList.add(TopProductItem.fromJson(item));
        }
      }
    }

    // Order funnel
    final funnel = OrderFunnelData.fromJson(
        json['statusFunnel'] ?? json['orderFunnel'] ?? json['order_funnel'] ?? json['funnel'] ?? {});

    // Payment methods & payment split
    final payments = PaymentMethodsData.fromJson(
        json['paymentSplit'] ?? json['paymentMethods'] ?? json['payment_methods'] ?? json['payments'] ?? {});

    final rawSplit = json['paymentSplit'] ?? json['payments'] ?? [];
    final splitList = <PaymentSplitItem>[];
    if (rawSplit is List) {
      for (var s in rawSplit) {
        if (s is Map<String, dynamic>) {
          splitList.add(PaymentSplitItem.fromJson(s));
        }
      }
    }

    // Star ratings breakdown & ratingDist
    final stars = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    final distList = <RatingDistItem>[];
    final rawDist = json['ratingDist'] ?? [];
    if (rawDist is List && rawDist.isNotEmpty) {
      for (var d in rawDist) {
        if (d is Map<String, dynamic>) {
          final item = RatingDistItem.fromJson(d);
          distList.add(item);
          stars[item.stars] = item.count;
        }
      }
    } else {
      final rawRatings = json['customerRatings'] ?? json['ratings'] ?? json['reviewsBreakdown'];
      if (rawRatings is Map<String, dynamic>) {
        final breakdown = rawRatings['breakdown'] ?? rawRatings['counts'] ?? rawRatings;
        if (breakdown is Map) {
          for (var k in [5, 4, 3, 2, 1]) {
            final c = (breakdown[k.toString()] ?? breakdown[k] as num?)?.toInt() ?? 0;
            stars[k] = c;
            distList.add(RatingDistItem(stars: k, count: c));
          }
        }
      }
    }

    int approvedReviews = revCountVal > 0 ? revCountVal : 0;
    if (approvedReviews == 0) {
      approvedReviews = stars.values.fold(0, (sum, c) => sum + c);
    }

    // Coupons
    final couponList = <CouponPerformanceItem>[];
    final rawCoupons = json['coupons'] ??
        json['couponPerformance'] ??
        json['coupon_performance'] ??
        [];
    if (rawCoupons is List) {
      for (var c in rawCoupons) {
        if (c is Map<String, dynamic>) {
          couponList.add(CouponPerformanceItem.fromJson(c));
        }
      }
    }

    return AnalyticsDashboardModel(
      range: json['range']?.toString() ?? '30d',
      revenue: revDouble,
      orders: ordersVal,
      unitsSold: unitsVal,
      avgOrderValue: aovDouble,
      cancellationRate: cancelRate,
      avgRating: ratingVal,
      customers: customersVal,
      repeatCustomersPct: repeatPct,
      lowStockVariants: lowStock.toInt(),
      reviewCount: revCountVal > 0 ? revCountVal : approvedReviews,
      revenueOverTime: seriesList,
      topProducts: topList,
      orderFunnel: funnel,
      paymentMethods: payments,
      paymentSplit: splitList,
      ratingDist: distList,
      starRatings: stars,
      approvedReviewsCount: approvedReviews,
      coupons: couponList,
    );
  }
}
