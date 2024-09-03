import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_config/app_constants.dart';
import 'package:driev/app_pages/profile_page/widgets/document_upload_alert.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_loading/alert_services.dart';
import 'widgets/document_re_upload.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static SizedBox defaultHeight = const SizedBox(height: 16);
  AlertServices alertServices = AlertServices();
  CustomerService customerService = CustomerService();
  SecureStorage secureStorage = SecureStorage();
  List customerDetails = [];
  List documents = [];
  bool userBlock = false;
  bool userVerified = false;
  List<Map<String, dynamic>> rewards = [
    {
      "hours": 100,
    },
    {
      "hours": 200,
    },
    {
      "hours": 300,
    },
  ];
  List<double> progressValues = [];
  String selfieUrl = "";
  double distance = 50;
  String result = "";
  int rideDurationmilliSec = 0;

  final double smallDeviceHeight = 600;
  final double largeDeviceHeight = 1024;

  Widget _buildCategoriesGrid() {
    return SizedBox(
      height: 150.0,
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10.0),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemCount: progressValues.length,
        itemBuilder: (_, int index) {
          int rewardHours = (index + 1) * 100;
          double initialValue = progressValues[index];
          return Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 99,
                    child: GestureDetector(
                      onTap: () {},
                      child: SleekCircularSlider(
                        min: 0,
                        max: 100,
                        initialValue: initialValue,
                        appearance: CircularSliderAppearance(
                          startAngle: 180,
                          angleRange: 360,
                          customWidths: CustomSliderWidths(
                            trackWidth: 4,
                            progressBarWidth: 6,
                          ),
                          size: 120,
                          customColors: CustomSliderColors(
                            trackColor: const Color(0xffF5F5F5),
                            progressBarColors: [Colors.green, Colors.green],
                          ),
                        ),
                        innerWidget: (double value) {
                          String labelText =
                              "Complete \n $rewardHours hours \n to get rewards";
                          String assetPath = Constants.scooter;
                          Color backgroundColor = Colors.white;
                          if (rewardHours.toDouble() >= value &&
                              value == 100.0) {
                            labelText = "Completed \n $rewardHours hours";
                            assetPath = Constants.gift;
                            backgroundColor = Colors.white;
                          } else if (value <= 100 && value <= 0) {
                            assetPath = Constants.gift;
                            labelText = "Unlock \n $rewardHours hours";
                            backgroundColor = const Color(0xffF5F5F5);
                          }
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  assetPath,
                                  height: 26,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  labelText,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Positioned(
                  //   top:
                  //       50, // Adjust this value to move the text along the slider
                  //   child: Text(
                  //     "${initialValue.toInt()}",
                  //     style: const TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.bold,
                  //       color: Colors.green,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              if (index != progressValues.length - 1)
                const SizedBox(
                  width: 30,
                  child: Divider(
                    color: Color(0xffF5F5F5),
                    thickness: 3,
                    height: 10,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double milliSecToHrs() {
    return rideDurationmilliSec / 3600000;
  }

  @override
  void initState() {
    getCustomer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getSliderValues() async {
    double totalHours = milliSecToHrs();
    int additionalItems = (totalHours / 100).ceil();
    int totalItems = rewards.length + additionalItems - 1;
    progressValues = List.generate(totalItems, (index) {
      if (totalHours > 0) {
        if (totalHours >= 100) {
          totalHours -= 100;
          return 100.0;
        } else {
          double value = totalHours;
          totalHours = 0;
          return value;
        }
      } else {
        return 0.0;
      }
    });
  }

  getCustomer() async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    customerService.getCustomer(mobile).then((response) {
      customerDetails = [response];
      documents = customerDetails[0]['documents'];
      rideDurationmilliSec = customerDetails[0]['rideDuration'];
      selfieUrl = customerDetails[0]['selfi'] ?? "";
      alertServices.hideLoading();
      getSliderValues();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double fontSize;

    if (height < smallDeviceHeight) {
      fontSize = 11.5;
      print('small');
    } else if (height >= smallDeviceHeight && height < largeDeviceHeight) {
      fontSize = 12;
      print('medium');
    } else {
      fontSize = 12.5;
      print('large');
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: userBlock
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.home_outlined,
                  size: 30,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "home");
                },
              ),
      ),
      body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              children: [
                defaultHeight,
                if (customerDetails.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: const Color(0xffD6D6D6),
                      ),
                      color: const Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 2, // 30% width
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: CachedNetworkImage(
                                  width: 50,
                                  height: 50,
                                  imageUrl: selfieUrl,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    "assets/img/profile_logo.png",
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          color: const Color(0xffF5F5F5),
                                          width: 2,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 8, // 70% width
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const SizedBox(height: 15),
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          customerDetails[0]['name']
                                              .toString()
                                              .toUpperCase(),
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        height: 20,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            var selfie = {"id": "selfi"};
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return DocumentUploadAlert(
                                                  document: selfie,
                                                  onDataReceived:
                                                      (bool status) {
                                                    if (status) {
                                                      alertServices.successToast(
                                                          "File Uploaded Successfully.");
                                                      getCustomer();
                                                    }
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: const Text(
                                            "Edit Profile",
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          children: [
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text.rich(
                                                TextSpan(
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                  ),
                                                  children: [
                                                    TextSpan(text: 'CO'),
                                                    TextSpan(
                                                      text: '₂',
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    TextSpan(text: ' Saved'),
                                                  ],
                                                ),
                                              ),

                                              //  RichText(
                                              //   text: TextSpan(
                                              //     style: const TextStyle(
                                              //       color: Colors.black,
                                              //       fontSize: 12,
                                              //     ),
                                              //     children: [
                                              //       const TextSpan(
                                              //         text: 'CO',
                                              //         style: TextStyle(
                                              //           color: Colors.black,
                                              //           fontSize: 12,
                                              //         ),
                                              //       ),
                                              //       WidgetSpan(
                                              //         child:
                                              //             Transform.translate(
                                              //           offset: const Offset(
                                              //               0.0, 4.0),
                                              //           child: const Text(
                                              //             '2',
                                              //             style: TextStyle(
                                              //                 fontSize: 10),
                                              //           ),
                                              //         ),
                                              //       ),
                                              //       const TextSpan(
                                              //           text: ' Saved'),
                                              //     ],
                                              //   ),
                                              // ),
                                            ),
                                            const SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${customerDetails[0]['co2Saved'].toString()} kg",
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // const SizedBox(width: 100),
                                      const Spacer(
                                        flex: 2,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "KM Traveled",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${double.parse(customerDetails[0]['rideDistance'].toString()).toStringAsFixed(2)} km",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          endIndent: 10,
                          indent: 10,
                          color: Color(0xff929292),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 5,
                          ),
                          child: Column(
                            children: [
                              bottomUserDetail(
                                  Icons.mail_outline,
                                  customerDetails[0]['emailId'].toString(),
                                  Icons.phone_iphone_outlined,
                                  customerDetails[0]['contact'].toString(),
                                  fontSize),
                              // defaultHeight,
                              const SizedBox(height: 10),
                              bottomUserDetail(
                                  Icons.person,
                                  customerDetails[0]['rollNo'].toString(),
                                  LineAwesome.id_card,
                                  "ID Uploaded",
                                  fontSize),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                defaultHeight,
                defaultHeight,
                defaultHeight,
                if (documents.isNotEmpty) ...[
                  for (int i = 0; i < documents.length; i++) ...[

                    if (documents[i]['rejected'] == true) ...[
                      DocumentReUpload(
                        document: documents[i],
                        onDataReceived: (bool status) {
                          if (status) {
                            alertServices
                                .successToast("File Uploaded Successfully.");
                            getCustomer();
                          }
                        },
                      ),
                      defaultHeight,
                    ],
                    if (documents[i]['uploaded'] == false) ...[
                      DocumentReUpload(
                        document: documents[i],
                        onDataReceived: (bool status) {
                          if (status) {
                            alertServices
                                .successToast("File Uploaded Successfully.");
                            getCustomer();
                          }
                        },
                      ),
                      defaultHeight,
                    ],
                  ],
                ],
                const Text(
                  "driEVantage Rewards",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildCategoriesGrid(),
                defaultHeight,
                Card(
                  color: const Color(0xffF5F5F5),
                  surfaceTintColor: const Color(0xffF5F5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // if you need this
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        menuList("assets/img/wallet.png", "View Wallet", () {
                          Navigator.pushNamed(context, "wallet_summary");
                        }),
                        const Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Color(0xffD9D9D9),
                        ),
                        menuList("assets/img/ride_history.png", "Ride History",
                            () {
                          Navigator.pushNamed(
                            context,
                            "ride_history",
                          );
                        }),
                        const Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Color(0xffD9D9D9),
                        ),
                        menuList("assets/img/faq.png", "FAQs", () {
                          launchFaq();
                        }),
                        const Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Color(0xffD9D9D9),
                        ),
                        menuList("assets/img/rate.png", "Rate us", () {
                          launchRateUs();
                        }),
                        const Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Color(0xffD9D9D9),
                        ),
                        menuList("assets/img/gift.png", "Refer your friends",
                            () {
                          Navigator.pushNamed(context, "refer_screen");
                        }),
                        const Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Color(0xffD9D9D9),
                        ),
                        menuList("assets/img/logout.png", "Logout", () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  title: const Text("Confirm"),
                                  content:
                                      const Text("Do you want logout now?"),
                                  actions: [
                                    TextButton(
                                      child: const Text(
                                        "No",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        "Yes",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () async {
                                        secureStorage.save("isLogin", false);
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            "login_page",
                                            (route) => false);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 30),
              ],
            ),
          )),
    );
  }

  slider() {
    List aa = [
      {
        "rideId": "ITER-938",
        "lastRideDuration": "0 : 5 : 4",
        "totalRideDuration": "13 : 44 : 6",
        "lastRideDistance": 0.0,
        "totalRideDistance": 0.53,
        "contact": "7845456609"
      }
    ];
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return SizedBox(
          height: height / 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: height / 5.5 - 100,
                child: Container(
                  height: height,
                  width: width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: height / 6.6 - 100,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 50,
                        left: 50,
                        top: 50,
                        bottom: 20,
                      ),
                      child: Image.asset(
                        "assets/img/ride_end.png",
                        height: 60,
                        width: 60,
                      ),
                    ),
                    const Text(
                      "Ride done!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xff2c2c2c),
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        text: 'Great job on your ',
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          const TextSpan(
                              text: 'last trip covering',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text:
                                ' ${aa[0]['lastRideDistance'].toString()} kilometers!',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('0',
                              style: TextStyle(
                                  color: Color(0xff7B7B7B),
                                  fontWeight: FontWeight.bold)),
                          Text('500 km',
                              style: TextStyle(
                                  color: Color(0xff7B7B7B),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            // width: width / 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    "ride_summary",
                                    arguments: "rideId",
                                    (route) => false);
                              },
                              child: const Text("View Ride Summary"),
                            ),
                          ),
                          const SizedBox(width: 25),
                          SizedBox(
                            // width: width / 2,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text("Rate This Ride"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget bottomUserDetail(fIcon, fText, sIcon, sText, fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(fIcon, size: 15),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      fText,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // const Spacer(),
        Column(
          children: [
            Row(
              children: [
                Icon(sIcon, size: 15),
                const SizedBox(width: 5),
                Text(
                  sText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.verified,
                  size: 15,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  menuList(path, menu, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(path, width: 25, height: 25, fit: BoxFit.contain),
            const SizedBox(width: 15),
            Text(
              menu,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void launchFaq() async {
    final Uri url = Uri.parse('https://driev.bike/faqs');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      alertServices.errorToast("Could not launch $url");
    }
  }

  void launchRateUs() async {
    final Uri url = Uri.parse('https://maps.app.goo.gl/gtotFPdQL7iLcrBS7');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      alertServices.errorToast("Could not launch $url");
    }
  }
}

class RewardSlider extends StatelessWidget {
  final int rewardHours;
  final double initialValue;

  RewardSlider({required this.rewardHours, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return SleekCircularSlider(
      min: 0,
      max: 100,
      initialValue: initialValue,
      appearance: CircularSliderAppearance(
        startAngle: 180,
        angleRange: 360,
        customWidths: CustomSliderWidths(
          trackWidth: 4,
          progressBarWidth: 6,
        ),
        size: 120,
        customColors: CustomSliderColors(
          trackColor: const Color(0xffF5F5F5),
          progressBarColors: [Colors.green, Colors.green],
        ),
        infoProperties: InfoProperties(
          mainLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      innerWidget: (double value) {
        String labelText = "Complete \n $rewardHours hrs \n to get rewards";
        String assetPath = Constants.scooter;
        Color backgroundColor = Colors.white;
        if (rewardHours.toDouble() >= value && value == 100.0) {
          labelText = "Completed \n $rewardHours hrs";
          assetPath = Constants.gift;
          backgroundColor = Colors.white;
        } else if (value <= 100 && value <= 0) {
          assetPath = Constants.gift;
          labelText = "Unlock \n $rewardHours hrs";
          backgroundColor = const Color(0xffF5F5F5);
        }
        return Center(
          child: CircleAvatar(
            backgroundColor: backgroundColor,
            radius: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  assetPath,
                  height: 26,
                ),
                const SizedBox(height: 10),
                Text(
                  labelText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyApp1 extends StatefulWidget {
  @override
  _MyApp1State createState() => _MyApp1State();
}

class _MyApp1State extends State<MyApp1> {
  List<Map<String, dynamic>> rewards = [
    {"hours": 100},
    {"hours": 200},
    {"hours": 300},
  ];

  List<double> sliderValues = [];
  double lastCalculatedHours = 0.0;
  int itemCountCounter = 3; // Initial item count

  @override
  void initState() {
    super.initState();
    _updateSliderValues();
  }

  @override
  void didUpdateWidget(covariant MyApp1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (lastCalculatedHours != milliSecToHrs()) {
      _updateSliderValues();
    }
  }

  void _updateSliderValues() {
    lastCalculatedHours = milliSecToHrs();
    double totalHours = lastCalculatedHours;

    sliderValues.clear();
    int completedCount = 0;

    for (int i = 0; i < rewards.length; i++) {
      int rewardHours = rewards[i]["hours"];

      if (totalHours >= rewardHours) {
        sliderValues.add(rewardHours.toDouble());
        totalHours -= rewardHours.toDouble();
        completedCount++;

        if (completedCount == 3 && i == 2) {
          itemCountCounter += 2;
        }
      } else {
        sliderValues.add(totalHours);
        totalHours = 0;
      }
    }

    setState(() {}); // Trigger rebuild after updating slider values
  }

  Widget _buildCategoriesGrid() {
    return SizedBox(
      height: 150.0,
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10.0),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
        ),
        itemCount: itemCountCounter, // Use the itemCountCounter
        itemBuilder: (_, int index) {
          if (index < rewards.length) {
            int rewardHours = rewards[index]["hours"];
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 110,
                  child: GestureDetector(
                    onTap: () {},
                    child: RewardSlider(
                      rewardHours: rewardHours,
                      initialValue: sliderValues[index],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 18,
                  child: Divider(
                    color: Color(0xffF5F5F5),
                    thickness: 3,
                    height: 10,
                  ),
                ),
              ],
            );
          } else {
            return const SizedBox(); // Return an empty SizedBox for safety
          }
        },
      ),
    );
  }

  double milliSecToHrs() {
    return (310 * 3600000) /
        3600000; // Adjusted calculation as per your requirement
  }

  @override
  Widget build(BuildContext context) {
    return _buildCategoriesGrid();
  }
}
