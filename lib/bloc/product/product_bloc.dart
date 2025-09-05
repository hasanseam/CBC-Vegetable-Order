import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cbc_vegitable_order/services/api_service.dart';
import 'package:cbc_vegitable_order/bloc/product/product_event.dart';
import 'package:cbc_vegitable_order/bloc/product/product_state.dart';
import 'package:cbc_vegitable_order/models/product.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await ApiService.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      print(e.toString());
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onAddProduct(AddProduct event, Emitter<ProductState> emit) async {
    try {
      final newProduct = await ApiService.createProduct(event.product);

      if (state is ProductLoaded) {
        final currentProducts = (state as ProductLoaded).products;
        final updatedProducts = [...currentProducts, newProduct];
        emit(ProductLoaded(updatedProducts));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<ProductState> emit) async {
    try {
      final updatedProduct = await ApiService.updateProduct(event.product);

      if (state is ProductLoaded) {
        final currentProducts = (state as ProductLoaded).products;
        final updatedProducts = currentProducts.map((product) {
          return product.id == updatedProduct.id ? updatedProduct : product;
        }).toList();
        emit(ProductLoaded(updatedProducts));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<ProductState> emit) async {
    try {
      await ApiService.deleteProduct(event.productId);

      if (state is ProductLoaded) {
        final currentProducts = (state as ProductLoaded).products;
        final updatedProducts = currentProducts.where((product) => product.id != event.productId).toList();
        emit(ProductLoaded(updatedProducts));
      }
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
