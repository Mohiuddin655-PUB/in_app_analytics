abstract final class Events {
  static const logAddPaymentInfo = "logAddPaymentInfo";
  static const logAddShippingInfo = "logAddShippingInfo";
  static const logAddToCart = "logAddToCart";
  static const logAddToWishlist = "logAddToWishlist";
  static const logAppOpen = "logAppOpen";
  static const logBeginCheckout = "logBeginCheckout";
  static const logCampaignDetails = "logCampaignDetails";
  static const logEarnVirtualCurrency = "logEarnVirtualCurrency";
  static const logGenerateLead = "logGenerateLead";
  static const logJoinGroup = "logJoinGroup";
  static const logLogin = "logLogin";
  static const logLevelEnd = "logLevelEnd";
  static const logLevelStart = "logLevelStart";
  static const logLevelUp = "logLevelUp";
  static const logPostScore = "logPostScore";
  static const logPurchase = "logPurchase";
  static const logRefund = "logRefund";
  static const logRemoveFromCart = "logRemoveFromCart";
  static const logScreenView = "logScreenView";
  static const logSearch = "logSearch";
  static const logSelectContent = "logSelectContent";
  static const logSelectItem = "logSelectItem";
  static const logSelectPromotion = "logSelectPromotion";
  static const logShare = "logShare";
  static const logSignUp = "logSignUp";
  static const logSpendVirtualCurrency = "logSpendVirtualCurrency";
  static const logTutorialBegin = "logTutorialBegin";
  static const logTutorialComplete = "logTutorialComplete";
  static const logUnlockAchievement = "logUnlockAchievement";
  static const logViewCart = "logViewCart";
  static const logViewItem = "logViewItem";
  static const logViewItemList = "logViewItemList";
  static const logViewPromotion = "logViewPromotion";
  static const logViewSearchResults = "logViewSearchResults";
}

abstract final class EventFields {
  static const parameters = "parameters";
  static const value = "value";
  static const currency = "currency";
  static const coupon = "coupon";
  static const items = "items";
  static const itemId = "itemId";
  static const itemName = "itemName";
  static const itemListId = "itemListId";
  static const itemListName = "itemListName";
  static const promotionId = "promotionId";
  static const promotionName = "promotionName";
  static const shippingTier = "shippingTier";
  static const paymentType = "paymentType";
  static const source = "source";
  static const medium = "medium";
  static const campaign = "campaign";
  static const tax = "tax";
  static const shipping = "shipping";
  static const transactionId = "transactionId";
  static const affiliation = "affiliation";
  static const searchTerm = "searchTerm";
  static const contentType = "contentType";
  static const method = "method";
  static const signUpMethod = "signUpMethod";
  static const loginMethod = "loginMethod";
  static const id = "id";
  static const level = "level";
  static const levelName = "levelName";
  static const success = "success";
  static const character = "character";
  static const score = "score";
  static const groupId = "groupId";
  static const itemList = "itemList";
  static const virtualCurrencyName = "virtualCurrencyName";
  static const screenName = "screenName";
  static const screenClass = "screenClass";
  static const itemCategory = "itemCategory";
}

class EventItem {
  const EventItem({
    this.affiliation,
    this.currency,
    this.coupon,
    this.creativeName,
    this.creativeSlot,
    this.discount,
    this.index,
    this.itemBrand,
    this.itemCategory,
    this.itemCategory2,
    this.itemCategory3,
    this.itemCategory4,
    this.itemCategory5,
    this.itemId,
    this.itemListId,
    this.itemListName,
    this.itemName,
    this.itemVariant,
    this.locationId,
    this.price,
    this.promotionId,
    this.promotionName,
    this.quantity,
    this.parameters,
  });

  /// A product affiliation to designate a supplying company or brick and
  /// mortar store location.
  /// e.g. Google Store
  final String? affiliation;

  /// The currency, in 3-letter ISO 4217 format.
  /// If set, event-level currency is ignored.
  /// Multiple currencies per event is not supported. Each item should set the
  /// same currency.
  /// e.g. USD
  final String? currency;

