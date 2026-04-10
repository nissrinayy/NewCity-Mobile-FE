import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dio_client.dart';
import 'package:newcity/models/report.dart';
import 'mock_report_service.dart';

const bool USE_MOCK = true;

class ReportService {
  static final Dio dio = DioClient.instance;

  static Future<dynamic> postReport(var data) async {
    if (USE_MOCK) return MockReportService.postReport(data);
    
    final response = await dio.post(
      'api/report',
      data: data,
      options: Options(
        headers: {
          "Content-Type": "multipart/form-data",
        },
      ),
    );
    return response;
  }

  static Future<ReportResponsePagination?> getReport(int page) async {
    if (USE_MOCK) return MockReportService.getReport(page);
    try {
      final response =
          await dio.get('api/report', queryParameters: {'page': page});
      return response.statusCode == 200
          ? ReportResponsePagination.fromJson(response.data)
          : null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<ReportResponsePagination?> getSearchedReport(
      int page, String keyword) async {
    if (USE_MOCK) return MockReportService.getSearchedReport(page, keyword);
    try {
      final response = await dio.get(
        'api/report/search',
        queryParameters: {
          'page': page,
          'search': keyword,
        },
      );
      if (response.statusCode == 200) {
        return ReportResponsePagination.fromJson(response.data);
      } else {
        throw Exception('Failed to load berita');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<ReportResponsePagination?> getBookmarkedReport(int page) async {
    if (USE_MOCK) return MockReportService.getBookmarkedReport(page);
    try {
      final response =
          await dio.get('api/report/bookmark', queryParameters: {'page': page});
      return response.statusCode == 200
          ? ReportResponsePagination.fromJson(response.data)
          : null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<ReportResponsePagination?> getReportByStatus(
      int page, status) async {
    if (USE_MOCK) return MockReportService.getReportByStatus(page, status);
    try {
      final response = await dio
          .get('api/report/status/$status', queryParameters: {'page': page});
      if (response.statusCode == 200) {
        return ReportResponsePagination.fromJson(response.data);
      } else {
        throw Exception('Failed to load berita');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<ReportResponse?> getReportDetail(int id) async {
    if (USE_MOCK) return MockReportService.getReportDetail(id);
    try {
      final response = await dio.get('api/report/$id');
      return response.statusCode == 200
          ? ReportResponse.fromJson(response.data)
          : null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<dynamic> addStatus(int id, String status) async {
    if (USE_MOCK) return MockReportService.addStatus(id, status);
    try {
      final response = await dio.post(
        'api/report/status/$id',
        data: {"status": status},
      );
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Status berhasil ditambahkan',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        throw Exception('Failed to add status');
      }
    } catch (e) {
      print('Error menambah status $e');
    }
  }

  static Future<dynamic> toggleLikeReport(int id) async {
    if (USE_MOCK) return MockReportService.toggleLikeReport(id);
    try {
      final response =
          await dio.post('api/report/like', data: {'id': id, "loaded": false});
      if (response.statusCode == 200) {
        return Comment.fromJsonList(response.data);
      } else {
        throw Exception('Failed to like');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<dynamic> toggleBookmark(int id) async {
    if (USE_MOCK) return MockReportService.toggleBookmark(id);
    try {
      final response = await dio
          .post('api/report/bookmark', data: {'id': id, "loaded": false});
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to bookmark');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<List<Comment>?> getComments(int id) async {
    if (USE_MOCK) return MockReportService.getComments(id);
    try {
      final response = await dio.get(
        'api/report/diskusi/$id',
      );
      if (response.statusCode == 200) {
        return Comment.fromJsonList(response.data);
      } else {
        throw Exception('Failed to load comment');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<dynamic> postComment(int id, String content) async {
    if (USE_MOCK) return MockReportService.postComment(id, content);
    try {
      final response =
          await dio.post('api/report/diskusi/$id', data: {'content': content});
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to load comment');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<KategoriReportResponse?> getKategoriReport() async {
    try {
      final response = await dio.get('api/kategori/report');
      if (response.statusCode == 200) {
        return KategoriReportResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load kategori');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<ReportResponsePagination?> getReportByKategori(
      int page, id) async {
    if (USE_MOCK) return MockReportService.getReportByKategori(page, id);
    try {
      final response = await dio
          .get('api/report/category/$id', queryParameters: {'page': page});
      if (response.statusCode == 200) {
        return ReportResponsePagination.fromJson(response.data);
      } else {
        throw Exception('Failed to load report');
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  static Future<ReportResponsePagination?> getLikedReports(int page) async {
    if (USE_MOCK) return MockReportService.getLikedReports(page);
    try {
      final response = await dio.get(
        'api/report/liked',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        return ReportResponsePagination.fromJson(response.data);
      } else {
        throw Exception('Failed to load liked reports');
      }
    } catch (e) {
      print("Error fetching liked reports: $e");
      return null;
    }
  }

  static Future<ReportResponsePagination?> getMyReports(int page) async {
    if (USE_MOCK) return MockReportService.getMyReports(page);
    try {
      final response = await dio.get(
        'api/report/my',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        return ReportResponsePagination.fromJson(response.data);
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print("Error fetching reports: $e");
      return null;
    }
  }
}
