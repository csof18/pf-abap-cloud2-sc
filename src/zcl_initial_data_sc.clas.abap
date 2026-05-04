CLASS zcl_initial_data_sc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    METHODS data_incident.
    METHODS data_historial.
    METHODS data_status.
    METHODS data_priority.

  PROTECTED  SECTION.
  PRIVATE SECTION.
    CONSTANTS: status_op TYPE zdt_status-status_value VALUE 'OP',
               status_ip TYPE zdt_status-status_value VALUE 'IP',
               status_pe TYPE zdt_status-status_value VALUE 'PE',
               status_co TYPE zdt_status-status_value VALUE 'CO',
               status_cl TYPE zdt_status-status_value VALUE 'CL',
               status_cn TYPE zdt_status-status_value VALUE 'CN'.

    CONSTANTS: priority_h TYPE zdt_priority_sc-priority_code VALUE 'H',
               priority_m TYPE zdt_priority_sc-priority_code VALUE 'M',
               priority_l TYPE zdt_priority_sc-priority_code VALUE 'L'.

    DATA: lv_uuid1     TYPE sysuuid_x16,
          lv_uuid2     TYPE sysuuid_x16,
          lv_uuid3     TYPE sysuuid_x16,
          lv_his_uuid1 TYPE sysuuid_x16,
          lv_his_uuid2 TYPE sysuuid_x16,
          lv_his_uuid3 TYPE sysuuid_x16,
          lv_date      TYPE d.

ENDCLASS.



CLASS zcl_initial_data_sc IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    data_incident(  ).
    data_historial(  ).
    data_status(  ).
    data_priority(  ).

  ENDMETHOD.

  METHOD data_incident.
    TRY.
        lv_uuid1 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_uuid2 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_uuid3 = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.
    lv_date = cl_abap_context_info=>get_system_date(  ).

    MODIFY zdt_inct_sc FROM TABLE @( VALUE #( ( inc_uuid = lv_uuid1
                                                  incident_id = '00000001'
                                                  status = status_op
                                                  priority = priority_h
                                                  title = 'Error login'
                                                  description = 'Usuario no puede loguearse'
                                                  creation_date = lv_date )

                                                ( inc_uuid = lv_uuid2
                                                  incident_id = '00000002'
                                                  status = status_ip
                                                  priority = priority_m
                                                  title = 'Error reporte'
                                                  description = 'Reporte no carga datos'
                                                  creation_date = lv_date )

                                                ( inc_uuid = lv_uuid3
                                                  incident_id = '00000003'
                                                  status = status_pe
                                                  priority = priority_l
                                                  title = 'Consulta usuario'
                                                  description = 'Consulta funcional'
                                                  creation_date = lv_date )
                                              ) ).
  ENDMETHOD.

  METHOD data_historial.
    TRY.
        lv_his_uuid1 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid2 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid3 = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    MODIFY zdt_inct_h_sc FROM TABLE @( VALUE #( ( inc_uuid = lv_uuid1
                                                  his_uuid = lv_his_uuid1
                                                  his_id = '00000001'
                                                  previous_status = status_op
                                                  new_status = status_ip
                                                  text = 'Se comienza a trabajar' )

                                                ( inc_uuid = lv_uuid2
                                                  his_uuid = lv_his_uuid2
                                                  his_id = '00000002'
                                                  previous_status = status_ip
                                                  new_status = status_co
                                                  text = 'Incidente completado' )

                                                ( inc_uuid = lv_uuid3
                                                  his_uuid = lv_his_uuid3
                                                  his_id = '00000003'
                                                  previous_status = status_pe
                                                  new_status = status_op
                                                  text = 'Reabierto' )
                                               ) ).

  ENDMETHOD.

  METHOD data_status.
    DELETE FROM zdt_status_sc.
    MODIFY zdt_status_sc FROM TABLE @( VALUE #( ( status_code           = status_cl
                                                  status_description    = 'Description Closed' )
                                                ( status_code           = status_op
                                                  status_description    = 'Description Open' )
                                                ( status_code           = status_cn
                                                  status_description    = 'Description Canceled' )
                                                ( status_code           = status_co
                                                  status_description    = 'Description Completed' )
                                                ( status_code           = status_ip
                                                  status_description    = 'Description In Progress' )
                                                ( status_code           = status_pe
                                                  status_description    = 'Description Pending' ) ) ).


  ENDMETHOD.

  METHOD data_priority.
    DELETE FROM zdt_priority_sc.
    MODIFY zdt_priority_sc FROM TABLE @( VALUE #(   ( priority_code           = priority_h
                                                      priority_description    = 'Description High' )
                                                    ( priority_code           = priority_m
                                                      priority_description    = 'Description Medium' )
                                                    ( priority_code           = priority_l
                                                      priority_description    = 'Description Low' ) ) ).

  ENDMETHOD.



ENDCLASS.
