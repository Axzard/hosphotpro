import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/subscription_package_api_model.dart';
import '../model/transaction_api_model.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';
import 'token_service.dart';

class SubscriptionService extends GetxService {
  final Dio _dio = Dio();
  final TokenService _tokenService = Get.find<TokenService>();

  // Get packages from backend API
  Future<ApiResponse<List<SubscriptionPackageApiModel>>> getPackages() async {
    try {
      print('=== GET PACKAGES DEBUG ===');
      print('URL: ${ApiConfig.packages}');
      
      final token = _tokenService.getToken();
      print('Using token: ${token != null ? "Yes" : "No"}');

      final response = await _dio.get(
        ApiConfig.packages,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status code: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Get Packages SUCCESS');

        final List<dynamic> packagesData = response.data['data'] ?? [];
        final packages = packagesData
            .map((json) => SubscriptionPackageApiModel.fromJson(json))
            .toList();

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Packages fetched successfully',
          data: packages,
        );
      } else {
        print('❌ Get Packages FAILED - Status: ${response.statusCode}');
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch packages',
          data: [],
        );
      }
    } on DioException catch (e) {
      print('❌ DioException occurred:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');

      return ApiResponse(
        success: false,
        message: 'Failed to fetch packages: ${e.message}',
        data: [],
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: [],
      );
    }
  }

  // Create transaction and get Midtrans Snap token (Mock)
  // Create transaction
  Future<ApiResponse<TransactionApiModel>> createTransaction(
    String packageId,
    String userId, {
    double? amount,
  }) async {
    try {
      print('=== CREATE TRANSACTION DEBUG ===');
      print('URL: ${ApiConfig.checkout}');
      print('Package ID: $packageId');
      
      final token = _tokenService.getToken();
      
      // Request body based on user requirement
      // Trying to add total_bayar as it might be required
      final data = {
        'id_paket_langganan': int.tryParse(packageId) ?? packageId,
        'metode_pembayaran': 'midtrans',
        if (amount != null) 'total_bayar': amount,
        'quantity': 1, // Common field, might be needed
      };
      
      print('Request Body: $data');

      final response = await _dio.post(
        ApiConfig.checkout,
        data: data,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Transaction Created SUCCESS');
        final responseData = response.data; // Using raw data based on user input example structure
        
        // Map response to TransactionApiModel
        // Note: The user said response is { "id_langganan": 1, "total_bayar": 150000, "metode_pembayaran": "midtrans" }
        // Use ID for both id and maybe fill others with defaults if missing
        
        // Check if we have snap_token or similar
        final snapToken = responseData['token'] ?? responseData['snap_token'] ?? '';
        
        final transaction = TransactionApiModel(
          id: responseData['id_langganan']?.toString() ?? '0',
          packageId: packageId, // We know this from request
          packageName: 'Subscription Package', // Placeholder or fetch if needed
          userId: userId,
          amount: double.tryParse(responseData['total_bayar']?.toString() ?? '0') ?? 0,
          status: 'pending',
          createdAt: DateTime.now().toIso8601String(),
          snapToken: snapToken,
        );

        return ApiResponse(
          success: true,
          message: 'Transaction created successfully',
          data: transaction,
        );
      } else {
        print('❌ Transaction Creation FAILED');
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? response.data['message'] ?? 'Failed to create transaction',
          data: null,
        );
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
        data: null,
      );
    } catch (e) {
      print('❌ Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error: $e',
        data: null,
      );
    }
  }

  // Get transaction by ID (Mock)
  Future<ApiResponse<TransactionApiModel>> getTransactionById(
    String transactionId,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock: return success status after some time
    final transaction = TransactionApiModel(
      id: transactionId,
      packageId: 'pkg_basic',
      packageName: 'Basic',
      userId: '1',
      amount: 50000,
      status: 'success', // Mock success
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      paidAt: DateTime.now().toIso8601String(),
      snapToken: 'mock_snap_token',
    );

    return ApiResponse(
      success: true,
      message: 'Transaction fetched',
      data: transaction,
    );
  }

  // Get transaction history (Mock)
  Future<ApiResponse<List<TransactionApiModel>>> getTransactionHistory(
    String userId,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final transactions = [
      TransactionApiModel(
        id: 'trx_001',
        packageId: 'pkg_basic',
        packageName: 'Basic',
        userId: userId,
        amount: 50000,
        status: 'success',
        createdAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        paidAt: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      ),
      TransactionApiModel(
        id: 'trx_002',
        packageId: 'pkg_pro',
        packageName: 'Professional',
        userId: userId,
        amount: 150000,
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        snapToken: 'mock_snap_token_002',
      ),
    ];

    return ApiResponse(
      success: true,
      message: 'Transaction history fetched',
      data: transactions,
    );
  }
}
