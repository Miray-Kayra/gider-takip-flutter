import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';


class ExpenseListView extends StatelessWidget {
  ExpenseListView({super.key});

  final List <String>_categories = ['Yemek', 'Ulaşım', 'Fatura', 'Eğlence', 'Alışveriş', 'Diğer'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harcama Takip'),
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, viewModel, child) {
          // 1. Durum: Yükleniyor
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Durum: Liste Boş
          

          // 3. Durum: Liste Dolu (Toplam Harcama Kartı + Harcama Listesi)
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: (){
                        viewModel.changeMonth(
                          DateTime(viewModel.selectedMonth.year, viewModel.selectedMonth.month - 1),
                        );
                      },
                    ),
                    Text(
                      "${viewModel.selectedMonth.year} - ${viewModel.selectedMonth.month.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: (){
                        viewModel.changeMonth(
                          DateTime(viewModel.selectedMonth.year, viewModel.selectedMonth.month+1),
                        );
                      },
                    ),
                  ],
                ),
              ),














              // --- YENİ EKLENEN: TOPLAM HARCAMA KARTI ---
              Card(
                margin: const EdgeInsets.all(12),
                color: Theme.of(context).primaryColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Harcama:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${viewModel.filteredTotalExpense.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildPieChart(viewModel),
              const SizedBox(height: 12),
                  // 1. ÖNCE FİLTRE BUTONLARI (KATEGORİLER)
              SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['Tümü', ..._categories].map((category) {
                  final isSelected = (viewModel.selectedCategoryFilter == category) ||
                      (viewModel.selectedCategoryFilter == null && category == 'Tümü');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        viewModel.setCategoryFilter(category == 'Tümü' ? null : category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

                // 2. SONRA BÜTÇE İLERLEME ÇUBUĞU (Kategori seçildiğinde görünür)
                if (viewModel.selectedCategoryFilter != null) ...[
                  Builder(
                    builder: (context) {
                      final category = viewModel.selectedCategoryFilter!;
                      final limit = viewModel.categoryBudgets[category] ?? 0;
                      final spent = viewModel.getTotalExpenseByCategory(category);
                      final progress = viewModel.getBudgetProgress(category);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$category Bütçesi',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${spent.toStringAsFixed(0)} TL / ${limit.toStringAsFixed(0)} TL',
                                  style: TextStyle(
                                    color: progress >= 1.0 ? Colors.red : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              color: progress >= 1.0
                                  ? Colors.red
                                  : progress > 0.8
                                      ? Colors.orange
                                      : Colors.green,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            if(spent > limit && limit> 0) ...[
                              const SizedBox(height: 6),
                              Text(
                                ' Bütçe limiti ${(spent - limit).toStringAsFixed(0)} TL aşıldı!',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],


              // --- HARCAMA LİSTESİ ---
              Expanded(
                child:
                viewModel.filteredExpenses.isEmpty
                    ? const Center(
                      child: Text(
                        'Seçilen kategoriye ait harcama bulunamadı.',
                        style: TextStyle(fontSize: 16,color: Colors.grey),
                      ),
                    )

                : ListView.builder(
                  itemCount: viewModel.filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = viewModel.filteredExpenses[index];
                    return Dismissible(
                      key: Key(expense.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        if (expense.id != null) {
                          viewModel.deleteExpense(expense.id!);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              expense.category.isNotEmpty
                                  ? expense.category[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(expense.title),
                          subtitle: Text(
                            DateFormat('dd.MM.yyyy').format(expense.date),
                          ),
                          trailing: Text(
                            '${expense.amount.toStringAsFixed(2)} ₺',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () {
                            _showEditExpenseDialog(context, expense);
                          }
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext mainContext) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = _categories.first;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: mainContext,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Yeni Harcama Ekle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),

                  // 1. Başlık Girişi
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Harcama Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Tutar Girişi
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Tutar (₺)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Kategori Seçimi (Dropdown)
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // 4. Tarih Seçimi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tarih: ${DateFormat('dd.MM.yyyy').format(selectedDate)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Tarih Seç'),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: sheetContext,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 5. Kaydet Butonu
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final title = titleController.text.trim();
                      final amountText = amountController.text.trim();
                      final amount = double.tryParse(amountText);

                      if (title.isEmpty || amount == null || amount <= 0) {
                        ScaffoldMessenger.of(mainContext).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen geçerli bir başlık ve tutar girin!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final newExpense = ExpenseModel(
                        title: title,
                        amount: amount,
                        category: selectedCategory,
                        date: selectedDate,
                      );

                      Provider.of<ExpenseViewModel>(
                        mainContext,
                        listen: false,
                      ).addExpense(newExpense);

                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Kaydet', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  void _showEditExpenseDialog(BuildContext context, ExpenseModel expense) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(text: expense.amount.toString());
    String selectedCategory = expense.category;
    DateTime selectedDate = expense.date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          top:20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Harcamayı Düzenle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Harcama Adı'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tutar (₺)'),
            ), 
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                final title = titleController.text.trim();
                final amount = double.tryParse(amountController.text);

                if(title.isNotEmpty && amount != null && amount > 0) {
                  final updatedExpense = ExpenseModel(
                    id: expense.id,
                    title: title,
                    amount: amount,
                    date: selectedDate,
                    category: selectedCategory,
                  );

                  Provider.of<ExpenseViewModel>(context, listen: false)
                      .updateExpense(updatedExpense);

                    Navigator.of(sheetContext).pop();  
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
      ),
    ),
  );
  }  
  Widget _buildPieChart(ExpenseViewModel viewModel){
    final categoryData = viewModel.categoryExpenses;

     final Map<String, Color> categoryColors ={
      'Yemek': Colors.orange,
      'Ulaşım': Colors.blue,
      'Fatura': Colors.red,
      'Eğlence': Colors.purple,
      'Alışveriş': Colors.pink,
      'Diğer': Colors.grey,     
     };

     final List<PieChartSectionData> sections = categoryData.entries.map((entry){
      final color = categoryColors[entry.key] ?? Colors.teal;
      final total = categoryData.values.fold(0.0, (sum, item) => sum +item);
      final percentage = total > 0 ? (entry.value / total) * 100 : 0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.key}\n%${percentage.toStringAsFixed(0)}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );

     }).toList();
    return SizedBox(
      height: 140,
      child: PieChart( 
          PieChartData(
            sections: sections,
            centerSpaceRadius: 25,
            sectionsSpace: 2,
        ),
      ),
    );
   }
}
