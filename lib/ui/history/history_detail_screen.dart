import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_detail_model.dart';
import 'package:vhs_mobile_user/ui/history/history_detail_viewmodel.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final String bookingId;

  const HistoryDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetail = ref.watch(historyDetailProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết đơn hàng")),
      body: asyncDetail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Lỗi: $e")),
        data: (detail) => _DetailBody(detail: detail),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final HistoryBookingDetail detail;

  const _DetailBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _statusHeader(),
        const SizedBox(height: 16),
        _serviceCard(),
        const SizedBox(height: 16),
        _providerCard(),
        if (detail.staffName != null) ...[
          const SizedBox(height: 16),
          _staffCard(),
        ],
        const SizedBox(height: 20),
        _timelineCard(),
        const SizedBox(height: 20),
        _paymentCard(),
        if (detail.cancelReason != null) ...[
          const SizedBox(height: 20),
          _refundCard(),
        ],
        const SizedBox(height: 30),
        _actionButtons(context),
        const SizedBox(height: 60),
      ],
    );
  }

  // ========================================
  // STATUS HEADER
  // ========================================
  Widget _statusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusColor(detail.status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info, size: 28, color: _statusColor(detail.status)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusVi(detail.status),
              style: TextStyle(
                color: _statusColor(detail.status),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusVi(String status) {
    final s = status.toLowerCase();
    if (s.contains("pending")) return "Chờ xác nhận";
    if (s.contains("confirmed")) return "Đã xác nhận";
    if (s.contains("progress")) return "Đang thực hiện";
    if (s.contains("completed")) return "Hoàn thành";
    if (s.contains("cancel")) return "Đã hủy";
    return status;
  }

  // ========================================
  // SERVICE CARD
  // ========================================
  Widget _serviceCard() {
    final img = detail.serviceImages.isNotEmpty
        ? detail.serviceImages.first
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: img != null
                  ? CachedNetworkImage(
                      imageUrl: img,
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 95,
                      height: 95,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.service.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    detail.addressLine,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${NumberFormat('#,###').format(detail.service.unitPrice)} ₫",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // PROVIDER CARD
  // ========================================
  Widget _providerCard() {
    final provider = detail.provider;
    final avatar = provider.providerImages.isNotEmpty
        ? provider.providerImages.first
        : null;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatar != null
              ? CachedNetworkImageProvider(avatar)
              : null,
          child: avatar == null ? const Icon(Icons.store) : null,
        ),
        title: Text(
          provider.providerName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("Mã đơn: ${detail.bookingCode}"),
      ),
    );
  }

  // ========================================
  // STAFF CARD
  // ========================================
  Widget _staffCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: detail.staffImage != null
              ? CachedNetworkImageProvider(detail.staffImage!)
              : null,
          child: detail.staffImage == null ? const Icon(Icons.person) : null,
        ),
        title: Text(detail.staffName!),
        subtitle: Text("SĐT: ${detail.staffPhone ?? "Không có"}"),
      ),
    );
  }

  // ========================================
  // TIMELINE CARD
  // ========================================
  Widget _timelineCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tiến trình đơn hàng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...detail.timeline.map((e) {
              final time = e.time?.toLocal();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.green.shade600,
                        ),
                        Container(
                          width: 2,
                          height: 35,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (e.description != null)
                            Text(
                              e.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          Text(
                            time != null
                                ? DateFormat("dd/MM/yyyy HH:mm").format(time)
                                : "Chưa cập nhật",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ========================================
  // PAYMENT CARD
  // ========================================
  Widget _paymentCard() {
    final price = detail.service.lineTotal;
    final discount = detail.voucherDiscount;
    final total = price - discount;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông tin thanh toán",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _priceRow(
              "Giá dịch vụ",
              "${NumberFormat('#,###').format(price)} ₫",
            ),
            _priceRow(
              "Giảm giá",
              "-${NumberFormat('#,###').format(discount)} ₫",
            ),
            const Divider(),
            _priceRow(
              "Thành tiền",
              "${NumberFormat('#,###').format(total)} ₫",
              isTotal: true,
            ),
            const SizedBox(height: 10),
            Text("Phương thức: ${detail.paymentMethod ?? "Chưa thanh toán"}"),
            Text("Trạng thái: ${detail.paymentStatus ?? "Chưa thanh toán"}"),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 15 : 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 17 : 13,
          ),
        ),
      ],
    );
  }

  // ========================================
  // REFUND CARD (if canceled)
  // ========================================
  Widget _refundCard() {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông báo hoàn tiền",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Lý do: ${detail.cancelReason}"),
            if (detail.refundStatus != null)
              Text("Trạng thái: ${detail.refundStatus}"),
            if (detail.resolutionNote != null)
              Text("Ghi chú: ${detail.resolutionNote}"),
          ],
        ),
      ),
    );
  }

  // ========================================
  // ACTION BUTTONS
  // ========================================
  Widget _actionButtons(BuildContext context) {
    return Column(
      children: [
        if (detail.status.toLowerCase().contains("completed"))
          ElevatedButton(
            onPressed: () {},
            child: const Text("Đánh giá dịch vụ"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ========================================
  // COLOR HELPERS
  // ========================================
  Color _statusColor(String s) {
    final st = s.toLowerCase();
    if (st.contains("pending")) return Colors.orange;
    if (st.contains("confirmed")) return Colors.blue;
    if (st.contains("progress")) return Colors.purple;
    if (st.contains("completed")) return Colors.green;
    if (st.contains("cancel")) return Colors.red;
    return Colors.grey;
  }
}
