import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_result_model.dart';
import 'package:vhs_mobile_user/routing/routes.dart';

class BookingResultScreen extends StatelessWidget {
  final BookingResultModel result;
  const BookingResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt lịch thành công')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 96),
            const SizedBox(height: 12),
            const Text('Bạn đã đặt lịch thành công', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Số đơn: ${result.bookingIds.join(", ")}'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: result.breakdown.map((b) => ListTile(
                  title: Text(b.serviceName),
                  trailing: Text('${b.amount.toStringAsFixed(0)} đ'),
                )).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.go(Routes.listService); // Quay về trang chủ
              },
              child: const Text('Quay về Trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
