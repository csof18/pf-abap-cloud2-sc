CLASS zcl_initial_data_sc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    METHODS data_status.
    METHODS data_priority.
    METHODS data_incident.
    METHODS data_historial.

  PROTECTED  SECTION.
  PRIVATE SECTION.
    CONSTANTS: status_op TYPE zdt_status_sc-status_code VALUE 'OP',
               status_ip TYPE zdt_status_sc-status_code VALUE 'IP',
               status_pe TYPE zdt_status_sc-status_code VALUE 'PE',
               status_co TYPE zdt_status_sc-status_code VALUE 'CO',
               status_cl TYPE zdt_status_sc-status_code VALUE 'CL',
               status_cn TYPE zdt_status_sc-status_code VALUE 'CN'.

    CONSTANTS: priority_h TYPE zdt_priority_sc-priority_code VALUE 'H',
               priority_m TYPE zdt_priority_sc-priority_code VALUE 'M',
               priority_l TYPE zdt_priority_sc-priority_code VALUE 'L'.

    DATA: lv_uuid1      TYPE sysuuid_x16,
          lv_uuid2      TYPE sysuuid_x16,
          lv_uuid3      TYPE sysuuid_x16,
          lv_uuid4      TYPE sysuuid_x16,
          lv_uuid5      TYPE sysuuid_x16,
          lv_uuid6      TYPE sysuuid_x16,
          lv_uuid7      TYPE sysuuid_x16,
          lv_uuid8      TYPE sysuuid_x16,
          lv_uuid9      TYPE sysuuid_x16,
          lv_uuid10     TYPE sysuuid_x16,
          lv_his_uuid1  TYPE sysuuid_x16,
          lv_his_uuid2  TYPE sysuuid_x16,
          lv_his_uuid3  TYPE sysuuid_x16,
          lv_his_uuid4  TYPE sysuuid_x16,
          lv_his_uuid5  TYPE sysuuid_x16,
          lv_his_uuid6  TYPE sysuuid_x16,
          lv_his_uuid7  TYPE sysuuid_x16,
          lv_his_uuid8  TYPE sysuuid_x16,
          lv_his_uuid9  TYPE sysuuid_x16,
          lv_his_uuid10 TYPE sysuuid_x16,
          lv_date       TYPE d.

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
        lv_uuid4 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_uuid5 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_uuid6 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_uuid7 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_uuid8 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_uuid9 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_uuid10 = cl_system_uuid=>create_uuid_x16_static( ).
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
                                                   creation_date = lv_date
                                                   changed_date = lv_date )

                                                 ( inc_uuid = lv_uuid2
                                                   incident_id = '00000002'
                                                   status = status_ip
                                                   priority = priority_m
                                                   title = 'Error reporte'
                                                   description = 'Reporte no carga datos'
                                                   creation_date = lv_date
                                                   changed_date = lv_date
                                                   zzresponzag = 'USER000002' )

                                                 ( inc_uuid = lv_uuid3
                                                   incident_id = '00000003'
                                                   status = status_pe
                                                   priority = priority_l
                                                   title = 'Consulta usuario'
                                                   description = 'Consulta funcional'
                                                   creation_date = lv_date
                                                   changed_date = lv_date )

                                                 ( inc_uuid = lv_uuid4
                                                   incident_id = '00000004'
                                                   status = status_op
                                                   priority = priority_m
                                                   title = 'Falla impresora'
                                                   description = 'La impresora de ventas no responde'
                                                   creation_date = lv_date
                                                   changed_date = lv_date )

                                                 ( inc_uuid = lv_uuid5
                                                   incident_id = '00000005'
                                                   status = status_ip
                                                   priority = priority_h
                                                   title = 'Servicio detenido'
                                                   description = 'Servicio de integracion fuera de linea'
                                                   creation_date = lv_date
                                                   changed_date = lv_date
                                                   zzresponzag = 'USER000005' )

                                                 ( inc_uuid = lv_uuid6
                                                   incident_id = '00000006'
                                                   status = status_pe
                                                   priority = priority_l
                                                   title = 'Acceso pendiente'
                                                   description = 'Pendiente aprobacion para acceso al sistema'
                                                   creation_date = lv_date
                                                   changed_date = lv_date )

                                                 ( inc_uuid = lv_uuid7
                                                   incident_id = '00000007'
                                                   status = status_co
                                                   priority = priority_h
                                                   title = 'Error interfaz'
                                                   description = 'Interfaz corregida y procesamiento completado'
                                                   creation_date = lv_date
                                                   changed_date = lv_date
                                                   zzresponzag = 'USER000007' )

                                                 ( inc_uuid = lv_uuid8
                                                   incident_id = '00000008'
                                                   status = status_cl
                                                   priority = priority_m
                                                   title = 'Reporte cerrado'
                                                   description = 'Reporte validado por el usuario y cerrado'
                                                   creation_date = lv_date
                                                   changed_date = lv_date
                                                   zzresponzag = 'USER000008' )

                                                 ( inc_uuid = lv_uuid9
                                                   incident_id = '00000009'
                                                   status = status_cn
                                                   priority = priority_l
                                                   title = 'Solicitud duplicada'
                                                   description = 'Incidente cancelado por encontrarse duplicado'
                                                   creation_date = lv_date
                                                   changed_date = lv_date )

                                                 ( inc_uuid = lv_uuid10
                                                   incident_id = '00000010'
                                                   status = status_op
                                                   priority = priority_l
                                                   title = 'Consulta stock'
                                                   description = 'Diferencia detectada en consulta de stock'
                                                   creation_date = lv_date
                                                   changed_date = lv_date )
                                                ) ).
  ENDMETHOD.


  METHOD data_historial.
    TRY.
        lv_his_uuid1 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid2 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid3 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid4 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid5 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid6 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid7 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid8 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid9 = cl_system_uuid=>create_uuid_x16_static( ).
        lv_his_uuid10 = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        RETURN.
    ENDTRY.

    MODIFY zdt_inct_h_sc FROM TABLE @( VALUE #( ( inc_uuid = lv_uuid1
                                                   his_uuid = lv_his_uuid1
                                                   his_id = '00000001'
                                                   previous_status = ''
                                                   new_status = status_op
                                                   text = 'First Incident' )

                                                 ( inc_uuid = lv_uuid2
                                                   his_uuid = lv_his_uuid2
                                                   his_id = '00000002'
                                                   previous_status = status_op
                                                   new_status = status_ip
                                                   text = 'Responsable asignado' )

                                                 ( inc_uuid = lv_uuid3
                                                   his_uuid = lv_his_uuid3
                                                   his_id = '00000003'
                                                   previous_status = status_op
                                                   new_status = status_pe
                                                   text = 'Pendiente de informacion' )

                                                 ( inc_uuid = lv_uuid4
                                                   his_uuid = lv_his_uuid4
                                                   his_id = '00000004'
                                                   previous_status = ''
                                                   new_status = status_op
                                                   text = 'First Incident' )

                                                 ( inc_uuid = lv_uuid5
                                                   his_uuid = lv_his_uuid5
                                                   his_id = '00000005'
                                                   previous_status = status_op
                                                   new_status = status_ip
                                                   text = 'Analisis iniciado' )

                                                 ( inc_uuid = lv_uuid6
                                                   his_uuid = lv_his_uuid6
                                                   his_id = '00000006'
                                                   previous_status = status_op
                                                   new_status = status_pe
                                                   text = 'Pendiente de aprobacion' )

                                                 ( inc_uuid = lv_uuid7
                                                   his_uuid = lv_his_uuid7
                                                   his_id = '00000007'
                                                   previous_status = status_ip
                                                   new_status = status_co
                                                   text = 'Solucion implementada' )

                                                 ( inc_uuid = lv_uuid8
                                                   his_uuid = lv_his_uuid8
                                                   his_id = '00000008'
                                                   previous_status = status_op
                                                   new_status = status_cl
                                                   text = 'Cierre confirmado' )

                                                 ( inc_uuid = lv_uuid9
                                                   his_uuid = lv_his_uuid9
                                                   his_id = '00000009'
                                                   previous_status = status_op
                                                   new_status = status_cn
                                                   text = 'Incidente duplicado' )

                                                 ( inc_uuid = lv_uuid10
                                                   his_uuid = lv_his_uuid10
                                                   his_id = '00000010'
                                                   previous_status = ''
                                                   new_status = status_op
                                                   text = 'First Incident' )
                                               ) ).

  ENDMETHOD.


  METHOD data_status.
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
    MODIFY zdt_priority_sc FROM TABLE @( VALUE #(   ( priority_code           = priority_h
                                                      priority_description    = 'Description High' )
                                                    ( priority_code           = priority_m
                                                      priority_description    = 'Description Medium' )
                                                    ( priority_code           = priority_l
                                                      priority_description    = 'Description Low' ) ) ).

  ENDMETHOD.
ENDCLASS.
