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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 110, // Ensure the widget fits within the Grid
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
                        trackColor: Colors.grey[200],
                        progressBarColors: [Colors.green, Colors.green],
                      ),
                      infoProperties: InfoProperties(
                        topLabelText:"0",
                        topLabelStyle:const TextStyle(
                          fontSize: 240,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    innerWidget: (double value) {
                      String labelText =
                          "Complete \n $rewardHours hrs \n to get rewards";
                      String assetPath = Constants.scooter;
                      Color backgroundColor = Colors.white;
                      if (rewardHours.toDouble() >= value && value == 100.0) {
                        labelText = "Completed \n $rewardHours hrs";
                        assetPath = Constants.gift;
                        backgroundColor = Colors.white;
                      } else if (value <= 100 && value <= 0) {
                        assetPath = Constants.gift;
                        labelText = "Unlock \n $rewardHours hrs";
                        backgroundColor = Colors.grey[200]!;
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
                  ),
                ),
              ),
              SizedBox(
                width: 18, // Adjust the width as needed
                child: Divider(
                  color: Colors.grey[200],
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
    return rideDurationmilliSec/ 3600000;
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
getSliderValues() async{
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
      print("documents ${documents.length}");
      selfieUrl = customerDetails[0]['selfi'] ?? "";
      alertServices.hideLoading();
      getSliderValues();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  // Navigator.of(context).pop();
                },
              ),
      ),
      body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
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
                                        // borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 2,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
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
                                          // "Naethra Technologies PVT LTD",
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
                                      // const SizedBox(width: 20),
                                      SizedBox(
                                        height: 20,
                                        // width: 100,
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
                                  const SizedBox(height: 15),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                  children: [
                                                    const TextSpan(text: 'CO'),
                                                    WidgetSpan(
                                                      child:
                                                          Transform.translate(
                                                        offset: const Offset(
                                                            0.0, 4.0),
                                                        child: const Text(
                                                          '2',
                                                          style: TextStyle(
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                                    ),
                                                    const TextSpan(
                                                        text: ' Saved'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "0 kg",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 100),
                                      const Expanded(
                                        flex: 3,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "KM Traveled",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "0 km",
                                                style: TextStyle(
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
                        Divider(
                          endIndent: 10,
                          indent: 10,
                          color: Colors.grey[500],
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
                                customerDetails[0]['emailId'],
                                Icons.phone_iphone_outlined,
                                customerDetails[0]['contact'],
                              ),
                              // defaultHeight,
                              const SizedBox(height: 10),
                              bottomUserDetail(
                                Icons.person,
                                customerDetails[0]['rollNo'],
                                LineAwesome.id_card,
                                "ID Uploaded",
                              ),
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
                  ],
                ],
                const Text(
                  "DriEVantage Rewards",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Stack(alignment: Alignment.center, children: [
                _buildCategoriesGrid(),
                //  Divider(
                //   color: Colors.grey[200],
                // thickness: 3,
                // endIndent: 30,
                //indent: 30,
                // ),
                // ]),
                defaultHeight,
                Card(
                  elevation: 10,
                  color: Colors.grey[100],
                  surfaceTintColor: Colors.grey[100],
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
                          // paytm("10.00");
                        }),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList("assets/img/ride_history.png", "Ride History",
                            () {
                          Navigator.pushNamed(context, "ride_history");
                        }),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList("assets/img/faq.png", "FAQs", () {
                          launchFaq();
                        }),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList("assets/img/rate.png", "Rate us", () {
                          Navigator.pushNamed(context, "rate_this_raid",
                              arguments: "rideId");
                          launchRateUs();
                        }),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList("assets/img/gift.png", "Refer your friends",
                            () {
                          Navigator.pushNamed(context, "validate_code");
                        }),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList("assets/img/logout.png", "Logout", () {
                          secureStorage.save("isLogin", false);
                          Navigator.pushNamedAndRemoveUntil(
                              context, "login_page", (route) => false);
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
                            text: ' ${aa[0]['lastRideDistance']} kilometers!',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 0),
                    //   child: SfSliderTheme(
                    //     data: const SfSliderThemeData(
                    //       tooltipBackgroundColor: AppColors.primary,
                    //       thumbColor: Colors.transparent,
                    //       thumbRadius: 20,
                    //       activeDividerColor: Colors.white,
                    //     ),
                    //     child: SfSlider(
                    //       min: 10.0,
                    //       max: 500.0,
                    //       shouldAlwaysShowTooltip: false,
                    //       thumbIcon: Image.asset(
                    //         "assets/img/scooter_1.png",
                    //         height: 20,
                    //         width: 20,
                    //       ),
                    //       value: distance,
                    //       inactiveColor: AppColors.primary.withOpacity(0.3),
                    //       // labelPlacement: LabelPlacement.onTicks,
                    //       thumbShape: const SfThumbShape(),
                    //       semanticFormatterCallback: (dynamic value) {
                    //         return '$value km';
                    //       },
                    //       enableTooltip: true,
                    //       showLabels: false,
                    //       showDividers: true,
                    //       showTicks: false,
                    //       tooltipTextFormatterCallback:
                    //           (dynamic actualValue, String formattedText) {
                    //         return "$formattedText km";
                    //       },
                    //       onChanged: (dynamic newValue) {
                    //         setState(() {
                    //           // distance = newValue;
                    //         });
                    //       },
                    //     ),
                    //   ),
                    // ),
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

  Widget bottomUserDetail(
    fIcon,
    fText,
    sIcon,
    sText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Row(
              children: [
                Icon(fIcon, size: 15),
                const SizedBox(width: 5),
                Text(
                  fText,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
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
          trackColor: Colors.grey[200],
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
        String labelText =
            "Complete \n $rewardHours hrs \n to get rewards";
        String assetPath = Constants.scooter;
        Color backgroundColor = Colors.white;
        if (rewardHours.toDouble() >= value && value == 100.0) {
          labelText = "Completed \n $rewardHours hrs";
          assetPath = Constants.gift;
          backgroundColor = Colors.white;
        } else if (value <= 100 && value <= 0) {
          assetPath = Constants.gift;
          labelText = "Unlock \n $rewardHours hrs";
          backgroundColor = Colors.grey[200]!;
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

        // Check if additional items need to be added
        if (completedCount == 3 && i == 2) {
          // Add two more items after the 3rd slider is filled
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
                SizedBox(
                  width: 18,
                  child: Divider(
                    color: Colors.grey[200],
                    thickness: 3,
                    height: 10,
                  ),
                ),
              ],
            );
          } else {
            return SizedBox(); // Return an empty SizedBox for safety
          }
        },
      ),
    );
  }

  double milliSecToHrs() {
    return (310 * 3600000) / 3600000; // Adjusted calculation as per your requirement
  }


  @override
  Widget build(BuildContext context) {
    return _buildCategoriesGrid();
  }
}