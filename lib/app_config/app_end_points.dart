class EndPoints {

  static const baseApi = 'https://community-test.driev.bike/driev/api/app';
  static const baseApi1 = 'https://community-test.driev.bike/driev/api';
  static const sendOtp = 'generateOTP';
  static const otpLength = '6';
  static const verifyOtp = 'verifyOtp';
  static const generatedToken = 'auth/token';
  static const getAllCampus = 'campus/fetchAllCampus';
  static const getAllColleges = 'college/fetchAllCollege';
  static const voteCollege = 'college/voteForCollege';
  static const campusById = 'campus/fetchCampusById';
  static const uploadFile = 'uploadImage';
  static const aadhaarSendOtp = 'aadhar/generateOtp';
  static const aadhaarVerifyOtp = 'aadhar/validateOtp';
  static const createCustomer = 'createCommunityCustomer';
  static const getCustomer = 'customerDetails';
  static const getVehiclesByPlan = 'getVehiclesByPlan';
  static const getPlansByStation = 'getPlansByStation';
  static const uploadDocument = 'uploadDocument';
  static const getBikeDetails = 'getBikeDetails';
  static const walletBalance = 'wallet/openingBalance';
  static const createMyRide = 'createMyRide';
  static const blockBike = 'blockBike';
  static const extendBlocking = 'extendBlocking';
  static const rideDetails = 'rideDetails';
  static const getRideEndPin = 'getRideEndPin';
  static const rideEndConfirmation = 'rideEndConfirmation';

}