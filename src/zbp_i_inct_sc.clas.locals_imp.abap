CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF status_code,
*        open TYPE c LENGTH 1 VALUE
        status_op TYPE zdt_status-status_value VALUE 'OP',
        status_ip TYPE zdt_status-status_value VALUE 'IP',
        status_pe TYPE zdt_status-status_value VALUE 'PE',
        status_co TYPE zdt_status-status_value VALUE 'CO',
        status_cl TYPE zdt_status-status_value VALUE 'CL',
        status_cn TYPE zdt_status-status_value VALUE 'CN',
      END OF status_code.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Incident RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS ChangeStatus FOR MODIFY
      IMPORTING keys FOR ACTION Incident~ChangeStatus RESULT result.

    METHODS setIncident FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Incident~setIncident.

    METHODS createInitialHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~createInitialHistory.

    METHODS validateDateFuture FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateDateFuture.

    METHODS validateDateRange FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateDateRange.

    METHODS validateDeleteIncident FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateDeleteIncident.

    METHODS validateStatusChange FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateStatusChange.

    METHODS validationIncident FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validationIncident.


* probando de crear un metodo nuevo
    METHODS get_next_incident_id
      RETURNING VALUE(rv_incident_id) TYPE zdt_inct_sc-incident_id.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ChangeStatus.

    MODIFY ENTITIES OF zi_inct_sc  IN LOCAL MODE
      ENTITY Incident
      UPDATE FROM VALUE #( FOR key IN keys (
                                            %tky = key-%tky
                                            Status = key-%param-NewStatus ) ).

  ENDMETHOD.

  METHOD setIncident.

**  lectura dentro de un read entity
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*    ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(incidents).

* obteniendo el siguiente ID
    DATA(lv_max_id) = get_next_incident_id(  ).

*      modificacion
*   siempre es el mismo punto de ingreso, el BDEF la definicion que hice anteriormente
    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    UPDATE FIELDS ( IncidentId Status CreationDate ChangedDate )
    "datos registros que se verian afectados for -> declarar una estructura para navegar o iterar o indicar lo que seria la declaracion de una variable que seria una estructura
    WITH VALUE #( FOR key IN keys INDEX INTO i ( %tky            = key-%tky
                                                 IncidentId      = lv_max_id + i - 1
                                                 Status          =  status_code-status_op
                                                 CreationDate    = cl_abap_context_info=>get_system_date(  )
                                                 ChangedDate     = cl_abap_context_info=>get_system_date(  )
                                                 ) ).    "maneja la clave tecnica->necesita la clave tencica para identificar los registros afectados
*WITH VALUE #( FOR key IN keys ( %tky = ls_key-  ) ).    "maneja la clave tecnica->necesita la clave tencica para identificar los registros afectados
  ENDMETHOD.

  METHOD createInitialHistory.


  ENDMETHOD.

  METHOD validateDateFuture.
  ENDMETHOD.

  METHOD validateDateRange.
  ENDMETHOD.

  METHOD validateDeleteIncident.
  ENDMETHOD.

  METHOD validateStatusChange.
  ENDMETHOD.

  METHOD validationIncident.
  ENDMETHOD.

  METHOD get_next_incident_id.
    SELECT SINGLE MAX( incident_id )
    FROM zdt_inct_sc
*     FIELDS incident_id
    INTO @DATA(lv_max_id).

    rv_incident_id = lv_max_id + 1.

  ENDMETHOD.

ENDCLASS.
