library in_app_plugin;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:io';

/// A Calculator.
class inAppState {
  bool available = true;
  InAppPurchaseConnection iap = InAppPurchaseConnection.instance;
  List<ProductDetails> products = [];
  List<PurchaseDetails> purchases = [];
  late StreamSubscription subscription;
  late Set<String> ids = {};

  void cancelSubscription() {
    subscription.cancel();
  }

  void initialize() async {
    available = await iap.isAvailable();
    if (available) {
      await getProducts();
      await getPurchases();
      verifyPurchase();
      subscription = iap.purchaseUpdatedStream.listen((data) {
        print("-----NEW PURCHASE----");
        purchases.addAll(data);
        verifyPurchase();
      });
    }
  }

  void addId(id) {
    ids.add(id);
  }

  void removeId(id) {
    ids.remove(id);
  }

  Future<void> getProducts() async {
    ProductDetailsResponse response = await iap.queryProductDetails(ids);
    if (response.error == null) {
      throw Exception("Response error");
    }
    products = response.productDetails;
  }

  Future<void> getPurchases() async {
    QueryPurchaseDetailsResponse response = await iap.queryPastPurchases();
    for (PurchaseDetails purchase in response.pastPurchases) {
      if (Platform.isIOS) {
        iap.completePurchase(purchase);
      }
    }
    purchases = response.pastPurchases;
  }

  PurchaseDetails? hasPurchased(String productID) {
    return purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null as PurchaseDetails);
  }

  void verifyPurchase() {
    // PurchaseDetails? purchase = hasPurchased(prodID);

    // // serverside verification
    // if (purchase != null && purchase.status == PurchaseStatus.purchased) {
    //   // your logic
    // }
  }

  void verifyConsumablePurchases() {}

  void verifyNonConsumablePurchases() {}

  void verifyAllPurchases(Function fn) {
    fn();
  }

  void buyConsumable(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
  }

  void buyNonConsumable(ProductDetails prod) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
    iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void consumePurchase(PurchaseDetails purchase) async {
    await iap.consumePurchase(purchase);
  }
}
