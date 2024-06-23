import 'package:firmer_city/features/auth/data/user_model.dart';
import 'package:firmer_city/features/auth/provider/login_provider.dart';
import 'package:firmer_city/features/dashboard/data/oder_model.dart';
import 'package:firmer_city/features/dashboard/services/order_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderStreamProvider =
    StreamProvider.autoDispose<List<OrderModel>>((ref) async* {
  var user = ref.watch(userProvider);
  if (user.id != null) {
    var data = OrderServices.getOrderById(user.id!);
    await for (var value in data) {
      ref.read(orderProvider.notifier).setOrders(value, user);
      yield value;
    }
  } else {
    yield [];
  }
});

class OrderFilter {
  final List<OrderModel> orders;
  final List<OrderModel> filteredOrders;
  OrderFilter({
    required this.orders,
    required this.filteredOrders,
  });

  OrderFilter copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? filteredOrders,
  }) {
    return OrderFilter(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
    );
  }
}

final orderProvider = StateNotifierProvider<OrderProvider, OrderFilter>((ref) {
  return OrderProvider();
});

class OrderProvider extends StateNotifier<OrderFilter> {
  OrderProvider() : super(OrderFilter(orders: [], filteredOrders: []));
  void setOrders(List<OrderModel> orders, UserModel user) {
    var myOrders =
        orders.where((element) => element.farmerId.contains(user.id)).toList();
    state = state.copyWith(orders: myOrders, filteredOrders: myOrders);
  }

  void filterOrders(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredOrders: state.orders);
    } else {
      var filtered = state.orders
          .where((element) =>
              element.buyerName.toLowerCase().contains(query.toLowerCase()) ||
              element.buyerPhone.toLowerCase().contains(query.toLowerCase()) ||
              element.buyerPhone.toLowerCase().contains(query.toLowerCase()))
          .toList();
      state = state.copyWith(filteredOrders: filtered);
    }
  }
}
