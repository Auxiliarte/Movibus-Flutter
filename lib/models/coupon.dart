class Coupon {
  final int id;
  final String texto;
  final int descuento;
  final String? imagen;

  Coupon({
    required this.id,
    required this.texto,
    required this.descuento,
    this.imagen,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      texto: json['texto'],
      descuento: json['descuento'],
      imagen: json['imagen'],
    );
  }
}
