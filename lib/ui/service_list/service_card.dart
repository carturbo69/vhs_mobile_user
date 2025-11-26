// lib/ui/service_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/service/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = service.imageList; // CSV → List<String>
    final img = images.isNotEmpty ? images.first : null;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.hardEdge,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE =================
            img != null
                ? CachedNetworkImage(
                    imageUrl: img,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const SizedBox(
                      height: 160,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const SizedBox(
                      height: 160,
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  )
                : Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 48),
                  ),

            // ================= INFO =================
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Provider + Category
                  Text(
                    '${service.providerName ?? "Nhà cung cấp"} • ${service.categoryName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),

                  // Price
                  Text(
                    '${service.price.toStringAsFixed(0)} ₫ / ${service.unitType}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Rating row
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        service.averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${service.totalReviews})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ================= OPTIONS TAGS =================
                  if (service.serviceOptions.isNotEmpty) _buildOptionsRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a small horizontal list of tags for options
  Widget _buildOptionsRow() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: service.serviceOptions.take(3).map((opt) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            opt.optionName,
            style: const TextStyle(fontSize: 11, color: Colors.blue),
          ),
        );
      }).toList(),
    );
  }
}
