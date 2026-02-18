import 'package:get/get.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/token_service.dart';
import '../../domain/models/auth_repository.dart';
import '../../domain/models/subscription_repository.dart';
import '../../data/services/subscription_service.dart';
import '../../data/services/midtrans_service.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../ui/auth/view_models/auth_view_model.dart';
import '../../data/services/router_service.dart';
import '../../domain/models/router_repository.dart';
import '../../data/repositories/router_repository_impl.dart';
import '../../data/services/voucher_service.dart';
import '../../domain/models/voucher_repository.dart';
import '../../data/repositories/voucher_repository_impl.dart';
import '../../core/services/printer_service.dart';
import '../../core/services/websocket_service.dart';
import '../../data/services/payment_persistence_service.dart';

class GlobalBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // Initialize services that need async init
    final tokenService = TokenService();
    await tokenService.init();
    Get.put<TokenService>(tokenService);

    final paymentPersistenceService = PaymentPersistenceService();
    await paymentPersistenceService.init();
    Get.put<PaymentPersistenceService>(paymentPersistenceService);

    // Services
    Get.put<PrinterService>(PrinterService());
    Get.put<WebSocketService>(WebSocketService());
    Get.put<AuthService>(AuthService());
    Get.put<SubscriptionService>(SubscriptionService());
    Get.put<MidtransService>(MidtransService());
    Get.put<RouterService>(RouterService());
    Get.put<VoucherService>(VoucherService());

    // Repositories
    Get.put<AuthRepository>(AuthRepositoryImpl());
    Get.put<SubscriptionRepository>(SubscriptionRepositoryImpl());
    Get.put<RouterRepository>(RouterRepositoryImpl(Get.find()));
    Get.put<VoucherRepository>(VoucherRepositoryImpl());

    // ViewModels
    Get.put<AuthViewModel>(AuthViewModel(Get.find()), permanent: true);
  }
}
