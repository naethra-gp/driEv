import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_utils/app_form/custom_dropdown.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:path_provider/path_provider.dart';

import '../../app_config/app_constants.dart';
import '../../app_services/Coupon_services.dart';
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
  CouponServices couponServices = CouponServices();

  final _formKey = GlobalKey<FormState>();

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController genderCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController rollNoCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();
  TextEditingController altContactCtrl = TextEditingController();
  TextEditingController aadhaarCtrl = TextEditingController();
  TextEditingController passportCtrl = TextEditingController();
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
  late String nationalitySelection;
  bool showAadhaarField = false;
  bool showOverseasField = false;
  bool isAadhaarCtrlDisposed = false;
  bool isVerified = false;
  bool isVerifyDisabled = false;

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
    passportCtrl.dispose();

    if (aadhaarCtrl != null) {
      aadhaarCtrl.dispose();
      isAadhaarCtrlDisposed = true;
    }

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
      var a =
          campusDocList.where((e) => e['mandatory'].toString() == 'Y').toList();
      var b = a
          .where((e) =>
              e['documentId'].toString().toLowerCase().contains("aadharproof"))
          .toList();
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                          CustomDropdown(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Gender is Mandatory!";
                              }
                              return null;
                            },
                            dropdownMenuEntries: ['Male', 'Female', 'Others']
                                .map((e) => e)
                                .toList()
                                .map<DropdownMenuEntry<String>>((value) {
                              return DropdownMenuEntry<String>(
                                value: value,
                                label: value,
                              );
                            }).toList(),
                            title: "Gender",
                            onSelected: (value) {
                              setState(() {
                                genderCtrl.text = value!.toString();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormWidget(
                            title: 'College Email ID',
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            required: true,
                            readOnly: isVerified,
                            prefixIcon: Icons.alternate_email_outlined,
                            textCapitalization: TextCapitalization.none,
                            inputFormatters: [CustomTextInputFormatter()],
                            onVerify: verifyEmail,
                            validator: (value) {
                              if (value.toString().trim().isEmpty) {
                                return "Email ID is Mandatory!";
                              } else if (!Validators.isValidEmail(value)) {
                                return "Invalid Email ID!";
                              }
                              return null;
                            },
                            isVerified: isVerified,
                            isVerifyDisabled: isVerifyDisabled,
                          ),
                          if (isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 5, top: 2),
                              child: Text(
                                "Check your inbox to verify the email.",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontFamily: "Roboto-Regular",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
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
                            title: 'Alternative Contact',
                            controller: altContactCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            required: false,
                            prefixIcon: Icons.phone_iphone_outlined,
                          ),
                          const SizedBox(height: 16),
                          CustomDropdown(
                            dropdownMenuEntries: ['Indian', 'Overseas']
                                .map((e) => e)
                                .toList()
                                .map<DropdownMenuEntry<String>>((value) {
                              return DropdownMenuEntry<String>(
                                value: value,
                                label: value,
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Nationality is Mandatory!";
                              }
                              return null;
                            },
                            title: "Nationality",
                            onSelected: (value) {
                              setState(() {
                                nationalitySelection = value.toString();
                                if (nationalitySelection == "Indian") {
                                  showAadhaarField = true;
                                  showOverseasField = false;

                                  if (isAadhaarCtrlDisposed ||
                                      aadhaarCtrl == null) {
                                    aadhaarCtrl = TextEditingController();
                                    isAadhaarCtrlDisposed = false;
                                  }
                                } else if (nationalitySelection == "Overseas") {
                                  showOverseasField = true;
                                  showAadhaarField = false;
                                  isAadhaarCtrlDisposed = true;
                                } else {
                                  showAadhaarField = false;
                                  showOverseasField = false;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          if (showAadhaarField) ...[
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
                            ],
                            const SizedBox(height: 16),
                          ],
                          if (showOverseasField) ...[
                            TextFormWidget(
                              title: 'Passport Number',
                              controller: passportCtrl,
                              keyboardType: TextInputType.text,
                              maxLength: 15,
                              required: true,
                              prefixIcon: Icons.phone_iphone_outlined,
                              validator: (value) =>
                                  validatePassport(value.toString()),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (campusDetail.isNotEmpty) ...[
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
                                      return "${campusDocList[i]['documentName'].toString()} Mandatory!";
                                    }
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
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
                      if (showOverseasField ? true : isAadhaarVerified) {
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

  String? validatePassport(String? value) {
    final passportRegExp = RegExp(r'^[A-PR-WYa-pr-wy][1-9]\d\s?\d{4}[1-9]$');
    if (value == null || value.isEmpty) {
      return 'Please enter your passport number';
    } else if (!passportRegExp.hasMatch(value)) {
      return 'Enter a valid passport number';
    }
    return null;
  }

  submitForm() {
    List docList = campusDocList;
    List uploadArray = [];

    for (int d = 0; d < docList.length; d++) {
      uploadArray.add({
        "name": docList[d]['documentName'].toString(),
        "id": docList[d]['documentId'].toString(),
        "storageUrl": docList[d]['url'],
      });
    }

    var refer = secureStorage.get("referCode") ?? "";

    final request = {
      "name": nameCtrl.text.toString(),
      "gender": getGender(genderCtrl.text).toString(),
      "contact": contactCtrl.text.toString(),
      "altContact": altContactCtrl.text.toString(),
      "emailId": emailCtrl.text.toString(),
      "rollNo": rollNoCtrl.text.toString(),
      "referralCode": refer.toString(),
      "nationality": nationalitySelection.toString(),
      "aadharVerificationStatus": isAadhaarVerified ? "Y" : "N",
      "organization": campusDetail[0]['campusName'].toString(),
      "documents": uploadArray,
      "aadharNo": showAadhaarField && !showOverseasField
          ? aadhaarMask.getUnmaskedText().toString()
          : '',
      "passportNo": showOverseasField && !showAadhaarField
          ? passportCtrl.text.toString()
          : '',
      "aadharDetails": showAadhaarField
          ? isAadhaarRequired
              ? aadhaarDetails[0]
              : {}
          : {},
    };
    // log(jsonEncode(uploadArray));

    alertServices.showLoading();
    customerService.createCustomer(request).then((response) async {
      alertServices.hideLoading();
      alertServices.successToast(response['status']);
      secureStorage.save("isLogin", true);
      getAssignCoupon();
      clearImageCache();
      Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
    });
  }

  clearImageCache() async {
    try {
      // Get the cache directory
      final cacheDir = await getTemporaryDirectory();
      // Check if the directory exists
      if (cacheDir.existsSync()) {
        // Delete the files in the cache directory
        cacheDir.listSync().forEach((file) {
          if (file is File) {
            try {
              file.deleteSync();
              print('Deleted: ${file.path}');
            } catch (e) {
              print('Failed to delete ${file.path}: $e');
            }
          } else if (file is Directory) {
            try {
              file.deleteSync(recursive: true);
              print('Deleted directory: ${file.path}');
            } catch (e) {
              print('Failed to delete directory ${file.path}: $e');
            }
          }
        });
        debugPrint('Cache folder cleared successfully.');
      }
    } catch (e) {
      print('Error clearing cache folder: $e');
    }
  }

  getFileName(details) {
    String name = details['documentName'].toString();
    bool required = details['mandatory'] == 'Y';
    if (required) {
      return "$name *";
    }
    return name;
  }

  getAssignCoupon() {
    String mobile = secureStorage.get("mobile");
    couponServices.getCouponCode(mobile).then((response) async {});
  }

  void verifyEmail() {
    FocusScope.of(context).unfocus();
    String email = emailCtrl.text.toString();
    if (email.isEmpty) {
      alertServices.errorToast("Please enter a valid email address.");
      return;
    }

    /// CHECK ALREADY EXISTS
    alertServices.showLoading();
    customerService.getCustomer(email, true).then((response) async {
      alertServices.hideLoading();
      if (response == null) {
        /// SENDING A MAIL
        var request = {"emailId": email};
        alertServices.showLoading();
        customerService.verifyEmail(email).then((response) async {
          if (response['statusCode'].toString() == '404') {
            alertServices.hideLoading();
            customerService.sentEmail(request).then((response) {
              if (response['status'].toString() == '1') {
                alertServices.hideLoading();
                alertServices
                    .successToast('Please check your inbox and verify');
              } else {}
            });
          } else {
            alertServices.hideLoading();
            alertServices.errorToast('Enter Valid Email');
          }
          setState(() {
            isVerified = true;
            isVerifyDisabled = true;
          });
        }).catchError((error) {
          alertServices.hideLoading();
          alertServices.errorToast('Verification failed. Try again.');
        });
      } else {
        alertServices.hideLoading();
        alertServices.errorToast("Email ID already exists.");
      }
    });
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
