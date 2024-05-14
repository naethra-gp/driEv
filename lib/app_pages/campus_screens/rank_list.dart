import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_utils/app_widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../app_config/app_constants.dart';
import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_themes/custom_theme.dart';
import '../../app_utils/app_loading/alert_services.dart';

class RankList extends StatefulWidget {
  const RankList({super.key});

  @override
  State<RankList> createState() => _RankListState();
}

class _RankListState extends State<RankList> {
  AlertServices alertServices = AlertServices();
  CampusServices campusServices = CampusServices();
  SecureStorage secureStorage = SecureStorage();
  List rankedColleges = [];

  @override
  void initState() {
    super.initState();
    getRankedColleges();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getRankedColleges() {
    alertServices.showLoading();
    campusServices.getAllColleges().then((response) async {
      alertServices.hideLoading();
      rankedColleges = response;
      rankedColleges.sort((a, b) {
        int idComparison = b['votingCount'].compareTo(a['votingCount']);
        if (idComparison != 0) {
          return idComparison;
        } else {
          return a['collegeName'].compareTo(b['collegeName']);
        }
      });

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  Constants.nailingit,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  Constants.checkoutcollege,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff6F6F6F),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (rankedColleges.isNotEmpty) ...[
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        rankedColleges.length < 15 ? rankedColleges.length : 15,
                    itemBuilder: (context, index) {
                      return listView(rankedColleges[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AppButtonWidget(
                    title: "Share with your squad",
                    onPressed: () async {
                      await Share.share('https://driev.bike');
                    },
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget listView(Map<String, dynamic> list) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Container(
          decoration: CustomTheme.decoration,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            leading: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    width: 30,
                    height: 30,
                    imageUrl: list['logoUrl'].toString(),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/app/no-img.png",
                      width: 30,
                      height: 30,
                    ),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  Text(
                    "${list['votingCount']} Votes",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      // color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              list['collegeName'].toString(),
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
