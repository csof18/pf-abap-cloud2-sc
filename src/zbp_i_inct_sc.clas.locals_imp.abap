CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF status_code,
*        open TYPE c LENGTH 1 VALUE
        status_op TYPE zdt_status_sc-status_code VALUE 'OP',
        status_ip TYPE zdt_status_sc-status_code VALUE 'IP',
        status_pe TYPE zdt_status_sc-status_code VALUE 'PE',
        status_co TYPE zdt_status_sc-status_code VALUE 'CO',
        status_cl TYPE zdt_status_sc-status_code VALUE 'CL',
        status_cn TYPE zdt_status_sc-status_code VALUE 'CN',
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
    METHODS validationStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validationStatus.


* probando de crear un metodo nuevo
    METHODS get_next_incident_id
      RETURNING VALUE(rv_incident_id) TYPE zdt_inct_sc-incident_id.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_features.

*  leer la entidad + datos
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(incidents)            "recuperar todos los incidentes
      FAILED failed.                     "posibles fallos se puede declarar una variable, aunque no es necesario en este caso porque tiene failed

    result = VALUE #( FOR incident IN incidents ( %tky    = incident-%tky
                                                  %field-Status = COND #( WHEN incident-Status = status_code-status_cn
                                                                            OR incident-Status = status_code-status_co
                                                                            OR incident-Status = status_code-status_cl
                                                                          THEN if_abap_behv=>fc-f-read_only
                                                                          ELSE if_abap_behv=>fc-f-unrestricted )
*                                                  %action-ChangeStatus = COND #( WHEN incident-Status = status_code-status_pe          "para hacer que algo (en este caso btn) se vea o no
*                                                                                 THEN if_abap_behv=>fc-o-disabled
*                                                                                 ELSE if_abap_behv=>fc-o-enabled )
                                                   ) ).       "devolver tab interna con vlaor del estado

  ENDMETHOD.

  METHOD get_instance_authorizations.

    DATA: update_requested TYPE abap_boolean,
          update_granted   TYPE abap_boolean,
          delete_requested TYPE abap_boolean,
          delete_granted   TYPE abap_boolean.

    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Priority )
    WITH CORRESPONDING #( keys )
    RESULT DATA(incidents)
    FAILED failed.

*   determina si se solicito o no una operacion de actualizacion
    update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
                                 OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                                 THEN abap_true
                                 ELSE abap_false ).

*   determina si se solicito o no una operacion de eliminacion
    delete_requested = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on
                                 OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                                 THEN abap_true
                                 ELSE abap_false ).


*     si es verdadero seguir sino no continua
    CHECK update_requested EQ abap_true.

    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).
    DATA user TYPE string VALUE 'CB9980007116'.

*   si se tiene el codigo de el campo al que se quiere bloquear el acceso
    LOOP AT incidents INTO DATA(incident)
    WHERE Priority IS NOT INITIAL.

      IF lv_technical_name EQ user AND incident-Priority NE 'M'.
*        para validar de eliminacion y de edicion agregar datos una forma de unificar las 2 validaciones
        update_granted = delete_granted = abap_true.

      ELSE.
        update_granted = delete_granted = abap_false.
      ENDIF.
*      IF lv_technical_name EQ user AND incident-Priority NE 'M'.
*        update_granted = abap_true.

*      ELSE.
*        update_granted = abap_false.
*      ENDIF.

*   agregar registros en el result  ----  indicar el registro para que el framework determine si permite o no el acceso a la operacion de actualizacion

      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted EQ abap_true       "declarar una var dentro del mismo registro
                                             THEN if_abap_behv=>auth-allowed        "tiene valor permitido o no
                                             ELSE if_abap_behv=>auth-unauthorized
                                             )
                          del_auth = COND #( WHEN delete_granted EQ abap_true       "declarar una var dentro del mismo registro
                                             THEN if_abap_behv=>auth-allowed        "tiene valor permitido o no
                                             ELSE if_abap_behv=>auth-unauthorized
                                             )
                         IN %tky         = incident-%tky             " el let declarado arriba tiene que ir con un IN
                            %update      = upd_auth
                            %action-Edit = upd_auth
                            %delete      = del_auth ) TO result.   "asignar al componente que se agrega en la tabla interna que se devuelve

*      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted EQ abap_true       "declarar una var dentro del mismo registro
*                                             THEN if_abap_behv=>auth-allowed        "tiene valor permitido o no
*                                             ELSE if_abap_behv=>auth-unauthorized
*                                             )
*                         IN %tky         = incident-%tky             " el let declarado arriba tiene que ir con un IN
*                            %update      = upd_auth
*                            %action-Edit = upd_auth
*                            %delete      = '' ) TO result.   "asignar al componente que se agrega en la tabla interna que se devuelve
*

    ENDLOOP.







  ENDMETHOD.

  METHOD get_global_authorizations.

    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).
    DATA user TYPE string VALUE 'CB9980007116'.

