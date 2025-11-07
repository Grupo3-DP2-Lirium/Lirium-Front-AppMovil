/// Modelo de respuesta para el enlace de compartir memorial
class ShareLinkResponse {
  final String shareUrl;
  final String slug;

  ShareLinkResponse({
    required this.shareUrl,
    required this.slug,
  });

  /// Crear desde JSON
  factory ShareLinkResponse.fromJson(Map<String, dynamic> json) {
    return ShareLinkResponse(
      shareUrl: json['url'] as String,  // El backend envía 'url'
      slug: json['slug'] as String,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'url': shareUrl,
      'slug': slug,
    };
  }
}
