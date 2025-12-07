import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vhs_mobile_user/data/models/notification/notification_model.dart';
import 'package:vhs_mobile_user/ui/notification/notification_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';
import 'package:vhs_mobile_user/services/translation_cache_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final notificationListAsync = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
        backgroundColor: Colors.transparent,
        title: Text(
          context.tr('notifications'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            onSelected: (value) async {
              if (value == 'mark_all_read') {
                await notifier.markAllAsRead();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('all_notifications_marked_read')),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else if (value == 'clear_all') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(context.tr('clear_all_notifications')),
                    content: Text(context.tr('confirm_clear_all_notifications')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(context.tr('cancel')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text(context.tr('clear')),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await notifier.clearAllNotifications();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('all_notifications_cleared')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    const Icon(Icons.done_all, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(context.tr('mark_all_read')),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_sweep, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(context.tr('clear_all')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await notifier.refresh();
        },
        color: ThemeHelper.getPrimaryColor(context),
        child: notificationListAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelper.getPrimaryColor(context),
              ),
            ),
          ),
          error: (e, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${context.tr('error')}: $e',
                  style: TextStyle(color: ThemeHelper.getTextColor(context)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    notifier.refresh();
                  },
                  child: Text(context.tr('try_again')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeHelper.getPrimaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getLightBlueBackgroundColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: ThemeHelper.getPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.tr('no_notifications'),
                      style: TextStyle(
                        color: ThemeHelper.getSecondaryTextColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationItem(
                  notification: notification,
                  onTap: () async {
                    // Luôn đánh dấu đã đọc khi tap vào thông báo
                    await notifier.markAsRead(notification.notificationId);
                  },
                  onDelete: () async {
                    await notifier.deleteNotification(notification.notificationId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('notification_deleted')),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    ref.watch(translationCacheProvider);
    
    final isRead = notification.isRead == true;
    final isDark = ThemeHelper.isDarkMode(context);

    return Dismissible(
      key: Key(notification.notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead
                ? ThemeHelper.getCardBackgroundColor(context)
                : (isDark
                    ? Colors.blue.shade900.withOpacity(0.2)
                    : Colors.blue.shade50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeHelper.getBorderColor(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeHelper.getLightBlueBackgroundColor(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.notificationType),
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.content,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                              color: ThemeHelper.getTextColor(context),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (notification.createdAt != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _formatTime(context, notification.createdAt!),
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeHelper.getTertiaryTextColor(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getNotificationTypeVN(notification.notificationType),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: ThemeHelper.getPrimaryColor(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Convert notification type to Vietnamese (matching web implementation)
  String _getNotificationTypeVN(String type) {
    final t = type.toLowerCase();
    if (t == 'payment_success' || t.contains('thanh toán thành công')) {
      return 'Thanh toán thành công';
    } else if (t == 'new_booking' || t.contains('đơn hàng mới')) {
      return 'Đơn hàng mới';
    } else if (t == 'booking_confirmed' || t == 'confirmed' || t.contains('xác nhận đơn hàng') || t.contains('xác nhận')) {
      return 'Xác nhận đơn hàng';
    } else if (t == 'booking_cancelled' || t == 'canceled' || t.contains('hủy đơn hàng') || t.contains('bị hủy')) {
      return 'Hủy đơn hàng';
    } else if (t == 'booking_completed' || t == 'completed' || t.contains('hoàn thành đơn hàng') || t.contains('hoàn thành')) {
      return 'Hoàn thành đơn hàng';
    } else if (t.contains('payment') || t.contains('thanh toán')) {
      return 'Thanh toán';
    } else if (t.contains('booking') || t.contains('đặt lịch')) {
      return 'Đặt lịch';
    } else if (t == 'system' || t.contains('hệ thống')) {
      return 'Hệ thống';
    } else if (t.contains('promotion') || t.contains('khuyến mãi')) {
      return 'Khuyến mãi';
    } else if (t == 'servicecompleted' || t.contains('xác nhận hoàn thành')) {
      return 'Xác nhận hoàn thành';
    } else if (t.contains('hoàn tiền')) {
      return 'Hoàn tiền';
    } else if (t.contains('khiếu nại')) {
      return 'Khiếu nại';
    } else if (t.contains('message') || t.contains('chat')) {
      return 'Tin nhắn';
    } else if (t.contains('review')) {
      return 'Đánh giá';
    } else if (t.contains('report')) {
      return 'Báo cáo';
    }
    return type; // Return original if no match
  }

  IconData _getNotificationIcon(String type) {
    final t = type.toLowerCase();
    // Match web implementation icon logic
    if (t.contains('payment') || t.contains('thanh toán')) {
      return Icons.payment;
    } else if (t.contains('booking') || t.contains('order') || t.contains('đơn hàng') || t.contains('đặt lịch')) {
      return Icons.calendar_today;
    } else if (t == 'system' || t.contains('hệ thống')) {
      return Icons.settings;
    } else if (t.contains('message') || t.contains('chat')) {
      return Icons.chat;
    } else if (t.contains('review') || t.contains('đánh giá')) {
      return Icons.star;
    } else if (t.contains('report') || t.contains('khiếu nại')) {
      return Icons.report;
    } else if (t.contains('promotion') || t.contains('khuyến mãi')) {
      return Icons.local_offer;
    } else if (t.contains('hoàn tiền')) {
      return Icons.account_balance_wallet;
    }
    return Icons.notifications;
  }

  String _formatTime(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return context.tr('just_now');
        }
        return '${difference.inMinutes} ${context.tr('minutes_ago')}';
      }
      return '${difference.inHours} ${context.tr('hours_ago')}';
    } else if (difference.inDays == 1) {
      return context.tr('yesterday');
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${context.tr('days_ago')}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(time);
    }
  }
}

