class AddCartItemRequest {
  final String serviceId;
  final List<String> optionIds;
  final Map<String, dynamic>? optionValues;

  AddCartItemRequest({
    required this.serviceId,
    this.optionIds = const [],
    this.optionValues,
  });

  Map<String, dynamic> toJson() {
    return {
      "serviceId": serviceId,
      "optionIds": optionIds,
      "optionValues": optionValues,
    };
  }
}
