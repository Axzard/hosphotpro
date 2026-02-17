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

class GlobalBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    // Initialize TokenService first (needs async init)
    final tokenService = TokenService();
    await tokenService.init();
    Get.put<TokenService>(tokenService);
    
    // Services
    Get.put<AuthService>(AuthService());
    Get.put<SubscriptionService>(SubscriptionService());
    Get.put<MidtransService>(MidtransService());
    Get.put<RouterService>(RouterService());

    // Repositories
    Get.put<AuthRepository>(AuthRepositoryImpl());
    Get.put<SubscriptionRepository>(SubscriptionRepositoryImpl());
    Get.put<RouterRepository>(RouterRepositoryImpl(Get.find()));
    
    // ViewModels
    Get.put<AuthViewModel>(AuthViewModel(Get.find()), permanent: true);
  }
}
