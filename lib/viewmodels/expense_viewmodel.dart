import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _expenseRepository = ExpenseRepository();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;

  String? _selectedCategoryFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  List<ExpenseModel> get filteredExpenses{
    if (_selectedCategoryFilter == null || _selectedCategoryFilter =='Tümü'){
      return _expenses;
    }
    return _expenses
        .where((expense) => expense.category == _selectedCategoryFilter)
        .toList();
  }

  void setCategoryFilter(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }


  List<ExpenseModel> get expenses => _expenses;
 

  bool get isLoading => _isLoading;

  double get totalExpense {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }
  double get filteredTotalExpense {
    return filteredExpenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    _expenses = await _expenseRepository.getAllExpenses();
    _isLoading = false;
    notifyListeners();

  }
  
  Future<void> addExpense(ExpenseModel expense) async {
    await _expenseRepository.insertExpense(expense);
    await fetchExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await _expenseRepository.deleteExpense(id);
    await fetchExpenses();
  } 
  Future<void> updateExpense(ExpenseModel expense) async{
    await _expenseRepository.updateExpense(expense);
    await fetchExpenses();
  }

  final Map<String, double> _categoryBudgets = {
    'Yemek': 3000,
    'Ulaşım': 1500,
    'Fatura': 2000,
    'Eğlence': 1000,
    'Alışveriş': 2500, 
    'Diğer': 1000,

  };

  Map<String, double> get categoryBudgets => _categoryBudgets;
  double getTotalExpenseByCategory(String category){
    return _expenses
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, item) => sum+item.amount);
  }
  double getBudgetProgress(String category){
    double limit = _categoryBudgets[category] ?? 1.0;
    double spent= getTotalExpenseByCategory(category);
    return (spent / limit).clamp(0.0, 1.0);
  }  
  
  Map<String, double> get categoryExpenses{
    Map<String, double> data ={};
    for (var expense in filteredExpenses){
      data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
    }
    return data;
  }

}