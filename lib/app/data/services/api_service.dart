import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';

import '../models/announcement_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/analytics_dashboard_model.dart';

class ApiService extends getx.GetxService {
  static const String devBaseUrl = 'https://dev.alifworld.com.bd/api/v1/';
  static const String prodBaseUrl = 'https://alifworld.com.bd/api/v1/';

  // ANSI Yellow Color for Debug Console
  static const String _yellow = '\x1B[33m';
  static const String _reset = '\x1B[0m';

  static void _logYellow(String message) {
    debugPrint('$_yellow$message$_reset');
  }

  late final Dio dio;
  late final GetStorage storage;

  static const String keyAccessToken = 'ACCESS_TOKEN';
  static const String keyRefreshToken = 'REFRESH_TOKEN';
  static const String keyUserData = 'USER_DATA';
  static const String keyIsLoggedIn = 'IS_LOGGED_IN';
  static const String keySiteConfig = 'SITE_CONFIG';

  Future<ApiService> init({bool isProduction = false}) async {
    storage = GetStorage();
    final baseUrl = isProduction ? prodBaseUrl : devBaseUrl;

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Request, Response & Error Interceptors with Yellow Console Output
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          final isPublicOrAuth =
              path.contains('auth/token') ||
              path.contains('auth/refresh') ||
              path.contains('auth/otp') ||
              path.contains('auth/email-otp') ||
              path.contains('auth/register/complete') ||
              path.contains('site');

          if (!isPublicOrAuth) {
            if (isTokenExpired()) {
              _logYellow(
                '⚡ [AUTH INTERCEPTOR] Access token expired, proactively refreshing...',
              );
              await refreshToken();
            }
            final accessToken = storage.read<String>(keyAccessToken) ?? '';
            if (accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }
          options.headers['Accept'] = 'application/json';

          _logYellow(
            '⚡ [API REQUEST] ${options.method} ${options.baseUrl}${options.path}',
          );
          if (options.headers.containsKey('Authorization')) {
            final authVal = options.headers['Authorization'].toString();
            final tokenPreview = authVal.length > 25
                ? '${authVal.substring(0, 20)}...${authVal.substring(authVal.length - 6)}'
                : authVal;
            _logYellow('   Auth: $tokenPreview (using: access_token)');
          }
          if (options.queryParameters.isNotEmpty) {
            _logYellow('   Params: ${options.queryParameters}');
          }
          if (options.data != null) {
            _logYellow('   Payload: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logYellow(
            '⚡ [API RESPONSE] [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.path}',
          );
          _logYellow('   Data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          _logYellow(
            '❌ [API ERROR] [${error.response?.statusCode}] ${error.requestOptions.method} ${error.requestOptions.path}',
          );
          _logYellow('   Response: ${error.response?.data ?? error.message}');

          final errData = error.response?.data;
          if (errData is Map && errData['error'] != null) {
            lastApiErrorCode = errData['error']['code']?.toString();
            lastApiError = errData['error']['message']?.toString();
          } else {
            lastApiErrorCode = null;
            lastApiError = error.message;
          }

          // Token Expired / Unauthenticated: Attempt proactive single refresh
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('auth/token') &&
              !error.requestOptions.path.contains('auth/refresh')) {
            final refreshed = await refreshToken();
            if (refreshed) {
              final newAccessToken = storage.read<String>(keyAccessToken) ?? '';
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              try {
                final cloneReq = await dio.fetch(error.requestOptions);
                return handler.resolve(cloneReq);
              } catch (_) {}
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Load initial site config
    await getSiteConfig();

    return this;
  }

  // --- 1. Site Config ---
  Future<Map<String, dynamic>?> getSiteConfig() async {
    try {
      final response = await dio.get('site');
      if (response.statusCode == 200 && response.data?['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        storage.write(keySiteConfig, data);
        return data;
      }
    } catch (e) {
      log('Error getting /site config: $e');
    }
    return storage.read<Map<String, dynamic>>(keySiteConfig);
  }

  // --- 2. Auth APIs per Sellerapp.md ---

  /// Request phone OTP (devCode returned on dev mode)
  Future<Map<String, dynamic>?> requestPhoneOtp({
    required String phone,
    String purpose = 'login',
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final response = await dio.post(
      'auth/otp/request',
      data: {'phone': cleanPhone, 'purpose': purpose},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : null;
    }
    return null;
  }

  /// Exchange OTP for Access & Refresh Tokens (POST /auth/token)
  Future<Map<String, dynamic>?> exchangeOtpForToken({
    required String phone,
    required String otp,
  }) async {
    lastApiError = null;
    lastApiErrorCode = null;
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      final response = await dio.post(
        'auth/token',
        data: {'phone': cleanPhone, 'otp': otp},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        if (data != null && data['accessToken'] != null) {
          _saveTokens(data['accessToken'], data['refreshToken']);
          return data;
        }
      }
    } on DioException catch (e) {
      log('Exchange OTP error: $e');
    }
    return null;
  }

  /// Password login (POST /auth/token with phone and password per §3.1 and §4.1)
  Future<Map<String, dynamic>?> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    lastApiError = null;
    lastApiErrorCode = null;
    try {
      final cleanPhone = identifier.replaceAll(RegExp(r'\D'), '');
      final response = await dio.post(
        'auth/token',
        data: {'phone': cleanPhone, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        if (data != null && data['accessToken'] != null) {
          _saveTokens(data['accessToken'], data['refreshToken']);
          return data;
        }
      }
    } on DioException catch (e) {
      log('Login error: $e');
    }
    return null;
  }

  /// Proactive Token Refresh (POST /auth/refresh)
  Future<bool> refreshToken() async {
    final currentRefresh = storage.read<String>(keyRefreshToken);
    if (currentRefresh == null || currentRefresh.isEmpty) return false;

    try {
      final response = await dio.post(
        'auth/refresh',
        data: {'refreshToken': currentRefresh},
        options: Options(headers: {'Accept': 'application/json'}),
      );
      if (response.statusCode == 200) {
        final data = response.data?['data'] as Map<String, dynamic>?;
        if (data != null && data['accessToken'] != null) {
          final newAccess = data['accessToken'].toString();
          final newRefresh = data['refreshToken']?.toString();
          _saveTokens(newAccess, newRefresh);
          _logYellow(
            '⚡ [TOKEN REFRESH] Received fresh access token: ${newAccess.length > 20 ? "${newAccess.substring(0, 15)}..." : newAccess}',
          );
          return true;
        }
      }
    } catch (e) {
      log('Token refresh error: $e');
    }

    // Refresh token expired or reuse detected -> clear tokens
    storage.remove(keyAccessToken);
    storage.remove(keyRefreshToken);
    storage.write(keyIsLoggedIn, false);
    return false;
  }

  /// Check whether the stored JWT access token is expired or close to expiry (within 30s)
  bool isTokenExpired() {
    final token = storage.read<String>(keyAccessToken);
    if (token == null || token.isEmpty) return true;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp is int) {
        final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        return nowSeconds >= (exp - 30); // 30-second proactive buffer
      }
    } catch (_) {}
    return false;
  }

  void _saveTokens(String accessToken, String? refreshToken) {
    storage.write(keyAccessToken, accessToken);
    if (refreshToken != null) {
      storage.write(keyRefreshToken, refreshToken);
    }
    storage.write(keyIsLoggedIn, true);
  }

  /// Verify registration OTP (POST /auth/otp/verify) -> returns regToken
  Future<Map<String, dynamic>?> verifyPhoneOtp({
    required String phone,
    required String code,
    String purpose = 'login',
  }) async {
    if (purpose == 'login') {
      return exchangeOtpForToken(phone: phone, otp: code);
    }

    lastApiError = null;
    lastApiErrorCode = null;
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      final response = await dio.post(
        'auth/otp/verify',
        data: {'phone': cleanPhone, 'code': code, 'purpose': purpose},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map
            ? (response.data['data'] as Map<String, dynamic>?)
            : null;
      }
    } on DioException catch (e) {
      log('Verify phone OTP error: $e');
    }
    return null;
  }

  /// Request email OTP (POST /auth/email-otp/request)
  Future<Map<String, dynamic>?> requestEmailOtp({required String email}) async {
    lastApiError = null;
    lastApiErrorCode = null;
    try {
      final response = await dio.post(
        'auth/email-otp/request',
        data: {'email': email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map
            ? (response.data['data'] as Map<String, dynamic>?)
            : null;
      }
    } on DioException catch (e) {
      log('Request email OTP error: $e');
    }
    return null;
  }

  /// Verify email OTP (POST /auth/email-otp/verify) -> returns emailToken
  Future<Map<String, dynamic>?> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    lastApiError = null;
    lastApiErrorCode = null;
    try {
      final response = await dio.post(
        'auth/email-otp/verify',
        data: {'email': email, 'code': code},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map
            ? (response.data['data'] as Map<String, dynamic>?)
            : null;
      }
    } on DioException catch (e) {
      log('Verify email OTP error: $e');
    }
    return null;
  }

  /// Complete Seller Registration (POST /auth/register/complete)
  Future<Map<String, dynamic>?> completeRegistration({
    required String regToken,
    required String emailToken,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    String? referralCode,
    Map<String, dynamic>? profile,
  }) async {
    final payload = <String, dynamic>{
      'regToken': regToken,
      'emailToken': emailToken,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
    };
    if (referralCode != null && referralCode.isNotEmpty) {
      payload['referralCode'] = referralCode;
    }
    if (profile != null && profile.isNotEmpty) {
      payload['profile'] = profile;
    }

    lastApiError = null;
    lastApiErrorCode = null;
    try {
      final response = await dio.post('auth/register/complete', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map
            ? (response.data['data'] as Map<String, dynamic>?)
            : null;
      }
    } on DioException catch (e) {
      log('Complete registration error: $e');
    }
    return null;
  }

  /// Get Current Authenticated Profile (GET /auth/me)
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await dio.get('auth/me');
      if (response.statusCode == 200) {
        final user = response.data?['data']?['user'] as Map<String, dynamic>?;
        if (user != null) {
          storage.write(keyUserData, user);
        }
        return user;
      }
    } catch (e) {
      log('Error getting profile: $e');
    }
    return null;
  }

  /// Logout (POST /auth/logout)
  Future<void> logout() async {
    try {
      await dio.post('auth/logout');
    } catch (_) {}
    storage.remove(keyAccessToken);
    storage.remove(keyRefreshToken);
    storage.remove(keyUserData);
    storage.write(keyIsLoggedIn, false);
  }

  // --- 3. Seller Announcements APIs ---

  /// GET /seller/announcements
  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await dio.get('seller/announcements');
      if (response.statusCode == 200) {
        final list =
            response.data?['data']?['announcements'] as List<dynamic>? ?? [];
        return list
            .map(
              (item) =>
                  AnnouncementModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      log('Error getting announcements: $e');
    }
    return [];
  }

  /// POST /seller/announcements/{id}/read
  Future<bool> markAnnouncementAsRead(String id) async {
    try {
      final response = await dio.post('seller/announcements/$id/read');
      return response.statusCode == 200 &&
          response.data?['data']?['ok'] == true;
    } catch (e) {
      log('Error marking announcement $id as read: $e');
      return false;
    }
  }

  // --- 4. Seller Dashboard & Analytics APIs ---

  /// 1. GET /seller/dashboard/stats?range=7d|30d|90d (Main KPIs, daily series, order funnel, top products, currency)
  Future<DashboardStatsModel?> getDashboardStats({String range = '30d'}) async {
    try {
      final response = await dio.get(
        'seller/dashboard/stats',
        queryParameters: {'range': range},
      );
      if (response.statusCode == 200 && response.data?['data'] != null) {
        return DashboardStatsModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      log('Error getting dashboard stats: $e');
    }
    return null;
  }

  /// 2. GET /seller/analytics/summary (Attention counters: reviews, low stock, pending products, announcements)
  Future<AnalyticsSummaryModel?> getAnalyticsSummary() async {
    try {
      final response = await dio.get('seller/analytics/summary');
      if (response.statusCode == 200 && response.data?['data'] != null) {
        return AnalyticsSummaryModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      log('Error getting analytics summary: $e');
    }
    return null;
  }

  /// 3. GET /seller/analytics/dashboard?range=7d|30d|90d (Growth KPIs, payment split, ratings, coupon performance)
  Future<AnalyticsDashboardModel?> getAnalyticsDashboard({
    String range = '30d',
  }) async {
    try {
      final response = await dio.get(
        'seller/analytics/dashboard',
        queryParameters: {'range': range},
      );
      if (response.statusCode == 200 && response.data?['data'] != null) {
        return AnalyticsDashboardModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      log('Error getting analytics dashboard: $e');
    }
    return null;
  }

  // --- 5. Seller Uploads (Multipart POST /seller/uploads) ---
  /// kind: "media" (products), "logo" (branding), "document" (KYC)
  Future<String?> uploadFile({
    required String filePath,
    String? fileName,
    String kind = 'logo',
  }) async {
    try {
      final name = fileName ?? filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: name),
        'kind': kind,
      });

      final response = await dio.post(
        'seller/uploads',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?['data']?['url'] as String?;
      }
    } catch (e) {
      log('Error uploading file to seller/uploads: $e');
    }
    return null;
  }

  // --- 6. Seller Onboarding / Store Setup APIs ---

  /// GET /seller/onboarding/status
  Future<Map<String, dynamic>?> getOnboardingStatus() async {
    try {
      final response = await dio.get('seller/onboarding/status');
      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      log('Error getting onboarding status: $e');
    }
    return null;
  }

  /// POST /seller/onboarding/draft
  Future<Map<String, dynamic>?> saveOnboardingDraft(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post('seller/onboarding/draft', data: payload);
      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      log('Error saving onboarding draft: $e');
    }
    return null;
  }

  /// POST /seller/onboarding/kyc
  Future<Map<String, dynamic>?> submitKycDocument({
    required String fieldId,
    required String fileUrl,
    required int fileSizeKb,
    required String extension,
  }) async {
    try {
      final response = await dio.post(
        'seller/onboarding/kyc',
        data: {
          'fieldId': fieldId,
          'fileUrl': fileUrl,
          'fileSizeKb': fileSizeKb,
          'extension': extension,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      log('Error submitting KYC document: $e');
    }
    return null;
  }

  /// DELETE /seller/onboarding/kyc/{docId}
  Future<bool> deleteKycDocument(String docId) async {
    try {
      final response = await dio.delete('seller/onboarding/kyc/$docId');
      return response.statusCode == 200 &&
          response.data?['data']?['ok'] == true;
    } catch (e) {
      log('Error deleting KYC document: $e');
      return false;
    }
  }

  /// POST /seller/onboarding/submit
  Future<Map<String, dynamic>> submitOnboarding() async {
    // 1. Proactively ensure access token is fresh (not expired)
    if (isTokenExpired()) {
      _logYellow(
        '⚡ [SUBMIT] Access token expired or close to expiry, proactively refreshing...',
      );
      await refreshToken();
    }

    final accessToken = storage.read<String>(keyAccessToken) ?? '';
    _logYellow(
      '⚡ [SUBMIT ONBOARDING] Submitting application with Access Token: ${accessToken.length > 20 ? "${accessToken.substring(0, 15)}...${accessToken.substring(accessToken.length - 6)}" : "NONE"} (type: access_token)',
    );

    try {
      final response = await dio.post(
        'seller/onboarding/submit',
        data: {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'ok': true, 'data': response.data?['data']};
      }
    } on DioException catch (dioErr) {
      final errData = dioErr.response?.data;
      if (errData is Map && errData['error'] != null) {
        return {
          'ok': false,
          'code': errData['error']['code'],
          'message': errData['error']['message'],
          'missing': errData['error']['missing'],
        };
      }
    } catch (e) {
      log('Error submitting onboarding: $e');
    }
    return {'ok': false, 'message': 'Submission failed.'};
  }

  String? lastApiError;
  String? lastApiErrorCode;

  // --- 7. Seller Shop Profile APIs ---

  /// GET /seller/shop
  Future<Map<String, dynamic>?> getShop() async {
    lastApiError = null;
    try {
      final response = await dio.get('seller/shop');
      if (response.statusCode == 200) {
        return response.data?['data']?['shop'] as Map<String, dynamic>?;
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message']?.toString();
      lastApiError = msg ?? e.message;
      log('Error getting shop profile: $e');
    } catch (e) {
      lastApiError = e.toString();
      log('Error getting shop profile: $e');
    }
    return null;
  }

  /// PUT /seller/shop
  Future<Map<String, dynamic>?> updateShop(Map<String, dynamic> payload) async {
    lastApiError = null;
    try {
      final response = await dio.put('seller/shop', data: payload);
      if (response.statusCode == 200) {
        return response.data?['data']?['shop'] as Map<String, dynamic>?;
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?['message']?.toString();
      lastApiError = msg ?? e.message;
      log('Error updating shop: $e');
    } catch (e) {
      lastApiError = e.toString();
      log('Error updating shop: $e');
    }
    return null;
  }

  // --- 8. Seller Products & Catalog APIs ---

  /// GET /catalog/categories
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await dio.get('catalog/categories');
      if (response.statusCode == 200) {
        return response.data?['data']?['categories'] as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }

  /// GET /catalog/brands
  Future<List<dynamic>> getBrands() async {
    try {
      final response = await dio.get('catalog/brands');
      if (response.statusCode == 200) {
        return response.data?['data']?['brands'] as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }

  /// GET /catalog/attributes
  Future<List<dynamic>> getAttributes() async {
    try {
      final response = await dio.get('catalog/attributes');
      if (response.statusCode == 200) {
        return response.data?['data']?['attributes'] as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }

  /// GET /seller/products
  Future<Map<String, dynamic>?> getProducts({
    int limit = 20,
    String? cursor,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (cursor != null) query['cursor'] = cursor;
      if (status != null) query['status'] = status;
      final response = await dio.get('seller/products', queryParameters: query);
      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  /// POST /seller/products (Creates draft product)
  Future<Map<String, dynamic>?> createProduct(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post('seller/products', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?['data']?['product'] as Map<String, dynamic>?;
      }
    } on DioException catch (e) {
      log('DioError creating product: ${e.response?.data}');
      rethrow;
    } catch (e) {
      log('Error creating product: $e');
      rethrow;
    }
    return null;
  }

  /// POST /seller/products/{id}/submit (Draft -> pending or live)
  Future<bool> submitProduct(String productId) async {
    try {
      final response = await dio.post('seller/products/$productId/submit');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// POST /seller/products/{id}/visibility
  Future<bool> toggleProductVisibility(String productId, bool visible) async {
    try {
      final response = await dio.post(
        'seller/products/$productId/visibility',
        data: {'visible': visible},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- 9. Seller Orders & Fulfillment APIs ---

  /// GET /seller/orders
  Future<Map<String, dynamic>?> getOrders({
    int limit = 20,
    String? cursor,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (cursor != null) query['cursor'] = cursor;
      if (status != null) query['status'] = status;
      final response = await dio.get('seller/orders', queryParameters: query);
      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  /// GET /seller/orders/{id}
  Future<Map<String, dynamic>?> getOrderDetail(String orderId) async {
    try {
      final response = await dio.get('seller/orders/$orderId');
      if (response.statusCode == 200) {
        final d = response.data?['data'];
        if (d is Map<String, dynamic>) {
          if (d['order'] is Map<String, dynamic>) {
            return d['order'] as Map<String, dynamic>;
          }
          return d;
        }
      }
    } catch (e) {
      log('Error getting order detail for $orderId: $e');
    }
    return null;
  }

  /// POST /seller/orders/{id}/status
  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        'seller/orders/$orderId/status',
        data: payload,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final d = response.data?['data'];
        return {'success': true, 'data': d};
      }
      return {
        'success': false,
        'message':
            response.data?['error']?['message'] ??
            'Failed to update order status',
      };
    } on DioException catch (e) {
      final msg =
          e.response?.data?['error']?['message'] ??
          e.message ??
          'Error updating order status';
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // --- 10. Inventory & Low Stock APIs (Commit 60c5a25 verified) ---

  /// GET /seller/inventory?lowStock=true&limit=...&cursor=...
  Future<Map<String, dynamic>?> getLowStockInventory({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final query = <String, dynamic>{
        'lowStock': 'true',
        'limit': limit,
      };
      if (cursor != null && cursor.isNotEmpty) {
        query['cursor'] = cursor;
      }
      final response = await dio.get('seller/inventory', queryParameters: query);
      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      log('Error getting low stock inventory: $e');
    }
    return null;
  }

  /// Convenience legacy helper for existing callers
  Future<List<dynamic>> getLowStockProducts() async {
    final res = await getLowStockInventory(limit: 50);
    return res?['products'] as List<dynamic>? ?? [];
  }

  /// GET /seller/inventory?productId=`productId`&limit=...&cursor=...
  /// Stock history / ledger entries for a single product (newest first).
  Future<Map<String, dynamic>?> getProductInventoryHistory({
    required String productId,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final query = <String, dynamic>{
        'productId': productId,
        'limit': limit,
      };
      if (cursor != null && cursor.isNotEmpty) {
        query['cursor'] = cursor;
      }
      final response = await dio.get('seller/inventory', queryParameters: query);
      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      log('Error getting product inventory history: $e');
    }
    return null;
  }

  /// POST /seller/inventory/adjust
  /// Follows commit 60c5a25 sign rule:
  /// - 'in': sends positive magnitude -> server adds +changeQty
  /// - 'out': sends positive magnitude -> server subtracts -changeQty (takes -|changeQty|)
  /// - 'adjustment': sends signed delta -> server posts exactly what is sent
  Future<Map<String, dynamic>?> adjustStock({
    required String productId,
    required String variantId,
    required int changeQty,
    String kind = 'in',
    String? note,
  }) async {
    lastApiError = null;
    lastApiErrorCode = null;
    try {
      // 60c5a25 sign rule: for in/out send magnitude
      int sendQty = changeQty;
      if (kind == 'in' || kind == 'out') {
        sendQty = changeQty.abs();
      }

      final payload = <String, dynamic>{
        'productId': productId,
        'variantId': variantId,
        'changeQty': sendQty,
        'kind': kind,
      };
      if (note != null && note.trim().isNotEmpty) {
        payload['note'] = note.trim();
      }
      final response = await dio.post('seller/inventory/adjust', data: payload);
      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final err = (e.response?.data as Map)['error'];
        if (err is Map) {
          lastApiErrorCode = err['code']?.toString();
          lastApiError = err['message']?.toString();
        }
      }
      log('Error adjusting stock: $e (code: $lastApiErrorCode, message: $lastApiError)');
    } catch (e) {
      log('Unexpected error adjusting stock: $e');
    }
    return null;
  }

  // --- 11. Seller Wallets & Payout APIs ---

  /// GET /seller/wallets (Returns all 7 seller wallets & transactions)
  Future<Map<String, dynamic>?> getSellerWallets() async {
    try {
      final response = await dio.get('seller/wallets');
      if (response.statusCode == 200) {
        return response.data?['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      log('Error getting seller wallets: $e');
    }
    return null;
  }

  /// GET /seller/payout-accounts
  Future<List<dynamic>> getPayoutAccounts() async {
    try {
      final response = await dio.get('seller/payout-accounts');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          if (data['data'] is Map && data['data']['accounts'] is List) {
            return data['data']['accounts'] as List<dynamic>;
          }
          if (data['data'] is List) return data['data'] as List<dynamic>;
          if (data['accounts'] is List) {
            return data['accounts'] as List<dynamic>;
          }
        } else if (data is List) {
          return data;
        }
      }
    } catch (e) {
      log('Error getting payout accounts: $e');
    }
    return [];
  }

  /// POST /seller/payout-accounts
  Future<Map<String, dynamic>?> createPayoutAccount(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post('seller/payout-accounts', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?['data']?['account'] as Map<String, dynamic>? ??
            response.data?['data'] as Map<String, dynamic>? ??
            {'success': true};
      }
    } on DioException catch (e) {
      final serverMsg =
          e.response?.data?['error']?['message']?.toString() ??
          e.response?.data?['message']?.toString();
      log('Error creating payout account ($serverMsg): ${e.response?.data}');
      return {'error': serverMsg ?? 'Failed to add payout account.'};
    } catch (e) {
      log('Error creating payout account: $e');
    }
    return null;
  }

  /// DELETE /seller/payout-accounts/{accountId}
  Future<bool> deletePayoutAccount(String accountId) async {
    try {
      final response = await dio.delete('seller/payout-accounts/$accountId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      log('Error deleting payout account: $e');
    }
    return false;
  }

  /// POST /seller/payouts
  Future<Map<String, dynamic>?> requestPayout({
    required String payoutAccountId,
    required int amountMinor,
  }) async {
    try {
      final response = await dio.post(
        'seller/payouts',
        data: {'payoutAccountId': payoutAccountId, 'amountMinor': amountMinor},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data?['data'];
        if (data is Map<String, dynamic>) return data;
        return {'success': true};
      }
    } on DioException catch (e) {
      final serverMsg =
          e.response?.data?['error']?['message']?.toString() ??
          e.response?.data?['message']?.toString();
      log('Error requesting payout ($serverMsg): ${e.response?.data}');
      return {'error': serverMsg ?? 'Payout request failed.'};
    } catch (e) {
      log('Error requesting payout: $e');
    }
    return null;
  }

  /// GET /seller/payouts
  Future<List<dynamic>> getPayouts() async {
    try {
      final response = await dio.get('seller/payouts');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          if (data['data'] is Map && data['data']['payouts'] is List) {
            return data['data']['payouts'] as List<dynamic>;
          }
          if (data['data'] is List) return data['data'] as List<dynamic>;
          if (data['payouts'] is List) return data['payouts'] as List<dynamic>;
        } else if (data is List) {
          return data;
        }
      }
    } catch (e) {
      log('Error getting payouts: $e');
    }
    return [];
  }

  // --- 12. Leaderboard, Coupons, Reviews & Returns APIs ---

  /// GET /seller/leaderboard?period=weekly
  Future<Map<String, dynamic>?> getLeaderboard({
    String period = 'weekly',
  }) async {
    try {
      final response = await dio.get(
        'seller/leaderboard',
        queryParameters: {'period': period.toLowerCase()},
      );
      if (response.statusCode == 200) {
        final data = response.data?['data'];
        if (data is Map<String, dynamic>) return data;
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        }
      }
    } catch (e) {
      log('Error getting leaderboard: $e');
    }
    return null;
  }

  /// GET /seller/coupons
  Future<List<dynamic>> getCoupons() async {
    try {
      final response = await dio.get('seller/coupons');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          if (data['data'] is Map && data['data']['coupons'] is List) {
            return data['data']['coupons'] as List<dynamic>;
          }
          if (data['data'] is List) return data['data'] as List<dynamic>;
          if (data['coupons'] is List) return data['coupons'] as List<dynamic>;
        } else if (data is List) {
          return data;
        }
      }
    } catch (e) {
      log('Error getting coupons: $e');
    }
    return [];
  }

  /// POST /seller/coupons
  Future<Map<String, dynamic>?> createCoupon(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post('seller/coupons', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data?['data']?['coupon'] as Map<String, dynamic>? ??
            response.data?['data'] as Map<String, dynamic>? ??
            {'success': true};
      }
    } on DioException catch (e) {
      final serverMsg =
          e.response?.data?['error']?['message']?.toString() ??
          e.response?.data?['message']?.toString();
      log('Error creating coupon ($serverMsg): ${e.response?.data}');
      return {'error': serverMsg ?? 'Failed to create coupon.'};
    } catch (e) {
      log('Error creating coupon: $e');
    }
    return null;
  }

  /// PUT /seller/coupons/{id}
  Future<Map<String, dynamic>?> updateCoupon(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.put('seller/coupons/$id', data: payload);
      if (response.statusCode == 200) {
        return response.data?['data']?['coupon'] as Map<String, dynamic>? ??
            response.data?['data'] as Map<String, dynamic>? ??
            {'success': true};
      }
    } on DioException catch (e) {
      final serverMsg =
          e.response?.data?['error']?['message']?.toString() ??
          e.response?.data?['message']?.toString();
      log('Error updating coupon ($serverMsg): ${e.response?.data}');
      return {'error': serverMsg ?? 'Failed to update coupon.'};
    } catch (e) {
      log('Error updating coupon: $e');
    }
    return null;
  }

  /// DELETE /seller/coupons/{id}
  Future<bool> deleteCoupon(String id) async {
    try {
      final response = await dio.delete('seller/coupons/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      log('Error deleting coupon: $e');
    }
    return false;
  }

  /// GET /seller/reviews
  Future<List<dynamic>> getReviews({String? status}) async {
    try {
      final response = await dio.get(
        'seller/reviews',
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.statusCode == 200) {
        return response.data?['data']?['reviews'] as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }

  /// POST /seller/reviews/:id/reply
  Future<bool> replyReview(String reviewId, String reply) async {
    try {
      final response = await dio.post(
        'seller/reviews/$reviewId/reply',
        data: {'reply': reply},
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  /// GET /seller/returns
  Future<List<dynamic>> getReturns({String? status}) async {
    try {
      final response = await dio.get(
        'seller/returns',
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.statusCode == 200) {
        return response.data?['data']?['returns'] as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }

  // --- 13. Geographic APIs (Bangladeshi Address Hierarchy) ---
  Future<List<dynamic>> getDivisions() async {
    try {
      final response = await dio.get('geo/divisions');
      if (response.statusCode == 200) {
        return response.data?['data']?['divisions'] as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> getDistricts(String divisionId) async {
    try {
      final response = await dio.get(
        'geo/districts',
        queryParameters: {'divisionId': divisionId},
      );
      if (response.statusCode == 200) {
        return response.data?['data']?['districts'] as List<dynamic>? ?? [];
      }
    } catch (_) {}
    return [];
  }
}