  /// The coupon name/code associated with the item.
  /// e.g. SUMMER_FUN
  final String? coupon;

  /// The name of the promotional creative.
  final String? creativeName;

  /// The name of the promotional creative slot associated with the item.
  final String? creativeSlot;

  /// The monetary discount value associated with the item.
  /// e.g. 2.22
  final num? discount;

  /// The index/position of the item in a list.
  /// e.g. 5
  final int? index;

  /// The brand of the item.
  /// e.g. Google
  final String? itemBrand;

  /// The category of the item. If used as part of a category hierarchy or
  /// taxonomy then this will be the first category.
  /// e.g. Apparel
  final String? itemCategory;

  /// The second category hierarchy or additional taxonomy for the item.
  /// e.g. Adult
  final String? itemCategory2;

  /// The third category hierarchy or additional taxonomy for the item.
  /// e.g. Shirts
  final String? itemCategory3;

  /// The fourth category hierarchy or additional taxonomy for the item.
  /// e.g. Crew
  final String? itemCategory4;

  /// The fifth category hierarchy or additional taxonomy for the item.
  /// e.g. Short sleeve
  final String? itemCategory5;

  /// The ID of the item.
  /// One of [itemId] or [itemName] is required.
  /// e.g. SKU_12345
  final String? itemId;

  /// The ID of the list in which the item was presented to the user.
  /// e.g. related_products
  final String? itemListId;

  /// The name of the list in which the item was presented to the user.
  /// e.g. Related products
  final String? itemListName;

  /// The name of the item.
  /// One of [itemId] or [itemName] is required.
  /// e.g. Stan and Friends Tee
  final String? itemName;

  /// The item variant or unique code or description for additional item details/options.
  /// e.g. green
  final String? itemVariant;

  /// The location associated with the item. It's recommended to use the Google
  /// Place ID that corresponds to the associated item. A custom location ID can
  /// also be used.
  /// e.g. L_12345
  final String? locationId;

  /// The monetary price of the item, in units of the specified currency parameter.
  /// e.g. 9.99
  final num? price;

  /// The ID of the promotion associated with the item.
  /// e.g. P_12345
  final String? promotionId;

  /// The name of the promotion associated with the item.
  /// e.g. Summer Sale
  final String? promotionName;

  /// Item quantity.
  /// e.g. 1
  final int? quantity;

  /// Extra parameters to pass along default ones
  ///
  /// Only strings and numbers are correctly handled by Google Analytics
  final Map<String, Object>? parameters;

  /// Returns the current instance as a [Map].
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      if (parameters != null) ...parameters!,
      if (affiliation != null) 'affiliation': affiliation,
      if (currency != null) 'currency': currency,
      if (coupon != null) 'coupon': coupon,
      if (creativeName != null) 'creative_name': creativeName,
      if (creativeSlot != null) 'creative_slot': creativeSlot,
      if (discount != null) 'discount': discount,
      if (index != null) 'index': index,
      if (itemBrand != null) 'item_brand': itemBrand,
      if (itemCategory != null) 'item_category': itemCategory,
      if (itemCategory2 != null) 'item_category2': itemCategory2,
      if (itemCategory3 != null) 'item_category3': itemCategory3,
      if (itemCategory4 != null) 'item_category4': itemCategory4,
      if (itemCategory5 != null) 'item_category5': itemCategory5,
      if (itemId != null) 'item_id': itemId,
      if (itemListId != null) 'item_list_id': itemListId,
      if (itemListName != null) 'item_list_name': itemListName,
      if (itemName != null) 'item_name': itemName,
      if (itemVariant != null) 'item_variant': itemVariant,
      if (locationId != null) 'location_id': locationId,
      if (price != null) 'price': price,
      if (promotionId != null) 'promotion_id': promotionId,
      if (promotionName != null) 'promotion_name': promotionName,
      if (quantity != null) 'quantity': quantity,
    };
  }

  @override
  String toString() {
    return '$EventItem(${asMap()})';
  }
}
