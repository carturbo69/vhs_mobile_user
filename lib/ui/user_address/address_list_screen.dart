import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhs_mobile_user/data/models/user/user_address_model.dart';

import 'package:vhs_mobile_user/routing/routes.dart';
import 'package:vhs_mobile_user/ui/user_address/user_address_viewmodel.dart';
import 'package:vhs_mobile_user/ui/core/theme_helper.dart';
import 'package:vhs_mobile_user/l10n/extensions/localization_extension.dart';
import 'package:vhs_mobile_user/providers/locale_provider.dart';

class AddressListPage extends ConsumerWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch locale để rebuild khi đổi ngôn ngữ
    ref.watch(localeProvider);
    
    final asyncData = ref.watch(userAddressProvider);

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
          context.tr('my_addresses'),
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
              onPressed: () => ref.read(userAddressProvider.notifier).refresh(),
              tooltip: context.tr('refresh'),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade600.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push(Routes.addAddress),
          icon: const Icon(Icons.add_location_alt_rounded, size: 22),
          label: Text(
            context.tr('add_address'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: ThemeHelper.getPrimaryColor(context),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      backgroundColor: ThemeHelper.getScaffoldBackgroundColor(context),
      body: asyncData.when(
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
        error: (err, _) {
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
                    context.tr('error_occurred'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ThemeHelper.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$err',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeHelper.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(userAddressProvider.notifier).refresh(),
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
          );
        },
        data: (list) {
          if (list.isEmpty) {
            return _EmptyAddress();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _AddressCard(address: list[i]),
          );
        },
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final UserAddressModel address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () {
          // Có thể thêm navigation hoặc action khi tap vào card
        },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ThemeHelper.getLightBlueBackgroundColor(context),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: ThemeHelper.getPrimaryColor(context),
              size: 24,
            ),
          ),
          title: Text(
            address.fullAddress,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: ThemeHelper.getTextColor(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (address.recipientName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ThemeHelper.getLightBackgroundColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: ThemeHelper.getSecondaryIconColor(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${context.tr('recipient')}: ${address.recipientName!}",
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeHelper.getSecondaryTextColor(context),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (address.recipientPhone != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getLightBackgroundColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: ThemeHelper.getSecondaryIconColor(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${context.tr('phone')}: ${address.recipientPhone!}",
                        style: TextStyle(
                          fontSize: 13,
                          color: ThemeHelper.getSecondaryTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeHelper.getLightBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.more_vert_rounded,
              color: ThemeHelper.getSecondaryIconColor(context),
              size: 20,
            ),
          ),
          color: ThemeHelper.getPopupMenuBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          itemBuilder: (_) {
            final isDark = ThemeHelper.isDarkMode(context);
            return [
              PopupMenuItem(
                value: "edit",
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ThemeHelper.getLightBlueBackgroundColor(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: ThemeHelper.getPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('edit'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ThemeHelper.getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "delete",
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.red.shade900.withOpacity(0.3)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('delete'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          onSelected: (value) async {
            if (value == "edit") {
              context.push(Routes.addAddress, extra: address);
            } else {
              await ref
                  .read(userAddressProvider.notifier)
                  .remove(address.addressId);
            }
          },
        ),
        ),
      ),
    );
  }
}

class _EmptyAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: ThemeHelper.getLightBlueBackgroundColor(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 80,
                color: ThemeHelper.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('no_addresses_yet'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeHelper.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('add_new_address'),
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push(Routes.addAddress);
              },
              icon: const Icon(Icons.add_location_alt_rounded, size: 20),
              label: Text(
                context.tr('add_first_address'),
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
    );
  }
}
