class AddCartItemRequest {
  final String serviceId;

  AddCartItemRequest({
    required this.serviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      "serviceId": serviceId,
      "optionIds": [],        // backend OK with empty list
      "optionValues": null,   // backend expects null or empty
    };
  }
}
