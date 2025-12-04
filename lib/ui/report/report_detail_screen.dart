import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/report/report_models.dart';
import 'package:vhs_mobile_user/ui/report/report_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';
import 'package:vhs_mobile_user/services/data_translation_service.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  String _getReportTypeDisplayName(BuildContext context, ReportTypeEnum type) {
    switch (type) {
      case ReportTypeEnum.serviceQuality:
        return context.tr('report_type_service_quality');
      case ReportTypeEnum.providerMisconduct:
        return context.tr('report_type_provider_misconduct');
      case ReportTypeEnum.staffMisconduct:
        return context.tr('report_type_staff_misconduct');
      case ReportTypeEnum.dispute:
        return context.tr('report_type_dispute');
      case ReportTypeEnum.technicalIssue:
        return context.tr('report_type_technical_issue');
      case ReportTypeEnum.refundRequest:
        return context.tr('refund_request');
      case ReportTypeEnum.other:
        return context.tr('report_type_other');
    }
  }

  String _getStatusDisplayName(BuildContext context, String status) {
    final s = status.toLowerCase();
    if (s == 'pending') return context.tr('report_status_pending');
    if (s == 'inreview') return context.tr('report_status_in_review');
    if (s == 'resolved') return context.tr('report_status_resolved');
    if (s == 'rejected') return context.tr('report_status_rejected');
    return status;
  }

  String _getRefundStatusDisplayName(BuildContext context, String status) {
    final s = status.toLowerCase();
    if (s == 'pending') return context.tr('refund_pending');
    if (s == 'approved') return context.tr('refund_approved');
    if (s == 'rejected') return context.tr('refund_rejected');
    return status;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale and translation cache to trigger rebuilds
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final asyncReport = ref.watch(reportByIdProvider(reportId));
    final translationService = DataTranslationService(ref);

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
          context.tr('report_detail'),
          style: const TextStyle(
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
                ref.invalidate(reportByIdProvider(reportId));
              },
              tooltip: context.tr('refresh'),
            ),
          ),
        ],
      ),
      body: asyncReport.when(
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
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ThemeHelper.isDarkMode(context)
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
                  context.tr('error_occurred'),
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
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(reportByIdProvider(reportId)),
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    context.tr('try_again'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHelper.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (report) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trạng thái
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor(context, report.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(context, report.status),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(context, report.status).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(report.status),
                      color: _getStatusColor(context, report.status),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusDisplayName(context, report.status),
                      style: TextStyle(
                        color: _getStatusColor(context, report.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Loại báo cáo
              _buildInfoCard(
                icon: Icons.category_rounded,
                label: context.tr('report_type_label'),
                value: _getReportTypeDisplay(context, report),
                context: context,
              ),
              const SizedBox(height: 16),

              // Tiêu đề
              _buildInfoCard(
                icon: Icons.title_rounded,
                label: context.tr('report_title'),
                value: translationService.smartTranslate(report.title),
                context: context,
              ),
              const SizedBox(height: 16),

              // Mô tả
              if (report.description != null && report.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('description'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ThemeHelper.getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<String>(
                      future: translationService.smartTranslateAsync(report.description!),
                      builder: (context, snapshot) {
                        final description = snapshot.data ?? report.description!;
                        return Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            color: ThemeHelper.getTextColor(context),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Ngày tạo
              if (report.createdAt != null)
                _buildInfoCard(
                  icon: Icons.calendar_today_rounded,
                  label: context.tr('created_date'),
                  value: DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt!),
                  context: context,
                ),
              const SizedBox(height: 16),

              // Hình ảnh đính kèm
              if (report.attachmentUrls != null && report.attachmentUrls!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeHelper.getLightBlueBackgroundColor(context),
                            ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image_rounded,
                              color: ThemeHelper.getPrimaryDarkColor(context),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.tr('attached_images'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: ThemeHelper.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: report.attachmentUrls!.length,
                      itemBuilder: (context, index) {
                        final url = report.attachmentUrls![index];
                        return GestureDetector(
                          onTap: () {
                            // Show full screen image
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => _FullScreenImage(url: url),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: url.startsWith('http')
                                    ? url
                                    : 'http://apivhs.cuahangkinhdoanh.com$url',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: ThemeHelper.getLightBackgroundColor(context),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeHelper.getPrimaryColor(context),
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: ThemeHelper.getLightBackgroundColor(context),
                                  child: Icon(
                                    Icons.image_not_supported_rounded,
                                    color: ThemeHelper.getSecondaryIconColor(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Ghi chú giải quyết
              if (report.resolutionNote != null && report.resolutionNote!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeHelper.getLightBlueBackgroundColor(context),
                            ThemeHelper.getLightBlueBackgroundColor(context).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.note_rounded,
                              color: ThemeHelper.getPrimaryDarkColor(context),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.tr('resolution_note'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: ThemeHelper.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getLightBlueBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
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
                      child: FutureBuilder<String>(
                        future: translationService.smartTranslateAsync(report.resolutionNote!),
                        builder: (context, snapshot) {
                          final note = snapshot.data ?? report.resolutionNote!;
                          return Text(
                            note,
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeHelper.getTextColor(context),
                              height: 1.5,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Thông tin hoàn tiền (nếu có)
              if (report.refundStatus != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: ThemeHelper.isDarkMode(context)
                              ? [
                                  Colors.green.shade900.withOpacity(0.3),
                                  Colors.green.shade800.withOpacity(0.2),
                                ]
                              : [
                                  Colors.green.shade50,
                                  Colors.green.shade100,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade400,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ThemeHelper.isDarkMode(context)
                                  ? Colors.green.shade800.withOpacity(0.5)
                                  : Colors.green.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.green.shade400,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            context.tr('refund_info'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                              color: ThemeHelper.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (report.refundAmount != null)
                      _buildInfoCard(
                        icon: Icons.attach_money_rounded,
                        label: context.tr('amount'),
                        value: "${NumberFormat('#,###').format(report.refundAmount!.toInt())} ₫",
                        context: context,
                      ),
                    const SizedBox(height: 12),
                    if (report.refundStatus != null)
                      _buildInfoCard(
                        icon: Icons.info_rounded,
                        label: context.tr('refund_status'),
                        value: _getRefundStatusDisplayName(context, report.refundStatus!),
                        context: context,
                      ),
                    const SizedBox(height: 12),
                    if (report.bankName != null)
                      _buildInfoCard(
                        icon: Icons.account_balance_rounded,
                        label: context.tr('bank_name'),
                        value: translationService.smartTranslate(report.bankName!),
                        context: context,
                      ),
                    const SizedBox(height: 12),
                    if (report.accountHolderName != null)
                      _buildInfoCard(
                        icon: Icons.person_rounded,
                        label: context.tr('owner'),
                        value: translationService.smartTranslate(report.accountHolderName!),
                        context: context,
                      ),
                    const SizedBox(height: 12),
                    if (report.bankAccountNumber != null)
                      _buildInfoCard(
                        icon: Icons.credit_card_rounded,
                        label: context.tr('bank_account_number'),
                        value: report.bankAccountNumber!,
                        context: context,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemeHelper.getSecondaryTextColor(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: ThemeHelper.getTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    final isDark = ThemeHelper.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: ThemeHelper.getPrimaryDarkColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ThemeHelper.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    final s = status.toLowerCase();
    if (s == 'pending') return Colors.orange.shade600;
    if (s == 'inreview') return Colors.blue.shade600;
    if (s == 'resolved') return Colors.green.shade600;
    if (s == 'rejected') return Colors.red.shade600;
    return ThemeHelper.getSecondaryTextColor(context); // Use theme color for default
  }

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s == 'pending') return Icons.pending_rounded;
    if (s == 'inreview') return Icons.reviews_rounded;
    if (s == 'resolved') return Icons.check_circle_rounded;
    if (s == 'rejected') return Icons.cancel_rounded;
    return Icons.info_rounded;
  }

  String _getReportTypeDisplay(BuildContext context, ReadReportDTO report) {
    // Nếu là RefundRequest thì hiển thị "Yêu cầu hoàn tiền"
    if (report.reportType == ReportTypeEnum.refundRequest) {
      return context.tr('refund_request');
    }
    
    // Nếu là Other nhưng có thông tin ngân hàng hoặc description chứa thông tin hoàn tiền
    // thì hiển thị "Yêu cầu hoàn tiền"
    if (report.reportType == ReportTypeEnum.other) {
      final hasBankInfo = (report.bankName != null && report.bankName!.isNotEmpty) ||
                          (report.accountHolderName != null && report.accountHolderName!.isNotEmpty) ||
                          (report.bankAccountNumber != null && report.bankAccountNumber!.isNotEmpty);
      
      final hasRefundInDescription = report.description != null && 
          (report.description!.contains(context.tr('bank_info_header')) ||
           report.description!.contains("THÔNG TIN NGÂN HÀNG ĐỂ HOÀN TIỀN"));
      
      if (hasBankInfo || hasRefundInDescription) {
        return context.tr('refund_request');
      }
    }
    
    // Mặc định hiển thị theo displayName đã dịch
    return _getReportTypeDisplayName(context, report.reportType);
  }
}

class _FullScreenImage extends StatelessWidget {
  final String url;

  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: url.startsWith('http')
                ? url
                : 'http://apivhs.cuahangkinhdoanh.com$url',
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.error,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

