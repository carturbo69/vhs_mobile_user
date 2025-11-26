import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:vhs_mobile_user/data/repositories/service_repository.dart';

/// Provider family: nhận serviceId khi gọi
final serviceDetailProvider =
    AsyncNotifierProvider.family<ServiceDetailNotifier, ServiceDetail, String>(
      ServiceDetailNotifier.new,
    );

class ServiceDetailNotifier extends AsyncNotifier<ServiceDetail> {
  late String id;
  late ServiceRepository _repo;
  ServiceDetailNotifier(this.id);

  @override
  Future<ServiceDetail> build() async {
    _repo = ref.read(serviceRepositoryProvider);

    // load service detail từ API
    return _repo.getServiceDetail(id);
  }

  /// Cho nút refresh
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getServiceDetail(id));
  }
}
