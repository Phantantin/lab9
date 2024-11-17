import 'package:location/location.dart';
import 'package:ccima/services/networking.dart';

const apiKey = 'e72ca729af228beabd5d20e3b7749713';
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';

class WeatherModel {
  Future<dynamic> _getWeatherData(String url) async {
    try {
      NetworkHelper networkHelper = NetworkHelper(url);
      var weatherData = await networkHelper.getData();
      return weatherData;
    } catch (e) {
      print('Lỗi khi lấy dữ liệu thời tiết: $e');
      return null; // Trả về null nếu có lỗi
    }
  }

  Future<dynamic> getCityWeather(String cityName) async {
    String url = '$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric';
    return await _getWeatherData(url); // Tái sử dụng phương thức
  }

  Future<dynamic> getLocationWeather() async {
    Location location = Location();

    // Kiểm tra quyền truy cập vị trí trước khi lấy vị trí
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null; // Nếu không có quyền truy cập, trả về null
      }
    }

    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return null; // Nếu không được cấp quyền, trả về null
      }
    }

    // Lấy vị trí người dùng
    LocationData locationData = await location.getLocation();

    String url =
        '$openWeatherMapURL?lat=${locationData.latitude}&lon=${locationData.longitude}&appid=$apiKey&units=metric';
    return await _getWeatherData(url); // Tái sử dụng phương thức
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩'; // Bão
    } else if (condition < 400) {
      return '🌧'; // Mưa nhỏ
    } else if (condition < 600) {
      return '☔️'; // Mưa
    } else if (condition < 700) {
      return '☃️'; // Tuyết
    } else if (condition < 800) {
      return '🌫'; // Mù
    } else if (condition == 800) {
      return '☀️'; // Trời quang đãng
    } else if (condition <= 804) {
      return '☁️'; // Mây
    } else {
      return '🤷‍'; // Không rõ
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'Thời gian ăn kem 🍦';
    } else if (temp > 20) {
      return 'Thời gian mặc quần đùi và áo thun 👕';
    } else if (temp < 10) {
      return 'Bạn sẽ cần khăn quàng và găng tay 🧣 🧤';
    } else {
      return 'Mang theo áo khoác 🧥 phòng khi trời lạnh';
    }
  }
}
