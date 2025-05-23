class EndPoints {
  /// LIVE APIS
  static String baseApi = 'https://iot.driev.bike/driev/api/app';
  static String baseApi1 = 'https://iot.driev.bike/driev/api';
  static String payment = 'https://iot.driev.bike/driev/app/payment';

  /// STAGING APIS
  // static String baseApi = 'https://community-test.driev.bike/driev/api/app';
  // static String baseApi1 = 'https://community-test.driev.bike/driev/api';
  // static String payment = 'https://community-test.driev.bike/driev/app/payment';

  static const sendOtp = 'generateOTP';
  static const otpLength = '6';
  static const verifyOtp = 'verifyOtp';
  static const sentEmail = 'customers/sendVerificationLink';
  static const verifyEmail = 'isEmailExist';
  static const generatedToken = 'auth/token';
  static const getAllCampus = 'campus/fetchAllCampus';
  static const getAllColleges = 'college/fetchAllCollege';
  static const voteCollege = 'college/voteForCollege';
  static const campusById = 'campus/fetchCampusById';
  static const uploadFile = 'uploadImage';
  static const aadhaarSendOtp = 'aadhar/generateOtp';
  static const aadhaarVerifyOtp = 'aadhar/validateOtp';
  static const createCustomer = 'createCommunityCustomer';
  static const deleteAccount = 'deleteAccount';
  static const getCustomer = 'customerDetails';
  static const getVehiclesByPlan = 'getVehiclesByPlan';
  static const vehiclesByStation = 'vehiclesByStation';
  static const getPlansByStation = 'getPlansByStation';
  static const uploadDocument = 'uploadDocument';
  static const getBikeDetails = 'getBikeDetails';
  static const walletBalance = 'wallet/openingBalance';
  static const createMyRide = 'createMyRide';
  static const blockBike = 'blockBike';
  static const releaseBlockedBike = 'releaseBlockedBike';
  static const extendBlocking = 'extendBlocking';
  static const rideDetails = 'rideDetails';
  static const getRideEndPin = 'getRideEndPin';
  static const rideEndConfirmation = 'rideEndConfirmation';
  static const rideFeedback = 'rideFeedBack';
  static const assignCouponCode = 'wallet/assignCouponCode';
  static const rideHistory = 'flespi/getRidesByCustomer';
  static const transactionByContact = 'fetchTransactionByContact';
  static const withdrawmoney = 'wallet/withdrawMoneyFromWallet';
  static const validateCode = 'validateCode';
  static const withdrawMoney = 'wallet/withdrawMoneyFromWallet';
  static const initiateTransaction = 'initiateTransaction';
  static const creditMoneyToWallet = 'wallet/creditMoneyToWallet';
  static const activeRides = 'activeRides';
  static const blockedRides = 'blockedBikeByContact';
}
