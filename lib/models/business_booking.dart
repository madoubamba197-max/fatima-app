class BusinessBooking {
  final String id;

  final String customerName;

  final String phone;

  final String itemName;

  final int price;

  final DateTime date;

  final String hour;

  final String employee;

  final String paymentMethod;

  final String status;

  BusinessBooking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.itemName,
    required this.price,
    required this.date,
    required this.hour,
    required this.employee,
    required this.paymentMethod,
    required this.status,
  });
}