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
      setState(() {});
      for (var control in campusDetail[0]['campusDocList']) {
        _controllers.add(TextEditingController());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
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
                    // trailing: Icon(
                    //   Icons.check_circle_outline,
                    //   color: Theme.of(context).primaryColor,
                    // ),
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
              // const SizedBox(height: 2),
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
                            RegExp('[a-z A-Z 0-9]'))
                      ],
                      validator: (value) {
                        if (value.toString().trim().isEmpty) {
                          return "Full Name is Mandatory!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // RichText(
                    //   text: TextSpan(
                    //     text: "Gender",
                    //     style: CustomTheme.formLabelStyle,
                    //     children: const [
                    //       TextSpan(
                    //         text: ' *',
                    //         style: TextStyle(
                    //           color: Colors.redAccent,
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 5,
                    // ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        // Customize the outline border
                        inputDecorationTheme: InputDecorationTheme(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xffD2D2D2),
                            ),
                          ),
                          errorStyle: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Colors.redAccent, width: 1),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                              color: Color(0xffD2D2D2),
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(left: 5),
                          isDense: false,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        alignment: Alignment.center,
                        validator: (value) {
                          if (value == null) {
                            return "Gender is Mandatory!";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Gender',
                          contentPadding:
                              const EdgeInsets.only(left: 15.0, right: 15),
                          hintStyle: CustomTheme.formHintStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide:
                                const BorderSide(color: Color(0xffD2D2D2)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xffD2D2D2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xffD2D2D2)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          // prefixIcon: const Icon(
                          //   Icons.male_outlined,
                          //   size: 26,
                          //   color: AppColors.primary,
                          // ),
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
                    // TextFormWidget(
                    //   title: 'Gender',
                    //   controller: genderCtrl,
                    //   required: true,
                    //   prefixIcon: Icons.male_outlined,
                    // ),
                    // const SizedBox(height: 16),
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
                            RegExp('[a-z A-Z 0-9]'))
                      ],
                      validator: (value) {
                        if (value.toString().trim().isEmpty) {
                          return "Roll Number is Mandatory!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormWidget(
                      title: 'Contact Number',
                      controller: contactCtrl,
                      // keyboardType: TextInputType.phone,
                      maxLength: 10,
                      required: true,
                      readOnly: true,
                      // prefixIcon: Icons.phone_android_outlined,
                      // inputFormatters: <TextInputFormatter>[
                      //   FilteringTextInputFormatter.digitsOnly
                      // ],
                      // validator: (value) {
                      //   if (value.toString().trim().isEmpty) {
                      //     return "Contact is Mandatory!";
                      //   } else if (value.toString().trim().length != 10) {
                      //     return "Invalid Contact Number!";
                      //   }
                      //   return null;
                      // },
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
                          if (value.toString().trim().isEmpty) {
                            return "Aadhaar Number Mandatory!";
                          }
                          if (value.toString().trim().length != 14) {
                            return "Invalid aadhaar number!";
                          }
                          return null;
                        },
                        otpSent: (bool otpSent, String id) {
                          print("Reg Page - Otp Sent $otpSent");
                          setState(() {
                            aadhaarOtpSent = otpSent;
                            clientId = id;
                          });
                        }
                        // verified: (bool verify, List ad) {
                        //   setState(() {
                        //     isAadhaarVerified = verify;
                        //     aadhaarDetails = ad;
                        //     print("Aadhaar details -> ${ad[0]}");
                        //   });
                        // },
                        ),
                    const SizedBox(height: 16),
                    if (aadhaarOtpSent) ...[
                      AadhaarOtpFormField(
                        title: 'Verify OTP',
                        required: true,
                        clientId: clientId,
                        prefixIcon: Icons.pin_outlined,
                        maxLength: 14,
                        onChanged: (String value) {
                          if (value.toString().trim().length == 14) {
                            FocusScope.of(context).unfocus();
                          }
                        },
                        onConfirm: (List list) {
                          print(list);
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
                      for (int i = 0;
                          i < campusDetail[0]['campusDocList'].length;
                          i++) ...[
                        FileUploadForm(
                          controller: _controllers[i],
                          documentId: campusDetail[0]['campusDocList'][i]
                                  ['documentId']
                              .toString(),
                          title: campusDetail[0]['campusDocList'][i]
                                  ['documentName']
                              .toString(),
                          required: campusDetail[0]['campusDocList'][i]
                                  ['mandatory'] ==
                              'Y',
                          onDataReceived: (String url) {
                            print("URL: $url");
                            campusDetail[0]['campusDocList'][i]['url'] = url;
                            setState(() {});
                          },
                          validator: (value) {
                            if (campusDetail[0]['campusDocList'][i]
                                    ['mandatory'] ==
                                'Y') {
                              if (value.toString().trim().isEmpty) {
                                return "${campusDetail[0]['campusDocList'][i]['documentName']} Mandatory!";
                              }
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    const SizedBox(height: 25),
                    AppButtonWidget(
                      title: "Proceed",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (isAadhaarVerified) {
                            List docList = campusDetail[0]['campusDocList'];
                            List uploadArray = [];
                            for (int d = 0; d < docList.length; d++) {
                              // print("docList $docList");
                              uploadArray.add({
                                "name": docList[d]['documentName'],
                                "id": docList[d]['documentId'],
                                "storageUrl": docList[d]['url'],
                              });
                            }
                            final request = {
                              "name": nameCtrl.text,
                              "gender": genderCtrl.text,
                              "contact": contactCtrl.text,
                              "altContact": altContactCtrl.text,
                              "emailId": emailCtrl.text,
                              "rollNo": rollNoCtrl.text,
                              "aadharNo": aadhaarMask.getUnmaskedText(),
                              "aadharVerificationStatus":
                                  isAadhaarVerified ? "Y" : "N",
                              "organization":
                                  campusDetail[0]['campusName'].toString(),
                              "documents": uploadArray,
                              "aadharDetails": aadhaarDetails[0],
                            };
                            alertServices.showLoading();
                            customerService
                                .createCustomer(request)
                                .then((response) async {
                              alertServices.hideLoading();
                              alertServices.successToast(response['status']);
                              secureStorage.save("isLogin", true);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, "home", (route) => false);
                            });
                          } else {
                            Fluttertoast.cancel();
                            alertServices
                                .errorToast("Please verify aadhaar number!");
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
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
