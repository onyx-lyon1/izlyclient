class RequestDataModel {
  Map<String, dynamic> body;
  String url;
  RequestDataModel(this.url, this.body);

  @override
  String toString() {
    return "SecurityModel{url: $url, body: $body}";
  }
}
