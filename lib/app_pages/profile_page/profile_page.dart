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
    {"hours": 100},
    {"hours": 200},
    {"hours": 300},
  ];
  List<double> progressValues = [];
  String selfieUrl = "";
  double distance = 50;
  String result = "";
  int rideDurationmilliSec = 0;

  final double smallDeviceHeight = 600;
  final double largeDeviceHeight = 1024;

  @override
  void initState() {
    getCustomer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double milliSecToHrs() {
    return rideDurationmilliSec / 3600000;
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

  deleteCustomer() async {
    alertServices.showLoading();
    Navigator.pop(context);
    String mobile = secureStorage.get("mobile") ?? "";
    customerService.deleteCustomer(mobile).then((response) {
      String msg = response['message'].toString().toLowerCase();
      String status = response['status'].toString();
      if (msg.isNotEmpty || msg != 'null') {
        alertServices.hideLoading();
        alertServices.deleteUserAlert(
            context, response['message'].toString(), status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
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
                ProfileHeader(
                  customerDetails: customerDetails,
                  selfieUrl: selfieUrl,
                  onEditProfile: () {
                    var selfie = {"id": "selfi"};
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DocumentUploadAlert(
                          document: selfie,
                          onDataReceived: (bool status) {
                            if (status) {
                              alertServices
                                  .successToast("File Uploaded Successfully.");
                              getCustomer();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
              defaultHeight,
              defaultHeight,
              defaultHeight,
              if (documents.isNotEmpty) ...[
                DocumentsList(
                  documents: documents,
                  onDocumentUploaded: (bool status) {
                    if (status) {
                      alertServices.successToast("File Uploaded Successfully.");
                      getCustomer();
                    }
                  },
                ),
              ],
              RewardsSection(
                progressValues: progressValues,
                rewards: rewards,
              ),
              defaultHeight,
              MenuSection(
                onDeleteAccount: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteAccountDialog(
                        onDelete: deleteCustomer,
                      );
                    },
                  );
                },
                onLogout: () async {
                  secureStorage.save("isLogin", false);
                  Navigator.pushNamedAndRemoveUntil(
                      context, "login_page", (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final List customerDetails;
  final String selfieUrl;
  final VoidCallback onEditProfile;

  const ProfileHeader({
    super.key,
    required this.customerDetails,
    required this.selfieUrl,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                flex: 2,
                child: SizedBox(
                  height: 70,
                  width: 70,
                  child: CachedNetworkImage(
                    height: 70,
                    width: 70,
                    fit: BoxFit.contain,
                    imageUrl: selfieUrl,
                    errorWidget: (context, url, error) => Image.asset(
                      Constants.defaultUser,
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: const Color(0xffF5F5F5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const SizedBox(height: 15),
                        SizedBox(
                          width: 120,
                          child: Text(
                            customerDetails[0]['name'].toString().toUpperCase(),
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
                            onPressed: onEditProfile,
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      TextSpan(text: ' Saved'),
                                    ],
                                  ),
                                ),
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
                        const Spacer(flex: 2),
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                UserDetailRow(
                  firstIcon: Icons.mail_outline,
                  firstText: customerDetails[0]['emailId'].toString(),
                  secondIcon: LineAwesome.id_card,
                  secondText: "ID Uploaded",
                  isEmailVerified: customerDetails[0]['emailVerificationStatus']
                          .toString() ==
                      "Y",
                ),
                const SizedBox(height: 10),
                UserDetailRow(
                  firstIcon: Icons.person,
                  firstText: customerDetails[0]['rollNo'].toString(),
                  secondIcon: LineAwesome.id_card,
                  secondText: "ID Uploaded",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetailRow extends StatelessWidget {
  final IconData firstIcon;
  final String firstText;
  final IconData secondIcon;
  final String secondText;
  final bool isEmailVerified;

  const UserDetailRow({
    super.key,
    required this.firstIcon,
    required this.firstText,
    required this.secondIcon,
    required this.secondText,
    this.isEmailVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(firstIcon, size: 15),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          firstText,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        if (isEmailVerified) ...[
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.verified,
                            size: 15,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                Icon(secondIcon, size: 15),
                const SizedBox(width: 5),
                Text(
                  secondText,
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
}

class DocumentsList extends StatelessWidget {
  final List documents;
  final Function(bool) onDocumentUploaded;

  const DocumentsList({
    super.key,
    required this.documents,
    required this.onDocumentUploaded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < documents.length; i++) ...[
          if (documents[i]['rejected'] == true ||
              documents[i]['uploaded'] == false)
            DocumentReUpload(
              document: documents[i],
              onDataReceived: onDocumentUploaded,
            ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class RewardsSection extends StatelessWidget {
  final List<double> progressValues;
  final List<Map<String, dynamic>> rewards;

  const RewardsSection({
    super.key,
    required this.progressValues,
    required this.rewards,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "driEVantage Rewards",
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
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
                              if (rewardHours.toDouble() >= value &&
                                  value == 100.0) {
                                labelText = "Completed \n $rewardHours hours";
                                assetPath = Constants.gift;
                              } else if (value <= 100 && value <= 0) {
                                assetPath = Constants.gift;
                                labelText = "Unlock \n $rewardHours hours";
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
        ),
      ],
    );
  }
}

class MenuSection extends StatelessWidget {
  final VoidCallback onDeleteAccount;
  final VoidCallback onLogout;

  const MenuSection({
    super.key,
    required this.onDeleteAccount,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xffF5F5F5),
      surfaceTintColor: const Color(0xffF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuItem(
              icon: "assets/img/wallet.png",
              title: "View Wallet",
              onTap: () => Navigator.pushNamed(context, "wallet_summary"),
            ),
            const MenuDivider(),
            MenuItem(
              icon: "assets/img/ride_history.png",
              title: "Ride History",
              onTap: () => Navigator.pushNamed(context, "ride_history"),
            ),
            const MenuDivider(),
            MenuItem(
              icon: "assets/img/faq.png",
              title: "FAQs",
              onTap: () => _launchFaq(),
            ),
            const MenuDivider(),
            MenuItem(
              icon: "assets/img/rate.png",
              title: "Rate us",
              onTap: () => _launchRateUs(),
            ),
            const MenuDivider(),
            MenuItem(
              icon: "assets/img/gift.png",
              title: "Refer your friends",
              onTap: () => Navigator.pushNamed(context, "refer_screen"),
            ),
            const MenuDivider(),
            DeleteAccountItem(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteAccountDialog(
                      onDelete: onDeleteAccount,
                    );
                  },
                );
              },
            ),
            const MenuDivider(),
            MenuItem(
              icon: "assets/img/logout.png",
              title: "Logout",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LogoutDialog(onLogout: onLogout);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _launchFaq() async {
    final Uri url = Uri.parse('https://driev.bike/faqs');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      AlertServices().errorToast("Could not launch $url");
    }
  }

  void _launchRateUs() async {
    final Uri url = Uri.parse('https://maps.app.goo.gl/gtotFPdQL7iLcrBS7');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      AlertServices().errorToast("Could not launch $url");
    }
  }
}

class MenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon, width: 25, height: 25, fit: BoxFit.contain),
            const SizedBox(width: 15),
            Text(
              title,
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
}

class DeleteAccountItem extends StatelessWidget {
  final VoidCallback onTap;

  const DeleteAccountItem({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_outlined,
                color: Colors.red, size: 24),
            SizedBox(width: 15),
            Text(
              "Delete your account",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuDivider extends StatelessWidget {
  const MenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      endIndent: 15,
      indent: 15,
      color: Color(0xffD9D9D9),
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteAccountDialog({
    super.key,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirm"),
        content: const Text(
          "Do you want delete your account?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            child: const Text(
              "No",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: onDelete,
            child: const Text(
              "Yes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutDialog({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirm"),
        content: const Text("Do you want logout now?"),
        actions: [
          TextButton(
            child: const Text(
              "No",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: onLogout,
            child: const Text(
              "Yes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
