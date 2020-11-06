CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CONSTANTS: created TYPE c LENGTH 1 VALUE 'C',
               updated TYPE c LENGTH 1 VALUE 'U',
               deleted TYPE c LENGTH 1 VALUE 'D'.
    TYPES: BEGIN OF ty_buffer_master.
             INCLUDE TYPE snwd_so AS data.
    TYPES:   flag TYPE c LENGTH 1,
           END OF ty_buffer_master.
    TYPES: tt_master TYPE SORTED TABLE OF ty_buffer_master WITH UNIQUE KEY node_key.
    CLASS-DATA mt_buffer_master TYPE tt_master.
ENDCLASS.

CLASS lhc_zsmb_i_salesorder_un DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS:
      create     FOR MODIFY
        IMPORTING it_salesorder_create FOR CREATE salesorderi,
      update     FOR MODIFY
        IMPORTING it_salesorder_update FOR UPDATE salesorderi,
      delete     FOR MODIFY
        IMPORTING it_salesorder_delete FOR DELETE salesorderi,
      read       FOR READ
        IMPORTING it_salesorder_read FOR READ salesorderi
        RESULT    et_salesorder.

ENDCLASS.

CLASS lhc_zsmb_i_salesorder_un IMPLEMENTATION.

  METHOD create.
    LOOP AT it_salesorder_create INTO DATA(ls_salesorder_create).
      ls_salesorder_create-%data-node_key = cl_epm_helper=>get_guid( ).
      SELECT SINGLE MAX( so_id ) FROM snwd_so INTO @DATA(lv_max_id).
      ls_salesorder_create-%data-salesorderid = lv_max_id + 1.
      GET TIME STAMP FIELD DATA(lv_time_stamp).
      ls_salesorder_create-%data-Created_At = lv_time_stamp.
      ls_salesorder_create-%data-OverallStatus = 'N'.
      INSERT VALUE #( flag = lcl_buffer=>created
                      data = VALUE #(  node_key       = ls_salesorder_create-%data-node_key
                                       so_id          = ls_salesorder_create-%data-SalesOrderID
                                       created_at     = ls_salesorder_create-%data-Created_At
                                       buyer_guid     = ls_salesorder_create-%data-BuyerGuid
                                       currency_code  = ls_salesorder_create-%data-CurrencyCode
                                       gross_amount   = ls_salesorder_create-%data-GrossAmount
                                       net_amount     = ls_salesorder_create-%data-NetAmount
                                       tax_amount     = ls_salesorder_create-%data-TaxAmount
                                       overall_status = ls_salesorder_create-%data-OverallStatus ) ) INTO TABLE lcl_buffer=>mt_buffer_master.
      IF NOT ls_salesorder_create-%cid IS INITIAL.
        INSERT VALUE #( %cid = ls_salesorder_create-%cid
                        node_key = ls_salesorder_create-node_key ) INTO TABLE mapped-salesorderi.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT it_salesorder_delete INTO DATA(ls_salesorder_delete).
      INSERT VALUE #( flag = lcl_buffer=>deleted
                      data = VALUE #( node_key = ls_salesorder_delete-node_key ) ) INTO TABLE lcl_buffer=>mt_buffer_master.

      IF NOT ls_salesorder_delete-node_key IS INITIAL.
        INSERT VALUE #( %cid = ls_salesorder_delete-%key-node_key
                        node_key = ls_salesorder_delete-%key-node_key )  INTO TABLE mapped-salesorderi.
      ENDIF.
    ENDLOOP.
