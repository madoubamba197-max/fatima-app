import '../models/business_booking.dart';

class BookingService {

  static final List<BusinessBooking> _bookings = [];

  static List<BusinessBooking> get bookings => _bookings;

  static Future<void> addBooking(
      BusinessBooking booking) async {

    _bookings.add(booking);

  }

  static Future<void> removeBooking(
      BusinessBooking booking) async {

    _bookings.remove(booking);

  }

  static Future<void> updateStatus(
      BusinessBooking booking,
      String status) async {

    final index = _bookings.indexOf(booking);

    if (index != -1) {

      _bookings[index] = BusinessBooking(

        id: booking.id,

        customerName: booking.customerName,

        phone: booking.phone,

        itemName: booking.itemName,

        price: booking.price,

        date: booking.date,

        hour: booking.hour,

        employee: booking.employee,

        paymentMethod: booking.paymentMethod,

        status: status,

      );

    }

  }

}