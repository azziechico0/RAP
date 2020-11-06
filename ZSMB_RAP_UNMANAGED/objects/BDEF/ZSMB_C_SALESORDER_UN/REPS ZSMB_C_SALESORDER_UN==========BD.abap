projection;

define behavior for ZSMB_C_SALESORDER_UN alias SalesOrderC
use etag
{
  use create;
  use update;
  use delete;

  use association _SalesOrderItem;
}

define behavior for ZSMB_C_SALESORDERITEM_UN alias SalesOrderItemC
use etag
{
  use update;
  use delete;
}