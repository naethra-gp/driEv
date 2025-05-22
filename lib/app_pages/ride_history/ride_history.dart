import 'package:driev/app_services/feedback_services.dart';
import 'package:driev/app_storages/secure_storage.dart';
import 'package:driev/app_utils/app_loading/alert_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_themes/app_colors.dart';
import '../../app_utils/app_widgets/app_bar_widget.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  final AlertServices _alertServices = AlertServices();
  final SecureStorage _secureStorage = SecureStorage();
  final FeedbackServices _feedbackServices = FeedbackServices();
  List<Map<String, dynamic>> _rideHistoryDetails = [];

  @override
  void initState() {
    super.initState();
    _getRideHistory();
  }

  Future<void> _getRideHistory() async {
    _alertServices.showLoading();
    try {
      final mobile = _secureStorage.get("mobile") ?? "";
      final response = await _feedbackServices.getRideHistory(mobile);
      if (mounted) {
        setState(() {
          _rideHistoryDetails = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (error) {
      // Handle error silently
    } finally {
      _alertServices.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: const AppBarWidget(),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            _buildHeader(),
            if (_rideHistoryDetails.isEmpty)
              _buildEmptyState()
            else
              _buildRideList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text(
          "Ride History",
          style: TextStyle(
            fontSize: 20,
            color: AppColors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
         SizedBox(height: 10),
         Text(
          "Take a peek at your ride history \n with us.",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.referColor,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
         SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Expanded(
      child: Center(
        child: Text(
          "No data found!",
          style: TextStyle(
            fontSize: 14,
            height: 2,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }

  Widget _buildRideList() {
    return Flexible(
      child: ListView.builder(
        physics: const ScrollPhysics(),
        padding: const EdgeInsets.all(5),
        shrinkWrap: true,
        itemCount: _rideHistoryDetails.length,
        itemBuilder: (context, index) => RideHistoryItem(
          ride: _rideHistoryDetails[index],
          onTap: () => Navigator.pushNamed(
            context,
            "ride_details",
            arguments: [_rideHistoryDetails[index]],
          ),
        ),
      ),
    );
  }
}

class RideHistoryItem extends StatelessWidget {
  final Map<String, dynamic> ride;
  final VoidCallback onTap;

  const RideHistoryItem({
    super.key,
    required this.ride,
    required this.onTap,
  });

  String _formatDateTime(String dateTime) {
    try {
      return DateFormat('dd MMM yyyy')
          .format(DateTime.parse(dateTime).toLocal());
    } catch (e) {
      return "Unknown Date";
    }
  }

  String _formatTime(String dateTime) {
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(dateTime).toLocal());
    } catch (e) {
      return "Unknown Time";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xffD2D2D2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          leading: Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xffD2D2D2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Image.asset(
                "assets/img/ridebike.png",
                height: 30,
                width: 49,
              ),
            ),
          ),
          title: Text(
            _formatDateTime(ride["createdDate"] ?? ""),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            _formatTime(ride["startTime"] ?? ""),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(
            "₹${(ride["payableAmount"] as num).toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
