class VerifyOtpRequestModel {
  String? mobileNos;
  String? otp;
  String? source;

  VerifyOtpRequestModel({this.mobileNos, this.otp, this.source});

  VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) {
    mobileNos = json['mobileNos'];
    otp = json['otp'];
    source = json['source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mobileNos'] = mobileNos;
    data['otp'] = otp;
    data['source'] = source;
    return data;
  }
}
