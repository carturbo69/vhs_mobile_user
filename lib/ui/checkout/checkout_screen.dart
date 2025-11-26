import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/provider/provider_availability_model.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/cart/cart_list_viewmodel.dart';
import 'package:vhs_mobile_user/ui/cart/cart_total_provider.dart';
import 'package:vhs_mobile_user/ui/checkout/checkout_viewmodel.dart';
import 'package:vhs_mobile_user/ui/user_address/user_address_viewmodel.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  UserAddressModel? selectedAddress;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final addresses = ref.watch(userAddressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: cart.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi: $e')),
        data: (items) {
          return addresses.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Lỗi địa chỉ: $e')),
            data: (addrs) {
              if (addrs.isNotEmpty && selectedAddress == null) {
                selectedAddress = addrs.first;
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Địa chỉ giao hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _AddressSelector(
                    addresses: addrs,
                    selected: selectedAddress,
                    onChanged: (a) => setState(() => selectedAddress = a),
                  ),
                  const SizedBox(height: 14),
                  const Text('Chọn ngày', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _DateSelector(
                    selected: selectedDate!,
                    onDaySelected: (d) => setState(() => selectedDate = d),
                    onCheckAvailability: (d) async {
                      // brute-force: ask viewmodel to check that day
                      return await ref.read(checkoutProvider.notifier).checkDateAvailability(d);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Chọn khung giờ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _TimeSelector(
                    date: selectedDate!,
                    selected: selectedTime,
                    onTimeSelected: (t) => setState(() => selectedTime = t),
                    onCheckTime: (date, timeOfDay) async {
                      final dto = await ref.read(checkoutProvider.notifier).checkTimeAvailability(date, timeOfDay);
                      return dto; // expect ProviderAvailabilityCheckDTO
                    },
                  ),
                  const SizedBox(height: 18),
                  _OrderSummary(),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: items.isEmpty || selectedAddress == null || selectedTime == null
                        ? null
                        : () async {
                            // submit booking
                            final dynamic res = await ref.read(checkoutProvider.notifier).submitBooking(
                                  address: selectedAddress!,
                                  date: selectedDate!,
                                  time: selectedTime!,
                                );
                            if (res.success) {
                              // navigate to result
                              context.go(Routes.bookingResult, extra: res);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message ?? 'Lỗi')));
                            }
                          },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Đặt lịch'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _AddressSelector extends StatelessWidget {
  final List<UserAddressModel> addresses;
  final UserAddressModel? selected;
  final ValueChanged<UserAddressModel> onChanged;

  const _AddressSelector({required this.addresses, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return Card(
        child: ListTile(
          title: const Text('Chưa có địa chỉ nào'),
          trailing: ElevatedButton(
            onPressed: () => context.push(Routes.addAddress),
            child: const Text('Thêm địa chỉ'),
          ),
        ),
      );
    }

    return Column(
      children: addresses.map((a) {
        final isSelected = selected?.addressId == a.addressId;
        return Card(
          child: RadioListTile<UserAddressModel>(
            value: a,
            groupValue: selected,
            onChanged: (v) => onChanged(v!),
            title: Text(a.fullAddress),
            subtitle: Text('${a.recipientName ?? ''} • ${a.recipientPhone ?? ''}'),
            secondary: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
          ),
        );
      }).toList(),
    );
  }
}

class _DateSelector extends StatefulWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onDaySelected;
  final Future<bool> Function(DateTime) onCheckAvailability;

  const _DateSelector({required this.selected, required this.onDaySelected, required this.onCheckAvailability});

  @override
  State<_DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<_DateSelector> {
  late final List<DateTime> days;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    days = List.generate(14, (i) => DateTime(today.year, today.month, today.day).add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemBuilder: (_, i) {
          final d = days[i];
          return FutureBuilder<bool>(
            future: widget.onCheckAvailability(d),
            builder: (context, snap) {
              final available = snap.data ?? false;
              final isSelected = isSameDate(d, widget.selected);
              return GestureDetector(
                onTap: available ? () => widget.onDaySelected(d) : null,
                child: Container(
                  width: 84,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: available ? Colors.green.shade200 : Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(weekdayShort(d.weekday), style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                      const SizedBox(height: 6),
                      Text('${d.day}/${d.month}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                      const SizedBox(height: 6),
                      Text(available ? 'Có lịch' : 'Ngưng', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String weekdayShort(int w) {
    const names = ['T2','T3','T4','T5','T6','T7','CN'];
    return names[(w - 1) % 7];
  }
}

class _TimeSelector extends StatefulWidget {
  final DateTime date;
  final TimeOfDay? selected;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final Future<ProviderAvailabilityModel> Function(DateTime date, TimeOfDay time) onCheckTime;

  const _TimeSelector({required this.date, required this.selected, required this.onTimeSelected, required this.onCheckTime});

  @override
  State<_TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<_TimeSelector> {
  List<TimeOfDay> slots = [];

  @override
  void initState() {
    super.initState();
    _generateSlots();
  }

  void _generateSlots() {
    // generate default 30-min slots 07:00 - 20:00; availability will be validated by onCheckTime
    final start = TimeOfDay(hour: 7, minute: 0);
    final end = TimeOfDay(hour: 20, minute: 0);
    final list = <TimeOfDay>[];
    var cur = start;
    while (!_isAfter(cur, end)) {
      list.add(cur);
      cur = _addMinutes(cur, 30);
    }
    setState(() => slots = list);
  }

  TimeOfDay _addMinutes(TimeOfDay t, int minutes) {
    final dt = DateTime(2020,1,1, t.hour, t.minute).add(Duration(minutes: minutes));
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  bool _isAfter(TimeOfDay a, TimeOfDay b) {
    return a.hour > b.hour || (a.hour == b.hour && a.minute > b.minute);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        return FutureBuilder<ProviderAvailabilityModel>(
          future: widget.onCheckTime(widget.date, slot),
          builder: (context, snap) {
            final dto = snap.data;
            final enabled = dto?.isAvailable ?? false;
            final isSelected = widget.selected?.hour == slot.hour && widget.selected?.minute == slot.minute;
            return ChoiceChip(
              label: Text('${slot.format(context)}'),
              selected: isSelected,
              onSelected: enabled ? (_) => widget.onTimeSelected(slot) : null,
              selectedColor: Theme.of(context).colorScheme.primary,
              disabledColor: Colors.grey.shade200,
            );
          },
        );
      }).toList(),
    );
  }
}

class _OrderSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartTotalProvider);
    final cartAsync = ref.watch(cartProvider);
    final items = cartAsync.maybeWhen(
      data: (data) => data,
      orElse: () => [],
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ...items.map((i) => Row(
                  children: [
                    Expanded(child: Text(i.serviceName)),
                    Text('${(i.price * i.quantity).toStringAsFixed(0)} đ'),
                  ],
                )),
            const Divider(),
            Row(
              children: [
                const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(total is double ? '${total.toStringAsFixed(0)} đ' : '$total đ', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
