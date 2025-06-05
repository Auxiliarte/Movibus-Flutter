import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coupon.dart';

class CouponService {
  static Future<List<Coupon>> fetchCoupons(String baseUrl) async {
    final url = Uri.parse('$baseUrl/cupones');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['coupons'] as List)
          .map((json) => Coupon.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener cupones ahora');
    }
  }
}
