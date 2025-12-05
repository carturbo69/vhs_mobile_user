  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:intl/intl.dart';
  import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/booking/booking_history_detail_model.dart';
import 'package:vhs_mobile_user/ui/history/history_detail_viewmodel.dart';
import 'package:vhs_mobile_user/ui/payment/payment_viewmodel.dart';
import 'package:vhs_mobile_user/ui/review/review_screen.dart';
import 'package:vhs_mobile_user/ui/report/report_screen.dart';
import 'package:vhs_mobile_user/ui/report/report_viewmodel.dart';
import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';
import 'package:vhs_mobile_user/services/data_translation_service.dart';

  class HistoryDetailScreen extends ConsumerWidget {
    final String bookingId;

    const HistoryDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final asyncDetail = ref.watch(historyDetailProvider(bookingId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
        ),
        title: Text(
          context.tr('order_detail'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                ref.invalidate(historyDetailProvider(bookingId));
              },
              tooltip: context.tr('refresh'),
            ),
          ),
        ],
      ),
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate provider để force refresh
          ref.invalidate(historyDetailProvider(bookingId));
          // Đợi một chút để data được fetch lại
          await Future.delayed(const Duration(milliseconds: 300));
        },
        color: ThemeHelper.getPrimaryColor(context),
        child: asyncDetail.when(
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeHelper.getPrimaryColor(context),
                  ),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('loading'),
                  style: TextStyle(
                    color: ThemeHelper.getSecondaryTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          error: (e, st) {
            final isDark = ThemeHelper.isDarkMode(context);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.red.shade900.withOpacity(0.3)
                            : Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('error_loading_history'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$e",
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
          data: (detail) => _DetailBody(
            detail: detail,
            bookingId: bookingId,
            ref: ref,
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  final HistoryBookingDetail detail;
  final String bookingId;
  final WidgetRef ref;

  const _DetailBody({
    required this.detail,
    required this.bookingId,
    required this.ref,
  });

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Auto refresh khi màn hình được hiển thị lại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh khi app quay lại foreground
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  void _refreshData() {
    // Invalidate provider để refresh data
    widget.ref.invalidate(historyDetailProvider(widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale và translation cache để rebuild khi đổi ngôn ngữ hoặc có translation mới
    widget.ref.watch(localeProvider);
    widget.ref.watch(translationCacheProvider);
    
    // Watch lại để cập nhật khi data thay đổi
    final asyncDetail = widget.ref.watch(historyDetailProvider(widget.bookingId));
    
    return asyncDetail.when(
      loading: () => _buildContent(widget.detail), // Hiển thị data cũ khi đang load
      error: (e, st) => _buildContent(widget.detail), // Hiển thị data cũ khi có lỗi
      data: (detail) => _buildContent(detail),
    );
  }

  Widget _buildContent(HistoryBookingDetail detail) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _serviceCard(detail),
        const SizedBox(height: 16),
        _providerCard(detail),
        if (detail.staffName != null) ...[
          const SizedBox(height: 16),
          _staffCard(detail),
        ],
        const SizedBox(height: 20),
        _timelineCard(detail),
        const SizedBox(height: 20),
        _paymentCard(detail),
        if (detail.cancelReason != null) ...[
          const SizedBox(height: 20),
          _refundCard(detail),
        ],
        const SizedBox(height: 30),
        _actionButtons(context, detail),
        const SizedBox(height: 60),
      ],
    );
  }

  // ========================================
  // STATUS HEADER
  // ========================================
  Widget _statusHeader(HistoryBookingDetail detail) {
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
              _getLocalizedStatus(context, detail.status),
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

  String _getLocalizedStatus(BuildContext context, String status) {
    final locale = widget.ref.read(localeProvider);
    final isVietnamese = locale.languageCode == 'vi';
    final translationService = DataTranslationService(widget.ref);
    
    final s = status.toLowerCase();
    String statusVi;
    
    if (s.contains("pending")) {
      statusVi = "Chờ xác nhận";
    } else if (s.contains("confirmed")) {
      statusVi = "Đã xác nhận";
    } else if (s.contains("progress")) {
      statusVi = "Bắt đầu làm việc";
    } else if (s.contains("completed")) {
      statusVi = "Hoàn thành";
    } else if (s.contains("cancel")) {
      statusVi = "Đã hủy";
    } else {
      statusVi = status;
    }
    
    if (isVietnamese) {
      return statusVi;
    }
    
    // Dịch statusVi bằng DataTranslationService
    return translationService.smartTranslate(statusVi);
  }

    // ========================================
    // SERVICE CARD
    // ========================================
    Widget _serviceCard(HistoryBookingDetail detail) {
      final img = detail.serviceImages.isNotEmpty
          ? detail.serviceImages.first
          : null;

      return Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeHelper.getShadowColor(context),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: img != null
                      ? CachedNetworkImage(
                          imageUrl: img,
                          width: 95,
                          height: 95,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            width: 95,
                            height: 95,
                            color: ThemeHelper.getLightBackgroundColor(context),
                            child: Icon(
                              Icons.image_rounded,
                              size: 32,
                              color: ThemeHelper.getSecondaryIconColor(context),
                            ),
                          ),
                        )
                      : Container(
                          width: 95,
                          height: 95,
                          color: ThemeHelper.getLightBackgroundColor(context),
                          child: Icon(
                            Icons.image_rounded,
                            size: 32,
                            color: ThemeHelper.getSecondaryIconColor(context),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final locale = widget.ref.read(localeProvider);
                        final isVietnamese = locale.languageCode == 'vi';
                        final translationService = DataTranslationService(widget.ref);
                        final title = isVietnamese 
                            ? detail.service.title 
                            : translationService.smartTranslate(detail.service.title);
                        return Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getTextColor(context),
                          ),
                          maxLines: 2,
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detail.addressLine,
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeHelper.getTertiaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${NumberFormat('#,###').format(detail.service.unitPrice)} ₫",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red.shade600,
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
    Widget _providerCard(HistoryBookingDetail detail) {
      final provider = detail.provider;
      final avatar = provider.providerImages.isNotEmpty
          ? provider.providerImages.first
          : null;

      return Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ThemeHelper.getBorderColor(context),
                width: 1,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: avatar != null
                  ? CachedNetworkImageProvider(avatar)
                  : null,
              child: avatar == null
                  ? Icon(
                      Icons.store_rounded,
                      color: ThemeHelper.getSecondaryIconColor(context),
                    )
                  : null,
            ),
          ),
          title: Builder(
            builder: (context) {
              final locale = widget.ref.read(localeProvider);
              final isVietnamese = locale.languageCode == 'vi';
              final translationService = DataTranslationService(widget.ref);
              final name = isVietnamese 
                  ? provider.providerName 
                  : translationService.smartTranslate(provider.providerName);
              return Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: ThemeHelper.getTextColor(context),
                ),
              );
            },
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "${context.tr('order_code')}: ${detail.bookingCode}",
              style: TextStyle(
                fontSize: 13,
                color: ThemeHelper.getSecondaryTextColor(context),
              ),
            ),
          ),
        ),
      );
    }

    // ========================================
    // STAFF CARD
    // ========================================
    Widget _staffCard(HistoryBookingDetail detail) {
      return Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ThemeHelper.getBorderColor(context),
                width: 1,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: detail.staffImage != null
                  ? CachedNetworkImageProvider(detail.staffImage!)
                  : null,
              child: detail.staffImage == null
                  ? Icon(
                      Icons.person_rounded,
                      color: ThemeHelper.getSecondaryIconColor(context),
                    )
                  : null,
            ),
          ),
          title: Text(
            detail.staffName!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: ThemeHelper.getTextColor(context),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "${context.tr('phone_number')}: ${detail.staffPhone ?? context.tr('not_available')}",
              style: TextStyle(
                fontSize: 13,
                color: ThemeHelper.getSecondaryTextColor(context),
              ),
            ),
          ),
        ),
      );
    }

    // ========================================
    // TIMELINE CARD
    // ========================================
    Widget _timelineCard(HistoryBookingDetail detail) {
      return Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getLightBlueBackgroundColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.timeline_rounded,
                      color: ThemeHelper.getPrimaryColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('order_timeline'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...detail.timeline.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                final time = e.time?.toLocal();
                final isLast = index == detail.timeline.length - 1;
                
                // Xác định các code cần hiển thị proofs (giống web frontend)
                final codeUpper = e.code.toUpperCase();
                final shouldShowProofs = codeUpper == "CONFIRMED" ||
                    codeUpper == "INPROGRESS" ||
                    codeUpper == "IN PROGRESS" ||
                    codeUpper == "COMPLETED" ||
                    codeUpper == "CHECK IN" ||
                    codeUpper == "CHECK OUT";
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: ThemeHelper.isDarkMode(context)
                                  ? Colors.green.shade900.withOpacity(0.3)
                                  : Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: Colors.green.shade400,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 35,
                              color: ThemeHelper.getDividerColor(context),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                final locale = widget.ref.read(localeProvider);
                                final isVietnamese = locale.languageCode == 'vi';
                                final translationService = DataTranslationService(widget.ref);
                                final title = isVietnamese 
                                    ? e.title 
                                    : translationService.smartTranslate(e.title);
                                return Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeHelper.getTextColor(context),
                                  ),
                                );
                              },
                            ),
                            if (e.description != null)
                              Builder(
                                builder: (context) {
                                  final locale = widget.ref.read(localeProvider);
                                  final isVietnamese = locale.languageCode == 'vi';
                                  final translationService = DataTranslationService(widget.ref);
                                  final description = isVietnamese 
                                      ? e.description! 
                                      : translationService.smartTranslate(e.description!);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: ThemeHelper.getSecondaryTextColor(context),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            Text(
                              time != null
                                  ? DateFormat("dd/MM/yyyy HH:mm").format(time)
                                  : context.tr('not_updated'),
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemeHelper.getTertiaryTextColor(context),
                              ),
                            ),
                            // Hiển thị proofs (ảnh check-in/check-out)
                            if (shouldShowProofs && e.proofs.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: e.proofs.map((proof) {
                                  if (proof.mediaType.toLowerCase() == "image") {
                                    return GestureDetector(
                                      onTap: () {
                                        // Mở ảnh fullscreen
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: InteractiveViewer(
                                                    child: CachedNetworkImage(
                                                      imageUrl: proof.url,
                                                      fit: BoxFit.contain,
                                                      errorWidget: (context, url, error) =>
                                                          const Icon(Icons.error, color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: IconButton(
                                                    icon: const Icon(Icons.close, color: Colors.white),
                                                    onPressed: () => Navigator.of(context).pop(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: proof.url,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            width: 80,
                                            height: 80,
                                            color: ThemeHelper.getLightBackgroundColor(context),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: ThemeHelper.getPrimaryColor(context),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            width: 80,
                                            height: 80,
                                            color: ThemeHelper.getLightBackgroundColor(context),
                                            child: Icon(
                                              Icons.error,
                                              color: ThemeHelper.getSecondaryIconColor(context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Video - hiển thị icon play
                                    return GestureDetector(
                                      onTap: () {
                                        // TODO: Mở video player
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(context.tr('video_player_not_implemented'))),
                                        );
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: ThemeHelper.getLightBackgroundColor(context),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          size: 40,
                                          color: ThemeHelper.getSecondaryIconColor(context),
                                        ),
                                      ),
                                    );
                                  }
                                }).toList(),
                              ),
                            ],
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
    Widget _paymentCard(HistoryBookingDetail detail) {
    print("🔥 lineTotal runtimeType = ${detail.service.lineTotal.runtimeType}");
print("🔥 discount runtimeType = ${detail.voucherDiscount.runtimeType}");
print("🔥 lineTotal = ${detail.service.lineTotal}");
print("🔥 discount = ${detail.voucherDiscount}");
print("🔥 TOTAL = ${detail.service.lineTotal - detail.voucherDiscount}");
      final price = detail.service.lineTotal;
      final discount = detail.voucherDiscount;
      final total = price - discount;

      return Container(
        decoration: BoxDecoration(
          color: ThemeHelper.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeHelper.getBorderColor(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeHelper.getShadowColor(context),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getLightBlueBackgroundColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.payment_rounded,
                      color: ThemeHelper.getPrimaryColor(context),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('payment_info'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _priceRow(
                context.tr('service_price'),
                "${NumberFormat('#,###').format(price)} ₫",
              ),
              _priceRow(
                context.tr('discount'),
                "-${NumberFormat('#,###').format(discount)} ₫",
              ),
              const Divider(),
              _priceRow(
                context.tr('total_amount'),
                "${NumberFormat('#,###').format(total)} ₫",
                isTotal: true,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeHelper.getInputBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeHelper.getBorderColor(context),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payment_rounded,
                          size: 16,
                          color: ThemeHelper.getSecondaryIconColor(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${context.tr('payment_method_label')}: ",
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeHelper.getSecondaryTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          detail.paymentMethod ?? context.tr('not_paid'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ThemeHelper.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: ThemeHelper.getSecondaryIconColor(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${context.tr('payment_status')}: ",
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeHelper.getSecondaryTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPaymentStatusColor(detail.paymentStatus)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getPaymentStatusColor(detail.paymentStatus),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getPaymentStatusText(context, detail.paymentStatus),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getPaymentStatusColor(detail.paymentStatus),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    String _getPaymentStatusText(BuildContext context, String? status) {
      if (status == null || status.isEmpty) {
        return context.tr('not_paid');
      }
      final s = status.toLowerCase();
      if (s.contains("paid") || s.contains("đã thanh toán") || s.contains("thành công")) {
        return context.tr('paid');
      }
      if (s.contains("pending") || s.contains("chờ")) {
        return context.tr('pending_payment');
      }
      if (s.contains("failed") || s.contains("thất bại")) {
        return context.tr('payment_failed');
      }
      if (s.contains("refund") || s.contains("hoàn")) {
        return context.tr('refunded');
      }
      
      // Dịch status nếu không khớp với các trường hợp trên
      final locale = widget.ref.read(localeProvider);
      final isVietnamese = locale.languageCode == 'vi';
      if (isVietnamese) {
        return status;
      }
      final translationService = DataTranslationService(widget.ref);
      return translationService.smartTranslate(status);
    }

    Color _getPaymentStatusColor(String? status) {
      if (status == null || status.isEmpty) {
        return Colors.orange;
      }
      final s = status.toLowerCase();
      if (s.contains("paid") || s.contains("đã thanh toán") || s.contains("thành công")) {
        return Colors.green;
      }
      if (s.contains("pending") || s.contains("chờ")) {
        return Colors.orange;
      }
      if (s.contains("failed") || s.contains("thất bại")) {
        return Colors.red;
      }
      if (s.contains("refund") || s.contains("hoàn")) {
        return Colors.blue;
      }
      return ThemeHelper.getSecondaryTextColor(context); // Use theme color for default
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
              color: ThemeHelper.getTextColor(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal
                  ? ThemeHelper.getPrimaryColor(context)
                  : ThemeHelper.getTextColor(context),
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      );
    }

    // ========================================
    // REFUND CARD (if canceled)
    // ========================================
    Widget _refundCard(HistoryBookingDetail detail) {
      final isDark = ThemeHelper.isDarkMode(context);
      return Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.red.shade900.withOpacity(0.3)
              : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.shade400,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.shade900.withOpacity(0.5)
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('notification'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeHelper.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final cancelReasonText = detail.cancelReason;
                        if (cancelReasonText == null) {
                          return const SizedBox.shrink();
                        }
                        final locale = widget.ref.read(localeProvider);
                        final isVietnamese = locale.languageCode == 'vi';
                        final translationService = DataTranslationService(widget.ref);
                        final translatedReason = isVietnamese 
                            ? cancelReasonText 
                            : translationService.smartTranslate(cancelReasonText);
                        return Text(
                          "${context.tr('reason')}: $translatedReason",
                          style: TextStyle(
                            fontSize: 14,
                            color: ThemeHelper.getTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    if (detail.resolutionNote != null) ...[
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final locale = widget.ref.read(localeProvider);
                          final isVietnamese = locale.languageCode == 'vi';
                          final translationService = DataTranslationService(widget.ref);
                          final resolutionNote = isVietnamese 
                              ? detail.resolutionNote! 
                              : translationService.smartTranslate(detail.resolutionNote!);
                          return Text(
                            "${context.tr('note')}: $resolutionNote",
                            style: TextStyle(
                              fontSize: 13,
                              color: ThemeHelper.getSecondaryTextColor(context),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ========================================
    // ACTION BUTTONS
    // ========================================
  Widget _actionButtons(BuildContext context, HistoryBookingDetail detail) {
    final statusLower = detail.status.toLowerCase().trim();
    
    // Kiểm tra chặt chẽ từng trạng thái
    final isConfirmed = statusLower.contains("confirmed") && !statusLower.contains("completed");
    final isServiceCompleted = statusLower == "service completed" || 
                               statusLower == "servicecompleted" ||
                               (statusLower.contains("service") && statusLower.contains("completed"));
    // Chỉ "completed" thuần túy (không phải service completed, không phải confirmed)
    final isCompleted = (statusLower == "completed" || 
                        (statusLower.contains("completed") && !statusLower.contains("service"))) &&
                        !isConfirmed;
    
    final isCompletedOrServiceCompleted = isCompleted || isServiceCompleted;
    
    // Chỉ cho phép đánh giá khi là "Completed" thuần túy (không phải Service Completed, không phải Confirmed)
    var canReview = isCompleted && !isConfirmed && !detail.hasReview;
    var canReport = isCompletedOrServiceCompleted;
    
    // Kiểm tra xem đã qua 7 ngày từ khi hoàn thành chưa
    // Chỉ check 7 ngày cho đánh giá nếu là Completed
    if (isCompleted && canReview) {
      DateTime? completedDate = detail.completedAt;
      
      // Nếu không có completedAt, thử lấy từ timeline
      if (completedDate == null && detail.timeline.isNotEmpty) {
        // Thử tìm event có code liên quan đến completed/check out
        final possibleCodes = ["CHECK OUT", "Check Out", "CHECKOUT", "check out", 
                              "COMPLETED", "Completed", "completed"];
        
        for (var code in possibleCodes) {
          try {
            final event = detail.timeline.firstWhere(
              (e) => e.code.toUpperCase() == code.toUpperCase(),
            );
            if (event.time != null) {
              completedDate = event.time;
              break;
            }
          } catch (e) {
            // Không tìm thấy event với code này, tiếp tục tìm
            continue;
          }
        }
        
        // Nếu vẫn không tìm thấy, thử tìm event có code chứa "out" hoặc "complete"
        if (completedDate == null) {
          try {
            final completedEvent = detail.timeline.firstWhere(
              (e) => e.code.toUpperCase().contains("OUT") || 
                     e.code.toUpperCase().contains("COMPLETE"),
            );
            if (completedEvent.time != null) {
              completedDate = completedEvent.time;
            }
          } catch (e) {
            // Không tìm thấy event, giữ completedDate = null
          }
        }
      }
      
      // Tính số ngày từ khi hoàn thành
      if (completedDate != null) {
        final now = DateTime.now();
        final daysSinceCompleted = now.difference(completedDate).inDays;
        // Nếu đã qua 7 ngày (>= 7) thì không cho đánh giá nữa
        final within7Days = daysSinceCompleted < 7;
        canReview = canReview && within7Days; // Chỉ cho phép đánh giá nếu chưa qua 7 ngày
      }
      // Nếu không có thông tin về thời gian hoàn thành, vẫn cho phép đánh giá (fallback)
    }
    
    // Kiểm tra 7 ngày cho báo cáo (áp dụng cho cả Completed và Service Completed)
    if (isCompletedOrServiceCompleted) {
      DateTime? completedDate = detail.completedAt;
      
      // Nếu không có completedAt, thử lấy từ timeline
      if (completedDate == null && detail.timeline.isNotEmpty) {
        final possibleCodes = ["CHECK OUT", "Check Out", "CHECKOUT", "check out", 
                              "COMPLETED", "Completed", "completed"];
        
        for (var code in possibleCodes) {
          try {
            final event = detail.timeline.firstWhere(
              (e) => e.code.toUpperCase() == code.toUpperCase(),
            );
            if (event.time != null) {
              completedDate = event.time;
              break;
            }
          } catch (e) {
            continue;
          }
        }
        
        if (completedDate == null) {
          try {
            final completedEvent = detail.timeline.firstWhere(
              (e) => e.code.toUpperCase().contains("OUT") || 
                     e.code.toUpperCase().contains("COMPLETE"),
            );
            if (completedEvent.time != null) {
              completedDate = completedEvent.time;
            }
          } catch (e) {
            // Không tìm thấy event
          }
        }
      }
      
      if (completedDate != null) {
        final now = DateTime.now();
        final daysSinceCompleted = now.difference(completedDate).inDays;
        final within7Days = daysSinceCompleted < 7;
        canReport = within7Days;
      }
    }
    
    return Column(
      children: [
        // ==== ⭐ NÚT THANH TOÁN VNPay ====
        if (detail.status.toLowerCase().contains("confirmed") &&
            (detail.paymentStatus == null ||
            detail.paymentStatus!.toLowerCase().contains("chưa")))
          Consumer(builder: (context, ref, _) {
            final vm = ref.watch(paymentViewModelProvider);
            final isLoading = vm is AsyncLoading;

            return Column(
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          print("Thanh toán được bấm!");

                          final amount = detail.service.lineTotal - detail.voucherDiscount;

                          ref.read(paymentViewModelProvider.notifier).payBooking(
                                bookingId: detail.bookingId,
                                amount: amount.toDouble(),
                                context: context,
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: ThemeHelper.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.payment_rounded),
                  label: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          context.tr('pay_now'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

        // ==== ⭐ NÚT ĐÁNH GIÁ ====
        // Hiển thị khi Completed (không phải Service Completed), chưa đánh giá và chưa qua 7 ngày
        if (canReview)
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  // Navigate to review screen
                  final result = await context.push<bool>(
                    Routes.review,
                    extra: detail,
                  );
                  // Refresh nếu review thành công
                  if (result == true && mounted) {
                    widget.ref.invalidate(historyDetailProvider(widget.bookingId));
                  }
                },
                icon: const Icon(Icons.star_rounded),
                label: Text(
                  context.tr('review_service'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),

        // ==== ⭐ NÚT BÁO CÁO ====
        // Hiển thị khi Completed hoặc Service Completed và chưa qua 7 ngày
        if (canReport)
          _ReportButton(
            bookingId: detail.bookingId,
            detail: detail,
            parentRef: widget.ref,
          ),
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
      return ThemeHelper.getSecondaryTextColor(context); // Use theme color for default
    }
  }

  // ========================================
  // REPORT BUTTON WIDGET
  // ========================================
  class _ReportButton extends ConsumerWidget {
    final String bookingId;
    final HistoryBookingDetail detail;
    final WidgetRef parentRef;

    const _ReportButton({
      required this.bookingId,
      required this.detail,
      required this.parentRef,
    });

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final asyncReport = ref.watch(reportByBookingIdProvider(bookingId));

      return asyncReport.when(
        loading: () => const SizedBox.shrink(),
        error: (e, st) => ElevatedButton.icon(
          onPressed: () async {
            // Navigate to report screen
            final result = await context.push<bool>(
              Routes.report,
              extra: detail,
            );
            // Refresh nếu report thành công
            if (result == true && context.mounted) {
              ref.invalidate(reportByBookingIdProvider(bookingId));
              parentRef.invalidate(historyDetailProvider(bookingId));
            }
          },
          icon: const Icon(Icons.report_problem_rounded),
          label: Text(
            context.tr('report'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        data: (report) {
          if (report == null) {
            // Chưa có report - hiển thị nút "Báo cáo"
            return ElevatedButton.icon(
              onPressed: () async {
                // Navigate to report screen
                final result = await context.push<bool>(
                  Routes.report,
                  extra: detail,
                );
                // Refresh nếu report thành công
                if (result == true && context.mounted) {
                  ref.invalidate(reportByBookingIdProvider(bookingId));
                  parentRef.invalidate(historyDetailProvider(bookingId));
                }
              },
              icon: const Icon(Icons.report_problem_rounded),
              label: Text(
                context.tr('report'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            );
          } else {
            // Đã có report - hiển thị nút "Xem báo cáo"
            return ElevatedButton.icon(
              onPressed: () {
                // Navigate to report detail screen
                context.push(
                  Routes.reportDetailPath(report.complaintId),
                );
              },
              icon: const Icon(Icons.visibility_rounded),
              label: Text(
                context.tr('view_report'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            );
          }
        },
      );
    }
  }
