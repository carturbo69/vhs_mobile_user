import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:vhs_mobile_user/data/repositories/service_repository.dart';

final serviceDetailProvider =
    AsyncNotifierProvider.family<ServiceDetailNotifier, ServiceDetail, String>(
      ServiceDetailNotifier.new,
    );

class ServiceDetailNotifier extends AsyncNotifier<ServiceDetail> {
  final String id;
  ServiceDetailNotifier(this.id);

  late ServiceRepository _repo;

  @override
  Future<ServiceDetail> build() async {
    _repo = ref.read(serviceRepositoryProvider);
    return _load(id);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(id));
  }

  Future<ServiceDetail> _load(String id) async {
    try {
      return await _repo.getDetail(id);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
