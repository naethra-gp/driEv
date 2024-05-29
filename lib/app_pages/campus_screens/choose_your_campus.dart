import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../app_config/app_constants.dart';
import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/custom_theme.dart';
import '../../app_utils/app_loading/alert_services.dart';

class ChooseYourCampus extends StatefulWidget {
  const ChooseYourCampus({super.key});

  @override
  State<ChooseYourCampus> createState() => _ChooseYourCampusState();
}

class _ChooseYourCampusState extends State<ChooseYourCampus> {
  AlertServices alertServices = AlertServices();
  CampusServices campusServices = CampusServices();
  SecureStorage secureStorage = SecureStorage();

  List allCampus = [];

  @override
  void initState() {
    getAllCampus();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getAllCampus() {
    alertServices.showLoading();
    campusServices.getAllCampus().then((response) async {
      alertServices.hideLoading();
      allCampus = response;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        // leading: IconButton(
        //   icon: Image.asset(Constants.backButton),
        //   onPressed: () async {
        //     Navigator.of(context).pop();
        //   },
        // ),
      ),
      body:  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  Constants.campavail,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                Constants.campusopt,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (allCampus.isNotEmpty) ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allCampus.length,
                          itemBuilder: (context, index) {
                            return listView(allCampus[index]);
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          Constants.cantfind,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 16,
                            // wordSpacing: 5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "vote_your_campus");
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          child: Container(
                            decoration: CustomTheme.decoration,
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                              leading: Image.asset(
                                Constants.votecampus,
                                width: 55,
                                height: 55,
                                fit: BoxFit.contain,
                              ),
                              title: Text(
                                Constants.voteyorcamp,
                                overflow: TextOverflow.clip,
                                style: CustomTheme.listTittleStyle,
                              ),
                              trailing: IconButton(
                                icon: Image.asset(Constants.frwdArrow, height: 16, width: 16),
                                onPressed: () {
                                  
                                  Navigator.pushNamed(context, "vote_your_campus");
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
  Widget listView(Map<String, dynamic> list) {
    return GestureDetector(
      onTap: () {
        // Navigator.pushNamed(context, "rank_list");
        Navigator.pushNamed(context, "registration", arguments: list['campusId'].toString());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
        child: Container(
          decoration: CustomTheme.decoration,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 7,vertical: 7),
            leading: CachedNetworkImage(
              width: 52,
              height: 52,
              imageUrl: list['logoUrl'].toString(),
              errorWidget: (context, url, error) => Image.asset(
                "assets/app/no-img.png",
                height: 52,
                width: 52,
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
              list['campusName'].toString(),
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: 0.15
              ),
            ),
            trailing: IconButton(
              icon:Image.asset(Constants.frwdArrow,height: 16,width: 16,),
              onPressed: () {
                Navigator.pushNamed(context, "registration", arguments: list['campusId'].toString());
              },
            ),
          ),
        ),
      ),
    );
  }
}
