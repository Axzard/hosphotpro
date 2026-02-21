import '../../domain/models/report_model.dart';

class DailyReportApiModel {
  final String tanggal;
  final String totalPendapatan;
  final int totalTransaksi;

  DailyReportApiModel({
    required this.tanggal,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });

  factory DailyReportApiModel.fromJson(Map<String, dynamic> json) {
    return DailyReportApiModel(
      tanggal: json['tanggal'] ?? '',
      totalPendapatan: json['total_pendapatan']?.toString() ?? '0',
      totalTransaksi: json['total_transaksi'] ?? 0,
    );
  }

  DailyReportModel toDomain() {
    return DailyReportModel(
      tanggal: DateTime.tryParse(tanggal) ?? DateTime.now(),
      totalPendapatan: double.tryParse(totalPendapatan) ?? 0,
      totalTransaksi: totalTransaksi,
    );
  }
}

class MonthlyReportApiModel {
  final int bulan;
  final String totalPendapatan;
  final int totalTransaksi;

  MonthlyReportApiModel({
    required this.bulan,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });

  factory MonthlyReportApiModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportApiModel(
      bulan: json['bulan'] ?? 0,
      totalPendapatan: json['total_pendapatan']?.toString() ?? '0',
      totalTransaksi: json['total_transaksi'] ?? 0,
    );
  }

  MonthlyReportModel toDomain() {
    return MonthlyReportModel(
      bulan: bulan,
      totalPendapatan: double.tryParse(totalPendapatan) ?? 0,
      totalTransaksi: totalTransaksi,
    );
  }
}

class YearlyReportApiModel {
  final int tahun;
  final String totalPendapatan;
  final int totalTransaksi;

  YearlyReportApiModel({
    required this.tahun,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });

  factory YearlyReportApiModel.fromJson(Map<String, dynamic> json) {
    return YearlyReportApiModel(
      tahun: json['tahun'] ?? 0,
      totalPendapatan: json['total_pendapatan']?.toString() ?? '0',
      totalTransaksi: json['total_transaksi'] ?? 0,
    );
  }

  YearlyReportModel toDomain() {
    return YearlyReportModel(
      tahun: tahun,
      totalPendapatan: double.tryParse(totalPendapatan) ?? 0,
      totalTransaksi: totalTransaksi,
    );
  }
}

class ReportDashboardApiModel {
  final List<DailyReportApiModel> perHari;
  final List<MonthlyReportApiModel> perBulan;
  final List<YearlyReportApiModel> perTahun;

  ReportDashboardApiModel({
    required this.perHari,
    required this.perBulan,
    required this.perTahun,
  });

  factory ReportDashboardApiModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    return ReportDashboardApiModel(
      perHari: (data['perHari'] as List? ?? [])
          .map((i) => DailyReportApiModel.fromJson(i))
          .toList(),
      perBulan: (data['perBulan'] as List? ?? [])
          .map((i) => MonthlyReportApiModel.fromJson(i))
          .toList(),
      perTahun: (data['perTahun'] as List? ?? [])
          .map((i) => YearlyReportApiModel.fromJson(i))
          .toList(),
    );
  }

  ReportDashboardModel toDomain() {
    return ReportDashboardModel(
      perHari: perHari.map((i) => i.toDomain()).toList(),
      perBulan: perBulan.map((i) => i.toDomain()).toList(),
      perTahun: perTahun.map((i) => i.toDomain()).toList(),
    );
  }
}