*   permitir o no que x usuario pueda crear un nuevo incidente
    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.  "Si se solicito la opreacion de creat - mk si se marco o no

      IF  requested_authorizations-%create EQ user.    "si el usuario que solicito la accion es = a valor

        result-%create = if_abap_behv=>auth-unauthorized.  "asi mi usuario si puede crear

      ELSE.
        result-%create = if_abap_behv=>auth-allowed.
      ENDIF.

    ENDIF.

*  habilitar o no x btn para determinado usuario
    IF requested_authorizations-%update EQ if_abap_behv=>mk-on OR
     requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.

      IF lv_technical_name EQ user.
*        result-%update = if_abap_behv=>auth-unauthorized.           " no tiene permisos
*        result-%action-Edit = if_abap_behv=>auth-unauthorized.
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-Edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update = if_abap_behv=>auth-unauthorized.
        result-%action-Edit = if_abap_behv=>auth-unauthorized.
*        result-%update = if_abap_behv=>auth-allowed.
*        result-%action-Edit = if_abap_behv=>auth-allowed.

      ENDIF.

    ENDIF.




  ENDMETHOD.

  METHOD ChangeStatus.

*   siguiendo video
*DATA status_inc TYPE TABLE FOR UPDATE ZI_INCT_SC.
*
** lectura de los datos
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*     FIELDS ( Status )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(incidents).
*
*
*      LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
*      DATA(status_inci) = keys[ KEY  id %tky = <incident>-%tky ]-%param-NewStatus.
*   APPEND VALUE #( %tky = <incident>-%tky
*                    )
*
*      ENDLOOP.
***************************************

*****************CAMBIA EL ESTADO DE INCIDENTES NO DE HISTORIAL, NO SE VE EL TEXTO NOSE SI SIRVE***********************

* definir una tabla para tratar siempre los multiples registros que se pueden solicitar
    DATA status_for_update TYPE TABLE FOR UPDATE zi_inct_sc.


*status_for_update[ 1 ]
* lectura de datos para recuperar la informacion que se quiere modificar
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

* prueba de video
*    DATA status_prob TYPE zdt_status_sc-status_code.

    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
      DATA(new_status) = keys[ KEY id %tky = <incident>-%tky ]-%param-NewStatus.
*      DATA(new_text_status) = keys[ KEY id %tky = <incident>-%tky ]-%param-Observation.

      APPEND VALUE #( %tky   = <incident>-%tky
                      status = new_status
                     ) TO status_for_update.

    ENDLOOP.

    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    UPDATE FIELDS ( Status )
    WITH status_for_update.


    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(inc_status).

    result = VALUE #( FOR incident IN inc_status ( %tky  = incident-%tky
                                                   %param = incident ) ).

*****************CAMBIA EL ESTADO DE INCIDENTES NO DE HISTORIAL, NO SE VE EL TEXTO NOSE SI SIRVE***********************




*    MODIFY ENTITIES OF zi_inct_sc  IN LOCAL MODE
*      ENTITY Incident
*      UPDATE FROM VALUE #( FOR key IN keys (
*                                            %tky = key-%tky
*                                            Status = key-%param-NewStatus ) ).

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
  ENDMETHOD.

  METHOD createInitialHistory.

    DATA lv_text_ini TYPE string VALUE 'First Incident'.

    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident CREATE BY \_Historial
    FROM VALUE #( FOR key IN keys INDEX INTO i ( %tky    = key-%tky
                                                 %target = VALUE #( ( %cid      = |ID_{ i }|
                                                                      NewStatus = status_code-status_op
                                                                      Text      = lv_text_ini
                                                                      %control  = VALUE #( NewStatus = if_abap_behv=>mk-on
                                                                                           Text      = if_abap_behv=>mk-on
                                                                                         )
                                                                    ) )
                                               ) ).
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

  METHOD validationStatus.

    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
       ENTITY Incident
       FIELDS ( Status )
       WITH CORRESPONDING #( keys )
       RESULT DATA(incidents).

    DATA status TYPE SORTED TABLE OF zdt_status_sc WITH UNIQUE KEY client status_code.

* transportar el status de la tabla a la que defini recien
    status = CORRESPONDING #( incidents DISCARDING DUPLICATES MAPPING status_code = Status EXCEPT * ).      "con except* se indica que no importan las otras columnas

*    eliminar los registros que tengan el dato vacios
    DELETE status WHERE status_code IS INITIAL.

* comprobar clientes de la tabla con los clientes la tabla interna que declare recien
    IF status IS NOT INITIAL.
      SELECT FROM zdt_status_sc AS ddbb
      INNER JOIN @incidents AS http_req ON ddbb~status_code EQ http_req~Status
      FIELDS ddbb~status_code
      INTO TABLE @DATA(valid_status).
    ENDIF.

    LOOP AT incidents INTO DATA(incident).
      IF incident-Status IS INITIAL.

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.

      ELSEIF incident-Status IS NOT INITIAL AND NOT line_exists( valid_status[ status_code = incident-Status ]  ).  "si me pasaste un valor, y este valor no existe en la tabla de los status validos tambien tengo error

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
