class SecurityModel {
  Map<String, dynamic> body;
  String url;
  SecurityModel(this.url, this.body);

  @override
  String toString() {
    return "SecurityModel{url: $url, body: $body}";
  }
}
