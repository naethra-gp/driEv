import 'package:cached_network_image/cached_network_image.dart';
import 'package:driev/app_themes/custom_theme.dart';
import 'package:flutter/material.dart';
import '../../app_config/app_constants.dart';
import '../../app_services/index.dart';
import '../../app_storages/secure_storage.dart';
import '../../app_utils/app_loading/alert_services.dart';

class VoteForYourCampus extends StatefulWidget {
  const VoteForYourCampus({super.key});

  @override
  State<VoteForYourCampus> createState() => _VoteForYourCampusState();
}

class _VoteForYourCampusState extends State<VoteForYourCampus> {
  AlertServices alertServices = AlertServices();
  CampusServices campusServices = CampusServices();
  SecureStorage secureStorage = SecureStorage();

  List allColleges = [];
  List searchList = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllColleges();
    searchController.addListener(searchListener);
  }

  @override
  void dispose() {
    searchController.removeListener(searchListener);
    searchController.dispose();
    super.dispose();
  }

  void searchListener() {
    search(searchController.text);
  }

  void search(String value) {
    if (value.isEmpty) {
      setState(() {
        searchList = allColleges;
      });
    } else {
      setState(() {
        searchList = allColleges.where((element) {
          final title = element['collegeName'].toString().toLowerCase();
          final input = value.toLowerCase();
          return title.contains(input);
        }).toList();
      });
    }
  }

  getAllColleges() {
    alertServices.showLoading();
    campusServices.getAllColleges().then((response) async {
      alertServices.hideLoading();
      allColleges = response;
      searchList = response;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(Constants.backButton),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                Constants.voteyorcamp,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  Constants.headingturf,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff6F6F6F),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 45,
                child: SearchWidget(
                  controller: searchController,
                  hintText: "Search your campus",
                ),
              ),
              if (searchList.isEmpty) ...[
                const SizedBox(height: 150),
                const Text(
                  "No data found!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black45,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: false,
                  physics: const ScrollPhysics(),
                  itemCount: searchList.length,
                  itemBuilder: (context, index) {
                    final item = searchList[index];
                    return listView([item]);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget listView(List list) {
    return GestureDetector(
      onTap: () {
        submitRank(list);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Container(
          decoration: CustomTheme.decoration,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
            leading: CachedNetworkImage(
              width: 55,
              height: 55,
              imageUrl: list[0]['logoUrl'].toString(),
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
              list[0]['collegeName'].toString(),
              overflow: TextOverflow.clip,
              style: CustomTheme.listTittleStyle,
            ),
            trailing: IconButton(
              icon: Image.asset(
                Constants.frwdArrow,
                height: 16,
                width: 16,
              ),
              onPressed: () {
                submitRank(list);
              },
            ),
          ),
        ),
      ),
    );
  }

  submitRank(List list) {
    alertServices.showLoading();
    String mobile = secureStorage.get("mobile");
    Map<String, String> params = {
      "collegeId": list[0]['collegeId'].toString(),
      "name": list[0]['collegeName'].toString(),
      "email": "",
      "contact": mobile.toString(),
      "message": ""
    };
    campusServices.voteCollege(params, true).then(
      (r) async {
        alertServices.hideLoading();
        if(r['collegeId'] != null) {
          alertServices.successToast("Vote successfully.");
          Navigator.pushNamed(context, "vote_campus_success");
        } else {
          Navigator.pushNamed(context, "vote_campus_error", arguments: {"params" : r});
        }
      },
    );
  }
}

class SearchWidget extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final Iterable<Widget>? trailing;

  const SearchWidget(
      {super.key, this.hintText, this.controller, this.trailing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SearchBar(
        controller: controller,
        surfaceTintColor: MaterialStateProperty.all(Colors.white),
        shadowColor: MaterialStateProperty.all(Colors.white),
        elevation: MaterialStateProperty.all(5.0),
        backgroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50),
            ),
          ),
        ),
        side: MaterialStateProperty.all(
          const BorderSide(color: Color(0xffDEDEDE), width: 1),
        ),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        hintText: hintText,
        hintStyle: MaterialStateProperty.all(
          const TextStyle(color: Colors.black54),
        ),
        // leading: IconButton(
        //   onPressed: () {},
        //   icon: const Icon(Icons.search),
        // ),
        trailing: [
          controller?.text != ''
              ? IconButton(
                  onPressed: () {
                    controller?.text = '';
                    FocusScope.of(context).unfocus();
                  },
                  icon: const Icon(Icons.close),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
