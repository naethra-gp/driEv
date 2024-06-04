import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_pages/profile_page/widgets/document_upload_alert.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

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
  List rewards = [100, 200, 300];
  String selfieUrl = "";

  Widget _buildCategoriesGrid() {
    return SizedBox(
      height: 120.0,
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10.0),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 20.0,
        ),
        itemCount: rewards.length,
        itemBuilder: (_, int index) {
          return GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              backgroundColor: Colors.grey[200],
              // maxRadius: 150,
              radius: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/img/giftbox.png",
                    height: 20,
                    // width: 20,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Unlock \n ${rewards[index]} hrs",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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

  getCustomer() async {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile") ?? "";
    customerService.getCustomer(mobile).then((response) {
      customerDetails = [response];
      documents = customerDetails[0]['documents'];
      print("documents ${documents.length}");
      selfieUrl = customerDetails[0]['selfi'] ?? "";
      alertServices.hideLoading();
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
                Stack(alignment: Alignment.center, children: [
                  _buildCategoriesGrid(),
                  Divider(
                    color: Colors.grey[200],
                    thickness: 3,
                    endIndent: 30,
                    indent: 30,
                  ),
                ]),
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
                        menuList("assets/img/wallet.png", "View Wallet", () {}),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList("assets/img/ride_history.png", "Ride History",
                            () {
                          // Navigator.pushNamed(context, "ride_summary");
                        }),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList("assets/img/faq.png", "FAQs", () {}),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList("assets/img/rate.png", "Rate us", () {}),
                        Divider(
                          endIndent: 15,
                          indent: 15,
                          color: Colors.grey[400],
                        ),
                        menuList(
                            "assets/img/gift.png", "Refer your friends", () {}),
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
}
