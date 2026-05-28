import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/shared/components/components.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final Map<String, dynamic> _summary = {
    'income': 3500.0,
    'expenses': 2100.0,
    'balance': 1400.0,
  };

  final List<Map<String, dynamic>> _expenses = [
    {
      'id': '1',
      'title': 'Alquiler',
      'amount': 800.0,
      'category': 'Vivienda',
      'date': '2026-04-01',
    },
    {
      'id': '2',
      'title': 'Supermercado',
      'amount': 350.0,
      'category': 'Alimentación',
      'date': '2026-04-05',
    },
    {
      'id': '3',
      'title': 'Transporte',
      'amount': 150.0,
      'category': 'Transporte',
      'date': '2026-04-03',
    },
    {
      'id': '4',
      'title': 'Servicios',
      'amount': 120.0,
      'category': 'Vivienda',
      'date': '2026-04-02',
    },
    {
      'id': '5',
      'title': 'Entretenimiento',
      'amount': 200.0,
      'category': 'Ocio',
      'date': '2026-04-07',
    },
  ];

  final List<Map<String, dynamic>> _budgets = [
    {'id': '1', 'category': 'Alimentación', 'limit': 400.0, 'spent': 350.0},
    {'id': '2', 'category': 'Transporte', 'limit': 200.0, 'spent': 150.0},
    {'id': '3', 'category': 'Ocio', 'limit': 300.0, 'spent': 200.0},
    {'id': '4', 'category': 'Vivienda', 'limit': 1000.0, 'spent': 920.0},
  ];

  // Simular carga de datos
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // Skeleton loader para gastos
  Widget _buildExpensesSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.darkSurfaceAlt,
      highlightColor: AppColors.darkBorder,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // Empty state para gastos
  Widget _buildExpensesEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin gastos registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lleva registro de tus gastos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Finanzas'),
        backgroundColor: AppColors.darkBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentPrimary,
          labelColor: AppColors.accentPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Gastos'),
            Tab(text: 'Presupuestos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSummaryTab(), _buildExpensesTab(), _buildBudgetsTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: AppColors.accentPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Balance del Mes',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${_summary['balance'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        'Ingresos',
                        _summary['income'],
                        AppColors.accentGreen,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: _buildSummaryItem(
                        'Gastos',
                        _summary['expenses'],
                        AppColors.accentRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category breakdown
          const Text(
            'Gastos por Categoría',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryChart(),
          const SizedBox(height: 24),

          // Recent transactions
          const Text(
            'Transacciones Recientes',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._expenses.take(3).map((e) => _buildTransactionItem(e)),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          _buildCategoryRow('Vivienda', 920.0, AppColors.accentPrimary),
          const SizedBox(height: 12),
          _buildCategoryRow('Alimentación', 350.0, AppColors.accentSecondary),
          const SizedBox(height: 12),
          _buildCategoryRow('Ocio', 200.0, AppColors.accentTertiary),
          const SizedBox(height: 12),
          _buildCategoryRow('Transporte', 150.0, AppColors.accentOrange),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, double amount, Color color) {
    final percentage = amount / _summary['expenses'];
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            category,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: AnimatedProgressBar(
            progress: percentage,
            gradient: LinearGradient(colors: [color, color.withOpacity(0.5)]),
            height: 6,
            showPercentage: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_downward,
              color: AppColors.accentRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense['title'],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  expense['category'],
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-\$${expense['amount'].toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.accentRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (_isLoading) {
      return _buildExpensesSkeleton();
    }

    if (_expenses.isEmpty) {
      return _buildExpensesEmpty();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppColors.accentPrimary,
      backgroundColor: AppColors.darkSurface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _expenses.length,
        itemBuilder: (context, index) {
          return _buildTransactionItem(_expenses[index]);
        },
      ),
    );
  }

  Widget _buildBudgetsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _budgets.length,
      itemBuilder: (context, index) {
        return _buildBudgetCard(_budgets[index]);
      },
    );
  }

  Widget _buildBudgetCard(Map<String, dynamic> budget) {
    final progress = (budget['spent'] as double) / (budget['limit'] as double);
    final isOverBudget = progress > 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                budget['category'],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? AppColors.accentRed.withOpacity(0.15)
                      : AppColors.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOverBudget ? 'Sobre presupuesto' : 'En presupuesto',
                  style: TextStyle(
                    color: isOverBudget
                        ? AppColors.accentRed
                        : AppColors.accentGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${budget['spent'].toStringAsFixed(0)}',
                style: TextStyle(
                  color: isOverBudget
                      ? AppColors.accentRed
                      : AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'de \$${budget['limit'].toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedProgressBar(
            progress: progress.clamp(0.0, 1.0),
            gradient: isOverBudget
                ? AppColors.gradientSuccess
                : AppColors.gradientPrimary,
          ),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'General';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nuevo Gasto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty &&
                          amountController.text.isNotEmpty) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Agregar Gasto'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