*============================================================================================================
*======================== UTILIZAR BAPIS CON COMMIT DAN ERROR EN TIEMPO DE EJECUCION.========================
*===================================!NO SE PUEDEN USAR!======================================================
*============================================================================================================
*    DATA lv_persistdb TYPE bapi_epm_boolean.
*    DATA lt_return TYPE STANDARD TABLE OF bapiret2.
*    DATA lv_soid TYPE bapi_epm_so_id.
*    BREAK-POINT.
*    LOOP AT it_salesorder_delete ASSIGNING FIELD-SYMBOL(<fs_salesorder_delete>).
*      SELECT SINGLE so_id FROM snwd_so INTO lv_soid WHERE node_key = <fs_salesorder_delete>-node_key.
*      lv_persistdb = 'X'.
*      CALL FUNCTION 'BAPI_EPM_SO_DELETE'
*        EXPORTING
*          so_id         = lv_soid
**          persist_to_db = lv_persistdb
*        TABLES
*          return        = lt_return.
*    ENDLOOP.
*============================================================================================================
*============================================================================================================
*============================================================================================================
  ENDMETHOD.

  METHOD update.

    LOOP AT it_salesorder_update INTO DATA(ls_salesorder_update).
      SELECT SINGLE * FROM snwd_so
             WHERE node_key EQ @ls_salesorder_update-%data-node_key
             INTO @DATA(ls_ddbb).

      GET TIME STAMP FIELD DATA(lv_time_stamp).
      ls_salesorder_update-%data-Changed_At = lv_time_stamp.
      INSERT VALUE #( flag = lcl_buffer=>updated
                           data = VALUE #( node_key = ls_salesorder_update-%data-node_key
                                           buyer_guid     = COND #( WHEN ls_salesorder_update-%control-buyerguid EQ if_abap_behv=>mk-on
                                                                    THEN ls_salesorder_update-%data-buyerguid
                                                                    ELSE ls_ddbb-buyer_guid )
                                           currency_code  = COND #( WHEN ls_salesorder_update-%control-currencycode EQ if_abap_behv=>mk-on
                                                                    THEN ls_salesorder_update-%data-currencycode
                                                                    ELSE ls_ddbb-currency_code )
                                           gross_amount   = COND #( WHEN ls_salesorder_update-%control-grossamount EQ if_abap_behv=>mk-on
                                                                    THEN ls_salesorder_update-%data-grossamount
                                                                    ELSE ls_ddbb-gross_amount )
                                           net_amount     = COND #( WHEN ls_salesorder_update-%control-netamount EQ if_abap_behv=>mk-on
                                                                    THEN ls_salesorder_update-%data-netamount
                                                                    ELSE ls_ddbb-net_amount )
                                           tax_amount     = COND #( WHEN ls_salesorder_update-%control-taxamount EQ if_abap_behv=>mk-on
                                                                    THEN ls_salesorder_update-%data-taxamount
                                                                    ELSE ls_ddbb-tax_amount )
                                           overall_status = COND #( WHEN ls_salesorder_update-%control-overallstatus EQ if_abap_behv=>mk-on
                                                                    THEN ls_salesorder_update-%data-overallstatus
                                                                    ELSE ls_ddbb-overall_status )
                                           changed_at = COND #( WHEN ls_salesorder_update-%control-Changed_At EQ if_abap_behv=>mk-on
                                                                    THEN ls_salesorder_update-%data-Changed_At
                                                                    ELSE ls_ddbb-changed_at )
                                           so_id = ls_ddbb-so_id
                                           created_at = ls_ddbb-created_at
                                           created_by = ls_ddbb-created_by
                                           changed_by = ls_ddbb-changed_by
                                           note_guid  = ls_ddbb-note_guid
                                           lifecycle_status = ls_ddbb-lifecycle_status
                                           created_by_bp = ls_ddbb-created_by_bp
                                           changed_by_bp = ls_ddbb-changed_by_bp
                                           billing_status = ls_ddbb-billing_status
                                           delivery_status = ls_ddbb-delivery_status
                                           op_id = ls_ddbb-op_id
                                           _dataaging = ls_ddbb-_dataaging
                                           dummy = ls_ddbb-dummy
                                           buy_contact_guid = ls_ddbb-buy_contact_guid
                                           ship_to_adr_guid = ls_ddbb-ship_to_adr_guid
                                           bill_to_adr_guid = ls_ddbb-bill_to_adr_guid
                                           payment_method = ls_ddbb-payment_method
                                           payment_terms = ls_ddbb-payment_terms
                            ) ) INTO TABLE lcl_buffer=>mt_buffer_master.
      IF NOT ls_salesorder_update-node_key IS INITIAL.
        INSERT VALUE #( %cid     = ls_salesorder_update-%data-node_key
                        node_key = ls_salesorder_update-%data-node_key ) INTO TABLE mapped-salesorderi.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zsmb_i_salesorder_un DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS check_before_save REDEFINITION.

    METHODS finalize          REDEFINITION.

    METHODS save              REDEFINITION.

ENDCLASS.

CLASS lsc_zsmb_i_salesorder_un IMPLEMENTATION.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD finalize.
  ENDMETHOD.

  METHOD save.
    DATA: lt_data_created TYPE STANDARD TABLE OF snwd_so,
          lt_data_updated TYPE STANDARD TABLE OF snwd_so,
          lt_data_deleted TYPE STANDARD TABLE OF snwd_so.

    lt_data_created = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                        WHERE ( flag = lcl_buffer=>created ) ( <row>-data ) ).

    IF NOT lt_data_created IS INITIAL.
      INSERT snwd_so FROM TABLE @lt_data_created.
    ENDIF.

    lt_data_updated = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                       WHERE ( flag = lcl_buffer=>updated ) ( <row>-data ) ).

    IF NOT lt_data_updated IS INITIAL.
      UPDATE snwd_so FROM TABLE @lt_data_updated.
    ENDIF.

    lt_data_deleted = VALUE #( FOR <row> IN lcl_buffer=>mt_buffer_master
                       WHERE ( flag = lcl_buffer=>deleted ) ( <row>-data ) ).

    IF NOT lt_data_deleted IS INITIAL.
      DELETE snwd_so FROM TABLE @lt_data_deleted.
    ENDIF.
    CLEAR lcl_buffer=>mt_buffer_master.
  ENDMETHOD.

ENDCLASS.