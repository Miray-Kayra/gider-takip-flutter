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






}