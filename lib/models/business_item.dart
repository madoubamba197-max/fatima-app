import 'dart:convert';
import 'dart:typed_data';

class BusinessItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String image;
  final Uint8List? imageBytes;
  final String category;
  final Duration duration;

  BusinessItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.imageBytes,
    required this.category,
    required this.duration,
  });

  factory BusinessItem.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final imageData =
        data["image"]?.toString() ?? "";

    Uint8List? decodedImage;

    if (imageData.isNotEmpty) {
      try {
        decodedImage = base64Decode(imageData);
      } catch (_) {
        decodedImage = null;
      }
    }

    return BusinessItem(
      id: id,

      name:
          data["name"]?.toString() ?? "",

      description:
          data["description"]?.toString() ?? "",

      price:
          data["price"] is int
              ? data["price"]
              : int.tryParse(
                    data["price"]?.toString() ?? "",
                  ) ??
                  0,

      image: imageData,

      imageBytes: decodedImage,

      category:
          data["category"]?.toString() ?? "",

      duration: Duration(
        minutes:
            data["duration"] is int
                ? data["duration"]
                : int.tryParse(
                      data["duration"]?.toString() ?? "",
                    ) ??
                    0,
      ),
    );
  }
}