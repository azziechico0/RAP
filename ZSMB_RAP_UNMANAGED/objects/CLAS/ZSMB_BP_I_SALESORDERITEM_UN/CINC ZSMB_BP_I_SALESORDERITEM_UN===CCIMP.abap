CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.
    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE snwd_so_i AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.
    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY node_key.
    CLASS-DATA mt_buffer_master TYPE tt_master.
ENDCLASS.

CLASS lhc_zsmb_i_salesorderitem_un DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS:
      update     FOR MODIFY
        IMPORTING it_salesorderitem_update FOR UPDATE salesorderitem,
      delete     FOR MODIFY
        IMPORTING it_salesorderitem_delete FOR DELETE salesorderitem,
      read       FOR READ
        IMPORTING it_salesorderitem_read FOR READ salesorderitem
        RESULT    et_salesorderitem.

ENDCLASS.

CLASS lhc_zsmb_i_salesorderitem_un IMPLEMENTATION.

  METHOD delete.

    LOOP AT it_salesorderitem_delete INTO DATA(ls_salesorderitem_delete).
      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = VALUE #( node_key = ls_salesorderitem_delete-node_key ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_salesorderitem_delete-node_key IS INITIAL.
        INSERT VALUE #( %cid = ls_salesorderitem_delete-%key-node_key
                        node_key = ls_salesorderitem_delete-%key-node_key )  INTO TABLE mapped-salesorderitem.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.

    LOOP AT it_salesorderitem_update INTO DATA(ls_salesorderitem_update).
      SELECT SINGLE * FROM snwd_so_i
             WHERE node_key EQ @ls_salesorderitem_update-%data-node_key
             INTO @DATA(ls_ddbb).
      IF ls_ddbb IS NOT INITIAL.
        INSERT VALUE #( flag = lcl_buffer=>updated
                             data = VALUE #( node_key = ls_ddbb-node_key
                                             parent_key = ls_ddbb-parent_key
                                             so_item_pos  = COND #( WHEN ls_salesorderitem_update-%control-salesorderitemid EQ if_abap_behv=>mk-on
                                                                      THEN ls_salesorderitem_update-%data-salesorderitemid
                                                                      ELSE ls_ddbb-so_item_pos )
                                             product_guid   = COND #( WHEN ls_salesorderitem_update-%control-product EQ if_abap_behv=>mk-on
                                                                      THEN ls_salesorderitem_update-%data-product
                                                                      ELSE ls_ddbb-product_guid )
                                             currency_code     = COND #( WHEN ls_salesorderitem_update-%control-currencycode EQ if_abap_behv=>mk-on
                                                                      THEN ls_salesorderitem_update-%data-currencycode
                                                                      ELSE ls_ddbb-currency_code )
                                             gross_amount = COND #( WHEN ls_salesorderitem_update-%control-grossamount EQ if_abap_behv=>mk-on
                                                                      THEN ls_salesorderitem_update-%data-grossamount
                                                                      ELSE ls_ddbb-gross_amount )
                                             net_amount = COND #( WHEN ls_salesorderitem_update-%control-netamount EQ if_abap_behv=>mk-on
                                                                      THEN ls_salesorderitem_update-%data-netamount
                                                                      ELSE ls_ddbb-net_amount )
                                             tax_amount     = COND #( WHEN ls_salesorderitem_update-%control-taxamount EQ if_abap_behv=>mk-on
                                                                      THEN ls_salesorderitem_update-%data-taxamount
                                                                      ELSE ls_ddbb-tax_amount )
                                             item_atp_status = ls_ddbb-item_atp_status
                                             op_item_pos = ls_ddbb-op_item_pos
                                             _dataaging = ls_ddbb-_dataaging
                                             dummy  = ls_ddbb-dummy
                              ) ) INTO TABLE lcl_buffer=>mt_buffer_master.
        IF NOT ls_salesorderitem_update-node_key IS INITIAL.
          INSERT VALUE #( %cid     = ls_salesorderitem_update-%data-node_key
                          node_key = ls_salesorderitem_update-%data-node_key ) INTO TABLE mapped-salesorderitem.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD read.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zsmb_i_salesorderitem_un DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_zsmb_i_salesorderitem_un IMPLEMENTATION.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
    DATA: lt_data_created_item TYPE STANDARD TABLE OF snwd_so_i,
          lt_data_updated_item TYPE STANDARD TABLE OF snwd_so_i,
          lt_data_deleted_item TYPE STANDARD TABLE OF snwd_so_i.
    lt_data_created_item = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                        WHERE ( flag = lcl_buffer=>created ) ( <row>-data ) ).

    IF NOT lt_data_created_item IS INITIAL.
      INSERT snwd_so_i FROM TABLE @lt_data_created_item.
    ENDIF.

    lt_data_updated_item = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                       WHERE ( flag = lcl_buffer=>updated ) ( <row>-data ) ).

    IF NOT lt_data_updated_item IS INITIAL.
      UPDATE snwd_so_i FROM TABLE @lt_data_updated_item.
    ENDIF.

    lt_data_deleted_item = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                       WHERE ( flag = lcl_buffer=>deleted ) ( <row>-data ) ).

    IF NOT lt_data_deleted_item IS INITIAL.
      DELETE snwd_so_i FROM TABLE @lt_data_deleted_item.
    ENDIF.
    CLEAR lcl_buffer=>mt_buffer_master.
  ENDMETHOD.
ENDCLASS.