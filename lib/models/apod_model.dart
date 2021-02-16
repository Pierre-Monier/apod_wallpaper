class Apod {
  String date;
  String explanation;
  String mediaType;
  String serviceVersion;
  String thumbnailUrl;
  String title;
  String url;

  String getTitle() {
    return date + " : " + title;
  }

  bool isImage() {
    return (thumbnailUrl == null);
  }

  Apod.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    explanation = json['explanation'];
    mediaType = json['media_type'];
    serviceVersion = json['service_version'];
    thumbnailUrl = json['thumbnail_url'];
    title = json['title'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['explanation'] = this.explanation;
    data['media_type'] = this.mediaType;
    data['service_version'] = this.serviceVersion;
    data['thumbnail_url'] = this.thumbnailUrl;
    data['title'] = this.title;
    data['url'] = this.url;
    return data;
  }
}