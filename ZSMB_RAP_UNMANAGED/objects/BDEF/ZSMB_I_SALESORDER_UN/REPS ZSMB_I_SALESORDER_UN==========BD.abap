implementation unmanaged;

define behavior for ZSMB_I_SALESORDER_UN alias SalesOrderI implementation in class zsmb_bp_i_salesorder_un unique
//late numbering
//lock master
//authorization master
//etag Changed_At
{
  create;
  update;
  delete;
  field ( mandatory ) BuyerGuid;
  field ( readonly ) Created_At, Changed_At;
  association _SalesOrderItem;

  mapping for snwd_so
  {
    Node_Key = node_key;
    SalesOrderID = so_id;
    Created_At = created_at;
    Changed_At = changed_at;
    CurrencyCode = currency_code;
    GrossAmount = gross_amount;
    NetAmount = net_amount;
    TaxAmount = tax_amount;
    OverallStatus = overall_status;
    BuyerGuid = buyer_guid;
  }
}

define behavior for ZSMB_I_SALESORDERITEM_UN alias SalesOrderItem implementation in class zsmb_bp_i_salesorderitem_un unique
//late numbering
//lock
//authorization master
//etag
{
  update;
  delete;
  field ( mandatory ) SalesOrderItemID, Product;

  mapping for snwd_so_i
  {
    Node_Key = node_key;
    Parent_Key = parent_key;
    SalesOrderItemID = so_item_pos;
    Product = product_guid;
    CurrencyCode = currency_code;
    GrossAmount = gross_amount;
    NetAmount = net_amount;
    TaxAmount = tax_amount;
  }
}