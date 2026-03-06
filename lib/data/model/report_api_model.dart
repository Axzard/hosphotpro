import '../../domain/models/report_model.dart';

class DailyReportApiModel {
  final String? tanggal;
  final String? periode;
  final String totalPendapatan;
  final int totalTransaksi;

  DailyReportApiModel({
    this.tanggal,
    this.periode,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });

  factory DailyReportApiModel.fromJson(Map<String, dynamic> json) {
    return DailyReportApiModel(
      tanggal: json['tanggal'],
      periode: json['periode'],
      totalPendapatan: json['total_pendapatan']?.toString() ?? '0',
      totalTransaksi: json['total_transaksi'] ?? 0,
    );
  }

  DailyReportModel toDomain() {
    return DailyReportModel(
      tanggal: DateTime.tryParse(tanggal ?? periode ?? '') ?? DateTime.now(),
      totalPendapatan: double.tryParse(totalPendapatan) ?? 0,
      totalTransaksi: totalTransaksi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (tanggal != null) 'tanggal': tanggal,
      if (periode != null) 'periode': periode,
      'total_pendapatan': totalPendapatan,
      'total_transaksi': totalTransaksi,
    };
  }
}

class MonthlyReportApiModel {
  final dynamic periode;
  final int? bulan;
  final String totalPendapatan;
  final int totalTransaksi;

  MonthlyReportApiModel({
    this.periode,
    this.bulan,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });

  factory MonthlyReportApiModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportApiModel(
      periode: json['periode'],
      bulan: json['bulan'],
      totalPendapatan: json['total_pendapatan']?.toString() ?? '0',
      totalTransaksi: json['total_transaksi'] ?? 0,
    );
  }

  MonthlyReportModel toDomain() {
    int m = 1;
    if (bulan != null) {
      m = bulan!;
    } else if (periode != null) {
      if (periode is int) {
        m = 1;
      } else if (periode is String && periode.contains('-')) {
        m = int.tryParse(periode.split('-').last) ?? 1;
      }
    }

    return MonthlyReportModel(
      bulan: m,
      totalPendapatan: double.tryParse(totalPendapatan) ?? 0,
      totalTransaksi: totalTransaksi,
    );
  }
}

class YearlyReportApiModel {
  final dynamic periode;
  final int? tahun;
  final String totalPendapatan;
  final int totalTransaksi;

  YearlyReportApiModel({
    this.periode,
    this.tahun,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });

  factory YearlyReportApiModel.fromJson(Map<String, dynamic> json) {
    return YearlyReportApiModel(
      periode: json['periode'],
      tahun: json['tahun'],
      totalPendapatan: json['total_pendapatan']?.toString() ?? '0',
      totalTransaksi: json['total_transaksi'] ?? 0,
    );
  }

  YearlyReportModel toDomain() {
    return YearlyReportModel(
      tahun:
          tahun ??
          (periode is int
              ? periode
              : (int.tryParse(periode?.toString() ?? '') ?? 2024)),
      totalPendapatan: double.tryParse(totalPendapatan) ?? 0,
      totalTransaksi: totalTransaksi,
    );
  }
}

class ReportSummaryApiModel {
  final String totalPendapatan;
  final int totalTransaksi;

  ReportSummaryApiModel({
    required this.totalPendapatan,
    required this.totalTransaksi,
  });

  factory ReportSummaryApiModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryApiModel(
      totalPendapatan: json['total_pendapatan']?.toString() ?? '0',
      totalTransaksi: json['total_transaksi'] ?? 0,
    );
  }
}

class ReportDashboardApiModel {
  final List<DailyReportApiModel> perHari;
  final List<MonthlyReportApiModel> perBulan;
  final List<YearlyReportApiModel> perTahun;
  final ReportSummaryApiModel? summary;

  ReportDashboardApiModel({
    required this.perHari,
    required this.perBulan,
    required this.perTahun,
    this.summary,
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
      summary: data['summary'] != null
          ? ReportSummaryApiModel.fromJson(data['summary'])
          : null,
    );
  }

  ReportDashboardModel toDomain() {
    return ReportDashboardModel(
      perHari: perHari.map((i) => i.toDomain()).toList(),
      perBulan: perBulan.map((i) => i.toDomain()).toList(),
      perTahun: perTahun.map((i) => i.toDomain()).toList(),
      totalIncome: double.tryParse(summary?.totalPendapatan ?? '0') ?? 0,
      totalTransactions: summary?.totalTransaksi ?? 0,
    );
  }
}
