class ReportDashboardModel {
  final List<DailyReportModel> perHari;
  final List<MonthlyReportModel> perBulan;
  final List<YearlyReportModel> perTahun;
  final double totalIncome;
  final int totalTransactions;

  ReportDashboardModel({
    required this.perHari,
    required this.perBulan,
    required this.perTahun,
    this.totalIncome = 0,
    this.totalTransactions = 0,
  });
}

class DailyReportModel {
  final DateTime tanggal;
  final double totalPendapatan;
  final int totalTransaksi;

  DailyReportModel({
    required this.tanggal,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });
}

class MonthlyReportModel {
  final int bulan;
  final double totalPendapatan;
  final int totalTransaksi;

  MonthlyReportModel({
    required this.bulan,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });
}

class YearlyReportModel {
  final int tahun;
  final double totalPendapatan;
  final int totalTransaksi;

  YearlyReportModel({
    required this.tahun,
    required this.totalPendapatan,
    required this.totalTransaksi,
  });
}
