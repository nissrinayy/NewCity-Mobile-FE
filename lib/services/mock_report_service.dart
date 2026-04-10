import 'package:dio/dio.dart';
import 'package:newcity/models/report.dart';

class MockReportService {
  static Future<Response> postReport(var data) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return Response(
      data: {'message': 'Report submitted successfully'},
      statusCode: 201,
      requestOptions: RequestOptions(path: '/api/report'),
    );
  }

  static Future<ReportResponsePagination> getReport(int page) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return ReportResponsePagination(
      report: _getMockReports(),
      lastPage: 1,
    );
  }

  static Future<ReportResponsePagination> getSearchedReport(
    int page,
    String search,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final allReports = _getMockReports();
    final filtered = allReports
        .where((r) =>
            r.judul.toLowerCase().contains(search.toLowerCase()) ||
            r.deskripsi.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return ReportResponsePagination(
      report: filtered,
      lastPage: 1,
    );
  }

  static Future<ReportResponsePagination> getBookmarkedReport(int page) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Return all reports for mock (simulating bookmarks)
    return ReportResponsePagination(
      report: _getMockReports(),
      lastPage: 1,
    );
  }

  static Future<ReportResponsePagination> getReportByStatus(
      int page, String status) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final allReports = _getMockReports();
    final filtered = allReports
        .where((r) => r.status.any((s) => s.status == status))
        .toList();

    return ReportResponsePagination(
      report: filtered,
      lastPage: 1,
    );
  }

  static Future<ReportResponse> getReportDetail(int id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final reports = _getMockReports();
    final report = reports.firstWhere((r) => r.id == id, orElse: () => reports.first);
    
    return ReportResponse(
      report: report,
      masyarakatName: 'Citizen',
      pemerintahName: 'Government',
      kategoriName: 'Infrastructure',
      like: 0,
      comment: 0,
      hasLiked: false,
      hasBookmark: false,
    );
  }

  static Future<List<Comment>> getComments(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock comments
    return [
      Comment(
        content: 'Serius nih jalan disini sangat berbahaya',
        tanggal: DateTime.now().subtract(const Duration(days: 2)).toString(),
        name: 'Budi',
        foto: 'https://via.placeholder.com/50',
      ),
      Comment(
        content: 'Setuju, sudah laporkan ke dinas tapi belum ada respons',
        tanggal: DateTime.now().subtract(const Duration(days: 1)).toString(),
        name: 'Siti',
        foto: 'https://via.placeholder.com/50',
      ),
    ];
  }

  static Future<Response> postComment(int id, String content) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      data: {
        'content': content,
        'tanggal': DateTime.now().toString(),
        'user': {
          'name': 'Current User',
          'foto': 'https://via.placeholder.com/50',
        }
      },
      statusCode: 201,
      requestOptions: RequestOptions(path: '/api/report/id/comment'),
    );
  }

  static Future<Response> toggleLikeReport(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      data: [],
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/report/id/like'),
    );
  }

  static Future<Response> toggleBookmark(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      data: {'bookmarked': true},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/report/id/bookmark'),
    );
  }

  static Future<Response> addStatus(int id, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      data: {'message': 'Status updated successfully'},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/report/id/status'),
    );
  }

  static Future<ReportResponsePagination> getReportByKategori(
      int page, int categoryId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return ReportResponsePagination(
      report: _getMockReports(),
      lastPage: 1,
    );
  }

  static Future<ReportResponsePagination> getLikedReports(int page) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return ReportResponsePagination(
      report: _getMockReports(),
      lastPage: 1,
    );
  }

  static Future<ReportResponsePagination> getMyReports(int page) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return ReportResponsePagination(
      report: _getMockReports(),
      lastPage: 1,
    );
  }

  static List<Report> _getMockReports() {
    final now = DateTime.now();
    return [
      Report(
        id: 1,
        judul: 'Jalan Rusak di Jalan Merdeka',
        deskripsi: 'Jalan sudah rusak selama 3 bulan, perlu perbaikan segera',
        lokasi: 'Jalan Merdeka, Kelurahan A',
        status: [
          Status(
            status: 'Dalam Proses',
            deskripsi: 'Sedang ditindaklanjuti oleh dinas terkait',
            tanggal: now.subtract(const Duration(days: 10)),
          ),
        ],
        foto: 'assets/images/logo_NewCity.png',
        idMasyarakat: 1,
        idPemerintah: 1,
        idKategori: 1,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Report(
        id: 2,
        judul: 'Lampu Jalan Mati di Komplek Perumahan',
        deskripsi:
            'Beberapa lampu jalan mati di area perumahan, membuat keamanan tidak terjamin',
        lokasi: 'Komplek Perumahan B, Jalan Sultan',
        status: [
          Status(
            status: 'Tindak Lanjut',
            deskripsi: 'Menunggu permintaan anggaran untuk perbaikan',
            tanggal: now.subtract(const Duration(days: 15)),
          ),
        ],
        foto: 'assets/images/logo_NewCity.png',
        idMasyarakat: 2,
        idPemerintah: 2,
        idKategori: 2,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      Report(
        id: 3,
        judul: 'Selokan Mampet Menyebabkan Genangan Air',
        deskripsi: 'Selokan tersumbat sampah, menyebabkan air menggenang di jalan',
        lokasi: 'Jalan Gatot Subroto, Kelurahan C',
        status: [
          Status(
            status: 'Selesai',
            deskripsi: 'Telah dibersihkan oleh tim kebersihan',
            tanggal: now.subtract(const Duration(days: 20)),
          ),
        ],
        foto: 'assets/images/logo_NewCity.png',
        idMasyarakat: 3,
        idPemerintah: 3,
        idKategori: 3,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  static Future<Response> likeReport(int reportId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      data: {'message': 'Like added successfully'},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/report/reportId/like'),
    );
  }

  static Future<Response> unlikeReport(int reportId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      data: {'message': 'Like removed successfully'},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/report/reportId/unlike'),
    );
  }

  static Future<Response> bookmarkReport(int reportId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      data: {'message': 'Bookmark added successfully'},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/report/reportId/bookmark'),
    );
  }

  static Future<Response> unbookmarkReport(int reportId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      data: {'message': 'Bookmark removed successfully'},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/report/reportId/unbookmark'),
    );
  }

  static Future<Response> addComment(int reportId, String comment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return Response(
      data: {
        'id': 999,
        'userName': 'Current User',
        'comment': comment,
        'date': DateTime.now().toString(),
        'likes': 0,
      },
      statusCode: 201,
      requestOptions: RequestOptions(path: '/api/report/reportId/comment'),
    );
  }

  static Future<Response> updateReportStatus(
    int reportId,
    String newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return Response(
      data: {'message': 'Status updated successfully'},
      statusCode: 200,
      requestOptions: RequestOptions(path: '/api/report/reportId/status'),
    );
  }
}
