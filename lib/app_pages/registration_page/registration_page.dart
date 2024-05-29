import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../app_config/app_constants.dart';
import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_themes/custom_theme.dart';
import '../../app_utils/app_loading/alert_services.dart';
import 'validators/validators.dart';
import 'widget/aadhaar_form_field.dart';
import 'widget/aadhaar_otp_form_field.dart';
import 'widget/reg_file_upload_form.dart';
import 'widget/reg_text_form_widget.dart';

class RegistrationPage extends StatefulWidget {
  final String campusId;
  const RegistrationPage({super.key, required this.campusId});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  AlertServices alertServices = AlertServices();
  CampusServices campusServices = CampusServices();
  CustomerService customerService = CustomerService();
  SecureStorage secureStorage = SecureStorage();
  List campusDetail = [];
  List campusDocList = [];
  List aadhaarDetails = [];

  final _formKey = GlobalKey<FormState>();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController genderCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController rollNoCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();
  TextEditingController altContactCtrl = TextEditingController();
  TextEditingController aadhaarCtrl = TextEditingController();
  TextEditingController aadhaarOTPCtrl = TextEditingController();
  final List<TextEditingController> _controllers = [];

  var aadhaarMask = MaskTextInputFormatter(
      mask: '#### #### ####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  bool isPhotoTaken = false;
  bool isAadhaarVerified = false;
  bool isAadhaarRequired = false;
  bool aadhaarOtpSent = false;
  bool aadhaarField = false;
  String clientId = "";
  @override
  void initState() {
    getCampusDetails();
    setState(() {
      contactCtrl.text = secureStorage.get("mobile") ?? "";
    });
    super.initState();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    genderCtrl.dispose();
    emailCtrl.dispose();
    rollNoCtrl.dispose();
    altContactCtrl.dispose();
    contactCtrl.dispose();
    aadhaarCtrl.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  getCampusDetails() {
    alertServices.showLoading();
    campusServices.getCampusById(widget.campusId).then((response) async {
      alertServices.hideLoading();
      campusDetail = [response];
      campusDocList = campusDetail[0]['campusDocList'];
      print("campusDocList $campusDocList");
      var a =
          campusDocList.where((e) => e['mandatory'].toString() == 'Y').toList();
      var b = a
          .where((e) =>
              e['documentId'].toString().toLowerCase().contains("aadharproof"))
          .toList();
      print("a $a");
      print("b $b");
      isAadhaarRequired = b.isNotEmpty ? true : false;
      setState(() {});
      for (var control in campusDocList) {
        _controllers.add(TextEditingController());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (campusDetail.isNotEmpty) ...[
                Container(
                  decoration: CustomTheme.selectedDecoration,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    leading: CachedNetworkImage(
                      width: 40,
                      height: 40,
                      imageUrl: campusDetail[0]['logoUrl'].toString(),
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/app/no-img.png",
                        height: 50,
                        width: 50,
                      ),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    title: Text(
                      campusDetail[0]['campusName'].toString(),
                      overflow: TextOverflow.clip,
                      style: CustomTheme.listTittleStyle,
                    ),
                    trailing: const Text(
                      "Selected Campus",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 25),
              const Text(
                "We're getting you all geared up!",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Let's get to know better...",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const ScrollPhysics(),
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextFormWidget(
                            title: 'Full Name',
                            controller: nameCtrl,
                            required: true,
                            prefixIcon: Icons.account_circle_outlined,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                RegExp('[a-z A-Z 0-9]'),
                              ),
                            ],
                            validator: (value) {
                              if (value.toString().trim().isEmpty) {
                                return "Full Name is Mandatory!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Theme(
                            data: Theme.of(context).copyWith(
                                // inputDecorationTheme: InputDecorationTheme(
                                //   border: OutlineInputBorder(
                                //     borderRadius: BorderRadius.circular(10),
                                //     borderSide: const BorderSide(
                                //       color: Color(0xffD2D2D2),
                                //     ),
                                //   ),
                                //   errorStyle: const TextStyle(
                                //     color: Colors.redAccent,
                                //     fontSize: 12,
                                //     fontWeight: FontWeight.normal,
                                //   ),
                                //   errorBorder: OutlineInputBorder(
                                //     borderRadius: BorderRadius.circular(10),
                                //     borderSide: const BorderSide(
                                //         color: Colors.redAccent, width: 1),
                                //   ),
                                //   focusedBorder: const OutlineInputBorder(
                                //     borderRadius: BorderRadius.all(
                                //       Radius.circular(10),
                                //     ),
                                //     borderSide: BorderSide(
                                //       color: Color(0xffD2D2D2),
                                //     ),
                                //   ),
                                //   // contentPadding: const EdgeInsets.only(left: 5),
                                //   isDense: false,
                                // ),g
                                ),
                            child: DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              alignment: Alignment.center,
                              validator: (value) {
                                if (value == null) {
                                  return "Gender is Mandatory!";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Gender',
                                alignLabelWithHint: true,
                                // isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 0),
                                hintStyle: CustomTheme.formHintStyle,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                      color: Color(0xffD2D2D2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xffD2D2D2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xffD2D2D2)),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                ),
                              ),
                              style: CustomTheme.formFieldStyle,
                              isExpanded: false,
                              items: <String>['Male', 'Female', 'Others']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: CustomTheme.formFieldStyle,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  genderCtrl.text = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormWidget(
                            title: 'College Email ID',
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            required: true,
                            prefixIcon: Icons.alternate_email_outlined,
                            textCapitalization: TextCapitalization.none,
                            inputFormatters: [CustomTextInputFormatter()],
                            validator: (value) {
                              if (value.toString().trim().isEmpty) {
                                return "Email ID is Mandatory!";
                              } else if (!Validators.isValidEmail(value)) {
                                return "Invalid Email ID!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormWidget(
                            title: 'Roll Number',
                            controller: rollNoCtrl,
                            required: true,
                            prefixIcon: Icons.perm_identity,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp('[a-z A-Z 0-9]')),
                            ],
                            validator: (value) {
                              if (value.toString().trim().isEmpty) {
                                return "Roll Number is Mandatory!";
                              }
                              if (value.toString().trim().length > 15) {
                                return "Invalid Roll Number!";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormWidget(
                            title: 'Contact Number',
                            controller: contactCtrl,
                            maxLength: 10,
                            required: true,
                            readOnly: true,
                          ),
                          const SizedBox(height: 16),
                          TextFormWidget(
                            title: 'Alt Contact',
                            controller: altContactCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            required: false,
                            prefixIcon: Icons.phone_iphone_outlined,
                          ),
                          const SizedBox(height: 16),
                          AadhaarFormField(
                              title: 'Aadhaar Number',
                              required: true,
                              readOnly: aadhaarField,
                              controller: aadhaarCtrl,
                              prefixIcon: Icons.person_pin_outlined,
                              inputFormatters: [aadhaarMask],
                              maxLength: 14,
                              onChanged: (String value) {
                                if (value.toString().trim().length == 14) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              validator: (value) {
                                if (isAadhaarRequired) {
                                  if (value.toString().trim().isEmpty) {
                                    return "Aadhaar Number is Mandatory!";
                                  }
                                  if (value.toString().trim().length != 14) {
                                    return "Invalid aadhaar number!";
                                  }
                                }
                                return null;
                              },
                              otpSent: (bool otpSent, String id) {
                                setState(() {
                                  aadhaarOtpSent = otpSent;
                                  clientId = id;
                                });
                              }),
                          const SizedBox(height: 16),
                          if (aadhaarOtpSent) ...[
                            AadhaarOtpFormField(
                              title: 'Verify OTP',
                              required: true,
                              clientId: clientId,
                              prefixIcon: Icons.pin_outlined,
                              maxLength: 6,
                              onChanged: (String value) {
                                if (value.toString().trim().length == 6) {
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              onConfirm: (List list) {
                                if (list.isNotEmpty) {
                                  aadhaarOtpSent = false;
                                  aadhaarField = true;
                                  isAadhaarVerified = true;
                                  aadhaarDetails = list;
                                  setState(() {});
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (campusDetail.isNotEmpty)
                            for (int i = 0; i < campusDocList.length; i++) ...[
                              FileUploadForm(
                                controller: _controllers[i],
                                documentId:
                                    campusDocList[i]['documentId'].toString(),
                                title: getFileName(campusDocList[i]),
                                required: campusDocList[i]['mandatory'] == 'Y',
                                onDataReceived: (String url) {
                                  campusDocList[i]['url'] = url;
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (campusDocList[i]['mandatory'] == 'Y') {
                                    if (value.toString().trim().isEmpty) {
                                      return "${campusDocList[i]['documentName']} Mandatory!";
                                    }
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              AppButtonWidget(
                title: "Proceed",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (isAadhaarRequired) {
                      if (isAadhaarVerified) {
                        submitForm();
                      } else {
                        Fluttertoast.cancel();
                        alertServices
                            .errorToast("Please verify aadhaar number!");
                      }
                    } else {
                      submitForm();
                    }
                  }
                },
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  getGender(String gender) {
    // 'Male', 'Female', 'Others'
    if (gender == "Male") {
      return "M";
    } else if (gender == "Female") {
      return "F";
    } else {
      return "Others";
    }
  }

  submitForm() {
    List docList = campusDocList;
    List uploadArray = [];
    for (int d = 0; d < docList.length; d++) {
      uploadArray.add({
        "name": docList[d]['documentName'],
        "id": docList[d]['documentId'],
        "storageUrl": docList[d]['url'],
      });
    }
    final request = {
      "name": nameCtrl.text,
      "gender": getGender(genderCtrl.text),
      "contact": contactCtrl.text,
      "altContact": altContactCtrl.text,
      "emailId": emailCtrl.text,
      "rollNo": rollNoCtrl.text,
      "aadharNo": aadhaarMask.getUnmaskedText(),
      "aadharVerificationStatus": isAadhaarVerified ? "Y" : "N",
      "organization": campusDetail[0]['campusName'].toString(),
      "documents": uploadArray,
      "aadharDetails": isAadhaarRequired ? aadhaarDetails[0] : {},
    };
    alertServices.showLoading();
    print(jsonEncode(request));
    customerService.createCustomer(request).then((response) async {
      alertServices.hideLoading();
      alertServices.successToast(response['status']);
      secureStorage.save("isLogin", true);
      Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
    });
  }

  getFileName(details) {
    String name = details['documentName'].toString();
    bool required = details['mandatory'] == 'Y';
    if (required) {
      return "$name *";
    }
    return name;
  }
}

class CustomTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final RegExp allowedCharacters = RegExp(r'^[a-zA-Z0-9.@&]*$');
    if (!allowedCharacters.hasMatch(newValue.text)) {
      return oldValue;
    }
    return newValue;
  }
}
