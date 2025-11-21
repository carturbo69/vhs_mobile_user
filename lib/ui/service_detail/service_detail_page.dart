import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vhs_mobile_user/data/models/service/service_detail.dart';
import 'package:vhs_mobile_user/ui/service_detail/service_detail_viewmodel.dart';

class ServiceDetailPage extends ConsumerWidget {
  final String id;
  const ServiceDetailPage({super.key, required this.id});

  List<String> parseImages(String? csv) {
    if (csv == null || csv.isEmpty) return [];
    return csv.split(',').map((e) => e.trim()).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(serviceDetailProvider(id).notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Lỗi: $err')),
        data: (detail) => _buildBody(context, detail),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ServiceDetail detail) {
    final images = parseImages(detail.images);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          SizedBox(
            height: 260,
            child: images.isEmpty
                ? const Center(child: Icon(Icons.image_not_supported))
                : PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (c, i) => CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${detail.averageRating.toStringAsFixed(1)} (${detail.totalReviews})',
                    ),
                    const Spacer(),
                    Text(
                      '${detail.price} ${detail.unitType}',
                      style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                if (detail.description != null)
                  Text(detail.description!,
                      style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 16),
                _buildProvider(detail),
                const SizedBox(height: 16),

                _buildOptions(detail),
                const SizedBox(height: 16),

                _buildReviews(detail),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvider(ServiceDetail d) {
    final imgList = parseImages(d.provider.images);

    return ListTile(
      leading: imgList.isNotEmpty
          ? CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(imgList.first),
            )
          : const CircleAvatar(child: Icon(Icons.store)),
      title: Text(d.provider.providerName),
      subtitle: Text(
        'Services: ${d.provider.totalServices} • Rating: ${d.provider.averageRatingAllServices.toStringAsFixed(1)}',
      ),
    );
  }

  Widget _buildOptions(ServiceDetail d) {
    if (d.serviceOptions.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...d.serviceOptions.map(
          (o) => ListTile(
            title: Text(o.optionName),
            subtitle: Text('Type: ${o.type}${o.value != null ? " (${o.value})" : ""}'),
          ),
        ),
      ],
    );
  }

  Widget _buildReviews(ServiceDetail d) {
    if (d.reviews.isEmpty) {
      return const Text('Chưa có review nào',
          style: TextStyle(fontSize: 16));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...d.reviews.map((r) => Card(
              child: ListTile(
                leading: r.avatar != null
                    ? CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(r.avatar!),
                      )
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Row(
                  children: [
                    Text(r.fullName ?? 'User'),
                    const SizedBox(width: 8),
                    Text('${r.rating}/5',
                        style: const TextStyle(color: Colors.amber)),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.comment != null) Text(r.comment!),
                    if (r.images.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: r.images
                              .map(
                                (img) => Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: CachedNetworkImage(
                                    imageUrl: img,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
