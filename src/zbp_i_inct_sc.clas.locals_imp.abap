CLASS lhc_incidenthis DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateDeleteHistory FOR VALIDATE ON SAVE
      IMPORTING keys FOR IncidentHis~validateDeleteHistory.

ENDCLASS.

CLASS lhc_incidenthis IMPLEMENTATION.

  METHOD validateDeleteHistory.
*   READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY IncidentHis
*    FIELDS ( HisUuid )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(incidentsHis).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      APPEND VALUE #( %tky = <key>-%tky ) TO failed-incidenthis.

      APPEND VALUE #( %tky = <key>-%tky
                      %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                     text    = |No es posible eliminar un Historial | )
                                                   ) TO reported-incidenthis.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF status_code,
        status_op TYPE zdt_status_sc-status_code VALUE 'OP',
        status_ip TYPE zdt_status_sc-status_code VALUE 'IP',
        status_pe TYPE zdt_status_sc-status_code VALUE 'PE',
        status_co TYPE zdt_status_sc-status_code VALUE 'CO',
        status_cl TYPE zdt_status_sc-status_code VALUE 'CL',
        status_cn TYPE zdt_status_sc-status_code VALUE 'CN',
      END OF status_code.
    CONSTANTS:
      BEGIN OF priority_code,
        priority_h TYPE zdt_priority_sc-priority_code VALUE 'H',
        priority_m TYPE zdt_priority_sc-priority_code VALUE 'M',
        priority_l TYPE zdt_priority_sc-priority_code VALUE 'L',
      END OF priority_code.

*   usuario administrador para pruebas
    CONSTANTS gc_admin_user TYPE syuname VALUE 'CB9980007116'.
    CONSTANTS gc_admin_no_user TYPE syuname VALUE 'CB9980007124'.

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

    METHODS validationPriorityCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validationPriorityCode.

    METHODS get_next_incident_id
      RETURNING VALUE(rv_incident_id) TYPE zdt_inct_sc-incident_id.

    METHODS get_next_history_id
      RETURNING VALUE(rv_history_id) TYPE zdt_inct_h_sc-his_id.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_features.
*   controlar dinamicamente que hace cada cosa segun el estado de cada registro.
*    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).
*  leer la entidad + datos
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Status  )
      WITH CORRESPONDING #( keys )
      RESULT DATA(incidents)            "recuperar todos los incidentes
      FAILED failed.                     "posibles fallos se puede declarar una variable, aunque no es necesario en este caso porque tiene failed
**PROBAR SI VA O NO
*    IF lv_user NE gc_admin_user.
**      IF lv_user EQ gc_admin_no_user.
*      LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*        APPEND VALUE #( %tky = <key>-%tky ) TO failed-incident.
*
*        APPEND VALUE #( %tky = <key>-%tky
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                      text = 'No cuenta autorización para cambiar el estado ' )
*                      ) TO reported-incident.
*      ENDLOOP.
*      RETURN.
*    ENDIF.
**PROBAR SI VA O NO
*   configuracion comportamiento dinamico po instancia
    result = VALUE #( FOR incident IN incidents ( %tky          = incident-%tky
                                                  %action-ChangeStatus = COND #( WHEN incident-%is_draft = if_abap_behv=>mk-on
                                                                                 THEN if_abap_behv=>fc-o-disabled
                                                                                 WHEN incident-Status = status_code-status_cn
                                                                                   OR incident-Status = status_code-status_co
                                                                                   OR incident-Status = status_code-status_cl
                                                                                 THEN if_abap_behv=>fc-o-disabled

                                                                                 ELSE if_abap_behv=>fc-o-enabled )
                                                  ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
*   usuario logeado
*    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).
    DATA(update_requested) = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
                                       OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                                     THEN abap_true
                                     ELSE abap_false ).
    DATA(delete_requested) = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on
                                     THEN abap_true
                                     ELSE abap_false ).

    CHECK update_requested = abap_true
       OR delete_requested = abap_true.

    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(incidents)
    FAILED failed.

    result = VALUE #( FOR incident IN incidents (  %tky         = incident-%tky
                                                   %update      = if_abap_behv=>auth-allowed
                                                   %delete      = COND #( WHEN incident-Status = status_code-status_op
                                                                          THEN if_abap_behv=>auth-allowed
                                                                          ELSE if_abap_behv=>auth-unauthorized
                                                                        )
*                                                   %action-Edit = COND #( WHEN incident-Status = status_code-status_op
*                                                                          THEN if_abap_behv=>auth-allowed
*                                                                          ELSE if_abap_behv=>auth-unauthorized
*                                                                        )
                                                 ) ).
*    result = VALUE #( FOR incident IN incidents (  %tky         = incident-%tky
*                                                   %update      = if_abap_behv=>auth-allowed
*                                                   %delete      = COND #( WHEN incident-Status = status_code-status_op
*                                                                          THEN if_abap_behv=>auth-allowed
*                                                                          ELSE if_abap_behv=>auth-unauthorized
*                                                                        )
*                                                   %action-Edit = COND #( WHEN incident-Status = status_code-status_op
*                                                                          THEN if_abap_behv=>auth-allowed
*                                                                          ELSE if_abap_behv=>auth-unauthorized
*                                                                        )
*                                                 ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.

*   usuario logeado
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

    DATA(lv_auth) = COND abp_behv_auth(  WHEN lv_user IS NOT INITIAL
                                         "WHEN lv_user = gc_admin_no_user
                                         THEN if_abap_behv=>auth-allowed
                                         ELSE if_abap_behv=>auth-unauthorized ).


*   crear incidente -> permitir o no que x usuario pueda crear un nuevo incidente
    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.  "Si se solicito la opreacion de creat - mk si se marco o no
      result-%create = lv_auth.
    ENDIF.

    IF requested_authorizations-%update EQ if_abap_behv=>mk-on .
*    OR requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.
      result-%update = lv_auth.
*      result-%action-Edit = if_abap_behv=>auth-allowed.
*    ELSE.
*      result-%update = if_abap_behv=>auth-unauthorized.
*      result-%action-Edit = if_abap_behv=>auth-unauthorized.
    ENDIF.

    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.
      result-%delete = lv_auth.
    ENDIF.

  ENDMETHOD.

  METHOD ChangeStatus.

    DATA: status_for_update TYPE TABLE FOR UPDATE zi_inct_sc,
*          lv_next_his_id    TYPE zdt_inct_h_sc-his_id.
          lv_error          TYPE abap_boolean.

*    DATA history_for_create TYPE TABLE FOR UPDATE zi_inct_h_sc.

    DATA(keys_valid_status) = keys.
*    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

*    IF lv_user NE gc_admin_user.
**    IF lv_user ne gc_admin_no_user.        "prueba para que no deje cambiar el estado
*      LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*        APPEND VALUE #( %tky = <key>-%tky ) TO failed-incident.
*
*        APPEND VALUE #( %tky = <key>-%tky
*                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
*                                                      text = 'No tiene autorización para cambiar el estado ' )
*                      ) TO reported-incident.
*      ENDLOOP.
*      RETURN.
*
*    ENDIF.




*   sientra por le loop tenemos un error, si no entra no hay error y sigue con la logica
*  validar param obligatorios
    LOOP AT keys_valid_status ASSIGNING FIELD-SYMBOL(<key_valid_status>)
    WHERE %param-NewStatus IS INITIAL
    OR %param-Observation IS INITIAL.
      lv_error = abap_true.

      APPEND VALUE #( %tky = <key_valid_status>-%tky ) TO failed-incident.

      APPEND VALUE #( %tky = <key_valid_status>-%tky
                      %msg = new_message_with_text(
                             severity = if_abap_behv_message=>severity-error
                             text = 'Debe completar Nuevo Estado y Observación' )
                             %element-Status = if_abap_behv=>mk-on  "PROBAR - ANDA??
                    ) TO reported-incident.
    ENDLOOP.

*   si hay error corta
    CHECK lv_error NE abap_true.
*    CHECK lv_error IS INITIAL.

*status_for_update[ 1 ]
* leer incidente actual
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Status ChangedDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

*    DATA status_prob TYPE zdt_status_sc-status_code.
    DATA(lv_next_his_id) = get_next_history_id(  ).

*    validacion  + armado update
    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
*      DATA(new_status) = keys[ KEY id %tky = <incident>-%tky ]-%param-NewStatus.
*      DATA(new_text_status) = keys[ KEY id %tky = <incident>-%tky ]-%param-Observation.

*   prueba validacion
      DATA(ls_key) = VALUE #( keys_valid_status[ KEY id
                                                 %tky = <incident>-%tky ] OPTIONAL ).

      IF ls_key IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(new_status)      = ls_key-%param-NewStatus.
      DATA(new_text_status) = ls_key-%param-Observation.

*   prueba validacion




*   validar cambios de estado - VER SI DE VERDAD HACE FALTA TAMBIEN ACA
      IF <incident>-Status   = status_code-status_cn
        OR <incident>-Status = status_code-status_co
        OR <incident>-Status = status_code-status_cl.

        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                               severity        = if_abap_behv_message=>severity-error
                               text            = 'No es posible cambiar el estado del incidente' )
                               %element-Status = if_abap_behv=>mk-on  "PROBAR - ANDA??
                      ) TO reported-incident.

        CONTINUE.
      ENDIF.

*    No permitir PE -> CL / CO
      IF <incident>-Status = status_code-status_pe AND ( new_status = status_code-status_co
                                                    OR   new_status = status_code-status_cl ) .

        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
*        APPEND VALUE #( %tky = <key_valid_status>-%tky ) TO failed-incident.

*        APPEND VALUE #( %tky = <key_valid_status>-%tky
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text = 'Un incidente Pending no puede pasar a Completed o Closed' )
                               %element-Status = if_abap_behv=>mk-on  "PROBAR - ANDA??
                      ) TO reported-incident.
        CONTINUE.
      ENDIF.

      IF <incident>-Status = new_status.
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text = 'El nuevo estado debe ser diferente al actual' )
                               %element-Status = if_abap_behv=>mk-on
                      ) TO reported-incident.

        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.

        CONTINUE.

      ENDIF.

** Si pasa a In Progress debe tener responsable
*      IF new_status = status_code-status_ip
*      AND <incident>-Responsible IS INITIAL.
*
*        APPEND VALUE #( %tky = <incident>-%tky )
*          TO failed-incident.
*
*        APPEND VALUE #(
*            %tky = <incident>-%tky
*            %msg = new_message_with_text(
*                      severity = if_abap_behv_message=>severity-error
*                      text = 'Debe asignar un responsable antes de pasar a In Progress' )
*            %element-Responsible = if_abap_behv=>mk-on
*          ) TO reported-incident.
*
*        CONTINUE.
*
*      ENDIF.

*        update de status
      APPEND VALUE #( %tky   = <incident>-%tky
                      status = new_status
                      ChangedDate = cl_abap_context_info=>get_system_date(  )
                     ) TO status_for_update.

    ENDLOOP.

*    Actualizar incidente
    IF status_for_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
      ENTITY Incident
      UPDATE FIELDS ( Status ChangedDate )
      WITH status_for_update.

    ENDIF.

*   crear historial
    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    CREATE BY \_Historial
    FROM VALUE #( FOR incident IN incidents INDEX INTO idx ( %tky           = incident-%tky
                                                             %target        = VALUE #( ( %cid = |HIS_{ idx }|
                                                             HisId          = lv_next_his_id + idx - 1
                                                             PreviousStatus = incident-Status
                                                             NewStatus      = keys_valid_status[ KEY id %tky = incident-%tky ]-%param-NewStatus
                                                             Text           = keys_valid_status[ KEY id %tky = incident-%tky ]-%param-Observation
                                                             %control       = VALUE #(  HisId           = if_abap_behv=>mk-on
                                                                                        PreviousStatus  = if_abap_behv=>mk-on
                                                                                        NewStatus       = if_abap_behv=>mk-on
                                                                                        Text            = if_abap_behv=>mk-on
                                                                                       )
                                                                                       ) )
                                                             )
                 ).


*   devolver resultados
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
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(incidents).

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
                                                 Status          = status_code-status_op
                                                 CreationDate    = cl_abap_context_info=>get_system_date(  )
                                                 ChangedDate     = cl_abap_context_info=>get_system_date(  )
                                                 ) ).    "maneja la clave tecnica->necesita la clave tencica para identificar los registros afectados

*   PONER LOGICA PARA QUE CAMPO FECHA MODIFICACION NO SE PUEDA MODIFICAR CUANDO SE CREA UN NUEVO INCIDENTE

  ENDMETHOD.

  METHOD createInitialHistory.

    DATA lv_text_ini TYPE string VALUE 'First Incident'.
    DATA(lv_next_his_id) = get_next_history_id(  ).

    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident CREATE BY \_Historial
    FROM VALUE #( FOR key IN keys INDEX INTO i ( %tky    = key-%tky
                                                 %target = VALUE #( ( %cid           = |ID_{ i }|
                                                                      HisId          = lv_next_his_id + i - 1
                                                                      PreviousStatus = 'CN'
                                                                      NewStatus      = status_code-status_op
                                                                      Text           = lv_text_ini
                                                                      %control  = VALUE #( HisId            = if_abap_behv=>mk-on
                                                                                           PreviousStatus   = if_abap_behv=>mk-on
                                                                                           NewStatus        = if_abap_behv=>mk-on
                                                                                           Text             = if_abap_behv=>mk-on
                                                                                         )
                                                                        ) )
                                                   ) ).
  ENDMETHOD.

  METHOD validateDateFuture.
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*        ENTITY Incident
*        FIELDS ( CreationDate ChangedDate )
*        WITH CORRESPONDING #( keys )
*        RESULT DATA(incidents).
*
*    DATA(lv_fecha_mod) = cl_abap_context_info=>get_system_date(  ).
*
*    LOOP AT incidents INTO DATA(incident).
*      IF incident-CreationDate <= lv_fecha_mod.
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*
*      ENDIF.
*
**      IF incident-ChangedDate > lv_fecha_mod.
*      IF incident-ChangedDate <= lv_fecha_mod.
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*
*      ENDIF.
*
*    ENDLOOP.

  ENDMETHOD.

  METHOD validateDateRange.

    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
        ENTITY Incident
        FIELDS ( CreationDate ChangedDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(incidents).

    LOOP AT incidents INTO DATA(incidente).
      IF incidente-ChangedDate IS INITIAL.
        APPEND VALUE #( %tky = incidente-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = incidente-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'La fecha de modficacion debe contener un dato' )
                         %element-ChangedDate = if_abap_behv=>mk-on
                        ) TO reported-incident.

      ENDIF.

      IF incidente-ChangedDate GT cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #( %tky = incidente-%tky ) TO failed-incident.

        APPEND VALUE #( %tky = incidente-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'Fecha de modificacion futura' )
                         %element-ChangedDate = if_abap_behv=>mk-on
                            ) TO reported-incident.
      ENDIF.

      IF  incidente-ChangedDate LT  incidente-CreationDate AND incidente-ChangedDate IS NOT INITIAL
                                                          AND incidente-CreationDate IS NOT INITIAL.
        APPEND VALUE #( %tky = incidente-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = incidente-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'No puede ser anterior a la fecha de creacion' )
                         %element-CreationDate = if_abap_behv=>mk-on
                         %element-ChangedDate = if_abap_behv=>mk-on
                       ) TO reported-incident.


      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDeleteIncident.
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( IncidentId Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

    LOOP AT incidents INTO DATA(incidente).
      IF incidente-Status NE status_code-status_op.
        APPEND VALUE #( %tky = incidente-%tky ) TO failed-incident.

        APPEND VALUE #( %tky = incidente-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                       text    = |El incidente { incidente-IncidentId } no se puede eliminar, unicamente con estado Open | )
                        %element-Status = if_abap_behv=>mk-on ) TO reported-incident.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatusChange.
  ENDMETHOD.

  METHOD validationIncident.
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
       ENTITY Incident
       FIELDS ( Title Description Priority Status CreationDate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(incidents).

    LOOP AT incidents INTO DATA(incident).
      IF incident-Title IS INITIAL.
        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
      ENDIF.

      IF incident-Description IS INITIAL.
        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
      ENDIF.

*      IF incident-Priority IS INITIAL.
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*      ENDIF.
*
*      IF incident-Status IS INITIAL.
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*      ENDIF.
*
*      IF incident-CreationDate IS INITIAL.
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_next_incident_id.
    SELECT SINGLE FROM zdt_inct_sc
     FIELDS MAX( incident_id )
    INTO @DATA(lv_max_id).

    rv_incident_id = lv_max_id + 1.
  ENDMETHOD.

  METHOD get_next_history_id.
    SELECT SINGLE FROM zdt_inct_h_sc
     FIELDS MAX( his_id )
    INTO @DATA(lv_max_his_id).

    rv_history_id = lv_max_his_id + 1.
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
      INNER JOIN @status AS http_req ON ddbb~status_code EQ http_req~status_code
      FIELDS ddbb~status_code
      INTO TABLE @DATA(valid_status).
    ENDIF.

    LOOP AT incidents INTO DATA(incident).
*    se considera como un error
      IF incident-Status IS INITIAL.

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.

*      si me pasaste un valor, y este valor no existe en la tabla de los status validos tambien tengo error
      ELSEIF incident-Status IS NOT INITIAL AND NOT line_exists( valid_status[ status_code = incident-Status ]  ).

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validationPriorityCode.
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
     ENTITY Incident
     FIELDS ( Priority )
     WITH CORRESPONDING #( keys )
     RESULT DATA(incidents).

    DATA priority TYPE SORTED TABLE OF zdt_priority_sc WITH UNIQUE KEY client priority_code.

* transportar el status de la tabla a la que defini recien
    priority = CORRESPONDING #( incidents DISCARDING DUPLICATES MAPPING priority_code = Priority EXCEPT * ).      "con except* se indica que no importan las otras columnas

*    eliminar los registros que tengan el dato vacios
    DELETE priority WHERE priority_code IS INITIAL.

* comprobar clientes de la tabla con los clientes la tabla interna que declare recien
    IF priority IS NOT INITIAL.
      SELECT FROM zdt_priority_sc AS ddbb
      INNER JOIN @priority AS http_req ON ddbb~priority_code EQ http_req~priority_code
      FIELDS ddbb~priority_code
      INTO TABLE @DATA(valid_priority).
    ENDIF.

    LOOP AT incidents INTO DATA(incident).
*    se considera como un error
      IF incident-Priority IS INITIAL.

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*   indicar un mensaje de error
*reported-incident[ 1 ]-
        APPEND VALUE #( %tky = incident-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text = 'Debe completar el campo de Priority' )
                        %element-Priority = if_abap_behv=>mk-on
                      ) TO reported-incident.

*      si me pasaste un valor, y este valor no existe en la tabla de los status validos tambien tengo error
      ELSEIF NOT line_exists( valid_priority[ priority_code = incident-Priority ]  ).
*      ELSEIF incident-Priority IS NOT INITIAL AND NOT line_exists( valid_priority[ priority_code = incident-Priority ]  ).

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.

        APPEND VALUE #( %tky = incident-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text = 'El valor de Priority es incorrecto' )
                        %element-Priority = if_abap_behv=>mk-on
                      ) TO reported-incident.

*       APPEND VALUE #( %tky = incident-%tky
*                       %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>enter_agency_id
*                                                                                "agency_id = incident-Priority
*                                                                                severity = if_abap_behv_message=>severity-error )
*                                                                               ) to reported-incident.


      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.





*******************codigo original************************
*CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    CONSTANTS:
*      BEGIN OF status_code,
**        open TYPE c LENGTH 1 VALUE
*        status_op TYPE zdt_status_sc-status_code VALUE 'OP',
*        status_ip TYPE zdt_status_sc-status_code VALUE 'IP',
*        status_pe TYPE zdt_status_sc-status_code VALUE 'PE',
*        status_co TYPE zdt_status_sc-status_code VALUE 'CO',
*        status_cl TYPE zdt_status_sc-status_code VALUE 'CL',
*        status_cn TYPE zdt_status_sc-status_code VALUE 'CN',
*      END OF status_code.
*
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR Incident RESULT result.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR Incident RESULT result.
*
*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR Incident RESULT result.
*
*    METHODS ChangeStatus FOR MODIFY
*      IMPORTING keys FOR ACTION Incident~ChangeStatus RESULT result.
*
*    METHODS setIncident FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR Incident~setIncident.
*
*    METHODS createInitialHistory FOR DETERMINE ON SAVE
*      IMPORTING keys FOR Incident~createInitialHistory.
*
*    METHODS validateDateFuture FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Incident~validateDateFuture.
*
*    METHODS validateDateRange FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Incident~validateDateRange.
*
*    METHODS validateDeleteIncident FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Incident~validateDeleteIncident.
*
*    METHODS validateStatusChange FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Incident~validateStatusChange.
*
*    METHODS validationIncident FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Incident~validationIncident.
*    METHODS validationStatus FOR VALIDATE ON SAVE
*      IMPORTING keys FOR Incident~validationStatus.
*
*
** probando de crear un metodo nuevo
*    METHODS get_next_incident_id
*      RETURNING VALUE(rv_incident_id) TYPE zdt_inct_sc-incident_id.
*
*ENDCLASS.
*
*CLASS lhc_Incident IMPLEMENTATION.
*
*  METHOD get_instance_features.
*
**  leer la entidad + datos
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*    FIELDS ( Status )
*      WITH CORRESPONDING #( keys )
*      RESULT DATA(incidents)            "recuperar todos los incidentes
*      FAILED failed.                     "posibles fallos se puede declarar una variable, aunque no es necesario en este caso porque tiene failed
*
*    result = VALUE #( FOR incident IN incidents ( %tky          = incident-%tky
*                                                  %field-Status = COND #( WHEN incident-Status = status_code-status_cn
*                                                                            OR incident-Status = status_code-status_co
*                                                                            OR incident-Status = status_code-status_cl
*                                                                          THEN if_abap_behv=>fc-f-read_only
*                                                                          ELSE if_abap_behv=>fc-f-unrestricted )
*
**                                                  %action-ChangeStatus = COND #( WHEN incident-Status = status_code-status_pe          "para hacer que algo (en este caso btn) se vea o no
**                                                                                 THEN if_abap_behv=>fc-o-disabled
**                                                                                 ELSE if_abap_behv=>fc-o-enabled )
*                                                   ) ).       "devolver tab interna con vlaor del estado
*
*  ENDMETHOD.
*
*  METHOD get_instance_authorizations.
*
*    DATA: update_requested TYPE abap_boolean,
*          update_granted   TYPE abap_boolean,
*          delete_requested TYPE abap_boolean,
*          delete_granted   TYPE abap_boolean.
*
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*    FIELDS ( Status )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(incidents)
*    FAILED failed.
*
**   determina si se solicito o no una operacion de actualizacion
*    update_requested = COND #( WHEN requested_authorizations-%update = if_abap_behv=>mk-on
*                                 OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
*                                 THEN abap_true
*                                 ELSE abap_false ).
*
**   determina si se solicito o no una operacion de eliminacion
*    delete_requested = COND #( WHEN requested_authorizations-%delete = if_abap_behv=>mk-on
*                                 OR requested_authorizations-%action-Edit = if_abap_behv=>mk-on
*                                 THEN abap_true
*                                 ELSE abap_false ).
*
*
**     si es verdadero seguir sino no continua
*    CHECK update_requested EQ abap_true.
*
*    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).
*    DATA user TYPE string VALUE 'CB9980007116'.
*
**   si se tiene el codigo de el campo al que se quiere bloquear el acceso
*    LOOP AT incidents INTO DATA(incident)
*    WHERE Status IS NOT INITIAL.
**      IF lv_technical_name EQ user AND incident-Status EQ status_code-status_op.
***        para validar de eliminacion y de edicion agregar datos una forma de unificar las 2 validaciones
**        update_granted = delete_granted = abap_true.
**
**      ELSE.
**        update_granted = delete_granted = abap_false.
**      ENDIF.
*
** solo si el status es OP se puede eliminar sino no
*      IF lv_technical_name EQ user AND incident-Status EQ status_code-status_op.
*        delete_granted = abap_true.
*        update_granted = abap_true.
*
*      ELSE.
*        delete_granted = abap_false.
*        update_granted = abap_true.
*      ENDIF.
**      IF lv_technical_name EQ user AND incident-Priority NE 'M'.
**        update_granted = abap_true.
*
**      ELSE.
**        update_granted = abap_false.
**      ENDIF.
*
**   agregar registros en el result  ----  indicar el registro para que el framework determine si permite o no el acceso a la operacion de actualizacion
*
*      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted EQ abap_true       "declarar una var dentro del mismo registro
*                                             THEN if_abap_behv=>auth-allowed        "tiene valor permitido o no
*                                             ELSE if_abap_behv=>auth-unauthorized
*                                             )
*                          del_auth = COND #( WHEN delete_granted EQ abap_true       "declarar una var dentro del mismo registro
*                                             THEN if_abap_behv=>auth-allowed        "tiene valor permitido o no
*                                             ELSE if_abap_behv=>auth-unauthorized
*                                             )
*                         IN %tky         = incident-%tky             " el let declarado arriba tiene que ir con un IN
*                            %update      = upd_auth
*                            %action-Edit = upd_auth
*                            %delete      = del_auth ) TO result.   "asignar al componente que se agrega en la tabla interna que se devuelve
*
**      APPEND VALUE #( LET upd_auth = COND #( WHEN update_granted EQ abap_true       "declarar una var dentro del mismo registro
**                                             THEN if_abap_behv=>auth-allowed        "tiene valor permitido o no
**                                             ELSE if_abap_behv=>auth-unauthorized
**                                             )
**                         IN %tky         = incident-%tky             " el let declarado arriba tiene que ir con un IN
**                            %update      = upd_auth
**                            %action-Edit = upd_auth
**                            %delete      = '' ) TO result.   "asignar al componente que se agrega en la tabla interna que se devuelve
**
*
*    ENDLOOP.
*
*
*
*
*
*
*
*  ENDMETHOD.
*
*  METHOD get_global_authorizations.
*
*    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).
*    DATA user TYPE string VALUE 'CB9980007116'.
*
**   permitir o no que x usuario pueda crear un nuevo incidente
*    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.  "Si se solicito la opreacion de creat - mk si se marco o no
*
**      IF  requested_authorizations-%create EQ user.    "si el usuario que solicito la accion es = a valor
*      IF  lv_technical_name EQ user.    "si el usuario que solicito la accion es = a valor
*
*        result-%create = if_abap_behv=>auth-unauthorized.  "asi mi usuario si puede crear
*
*      ELSE.
*        result-%create = if_abap_behv=>auth-allowed.
*      ENDIF.
*
*    ENDIF.
*
**  habilitar o no x btn para determinado usuario
*    IF requested_authorizations-%update EQ if_abap_behv=>mk-on OR
*     requested_authorizations-%action-Edit EQ if_abap_behv=>mk-on.
*
*      IF lv_technical_name EQ user.
**        result-%update = if_abap_behv=>auth-unauthorized.           " no tiene permisos
**        result-%action-Edit = if_abap_behv=>auth-unauthorized.
*        result-%update = if_abap_behv=>auth-allowed.
*        result-%action-Edit = if_abap_behv=>auth-allowed.
*      ELSE.
*        result-%update = if_abap_behv=>auth-unauthorized.
*        result-%action-Edit = if_abap_behv=>auth-unauthorized.
**        result-%update = if_abap_behv=>auth-allowed.
**        result-%action-Edit = if_abap_behv=>auth-allowed.
*
*      ENDIF.
*
*    ENDIF.
*
**   sacar la opcion de eliminar para determinados usuarios
*    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.
*      IF lv_technical_name EQ user.
*        result-%delete = if_abap_behv=>auth-allowed.
**        result-%delete = if_abap_behv=>auth-unauthorized.   " no se ve el delete
*      ELSE.
**        result-%delete = if_abap_behv=>auth-allowed.
*        result-%delete = if_abap_behv=>auth-unauthorized.
*      ENDIF.
*    ENDIF.
*
*
*  ENDMETHOD.
*
*  METHOD ChangeStatus.
*
**   siguiendo video
**DATA status_inc TYPE TABLE FOR UPDATE ZI_INCT_SC.
**
*** lectura de los datos
**    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
**    ENTITY Incident
**     FIELDS ( Status )
**      WITH CORRESPONDING #( keys )
**      RESULT DATA(incidents).
**
**
**      LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
**      DATA(status_inci) = keys[ KEY  id %tky = <incident>-%tky ]-%param-NewStatus.
**   APPEND VALUE #( %tky = <incident>-%tky
**                    )
**
**      ENDLOOP.
****************************************
*
******************CAMBIA EL ESTADO DE INCIDENTES NO DE HISTORIAL, NO SE VE EL TEXTO NOSE SI SIRVE***********************
*
** definir una tabla para tratar siempre los multiples registros que se pueden solicitar
*    DATA status_for_update TYPE TABLE FOR UPDATE zi_inct_sc.
*
*
**status_for_update[ 1 ]
** lectura de datos para recuperar la informacion que se quiere modificar
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*    FIELDS ( Status )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(incidents).
*
** prueba de video
**    DATA status_prob TYPE zdt_status_sc-status_code.
*
*    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
*      DATA(new_status) = keys[ KEY id %tky = <incident>-%tky ]-%param-NewStatus.
**      DATA(new_text_status) = keys[ KEY id %tky = <incident>-%tky ]-%param-Observation.
*
*      APPEND VALUE #( %tky   = <incident>-%tky
*                      status = new_status
*                     ) TO status_for_update.
*
*    ENDLOOP.
*
*    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*    UPDATE FIELDS ( Status )
*    WITH status_for_update.
*
*
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(inc_status).
*
*    result = VALUE #( FOR incident IN inc_status ( %tky  = incident-%tky
*                                                   %param = incident ) ).
*
******************CAMBIA EL ESTADO DE INCIDENTES NO DE HISTORIAL, NO SE VE EL TEXTO NOSE SI SIRVE***********************
*
*
*
*
**    MODIFY ENTITIES OF zi_inct_sc  IN LOCAL MODE
**      ENTITY Incident
**      UPDATE FROM VALUE #( FOR key IN keys (
**                                            %tky = key-%tky
**                                            Status = key-%param-NewStatus ) ).
*
*  ENDMETHOD.
*
*  METHOD setIncident.
*
***  lectura dentro de un read entity
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*    ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(incidents).
*
** obteniendo el siguiente ID
*    DATA(lv_max_id) = get_next_incident_id(  ).
*
**      modificacion
**   siempre es el mismo punto de ingreso, el BDEF la definicion que hice anteriormente
*    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident
*    UPDATE FIELDS ( IncidentId Status CreationDate ChangedDate )
*    "datos registros que se verian afectados for -> declarar una estructura para navegar o iterar o indicar lo que seria la declaracion de una variable que seria una estructura
*    WITH VALUE #( FOR key IN keys INDEX INTO i ( %tky            = key-%tky
*                                                 IncidentId      = lv_max_id + i - 1
*                                                 Status          = status_code-status_op
*                                                 CreationDate    = cl_abap_context_info=>get_system_date(  )
*                                                 ChangedDate     = cl_abap_context_info=>get_system_date(  )
*                                                 ) ).    "maneja la clave tecnica->necesita la clave tencica para identificar los registros afectados
*
**   PONER LOGICA PARA QUE CAMPO FECHA MOD NO SE PUEDA MODIFICAR
*
*
*  ENDMETHOD.
*
*  METHOD createInitialHistory.
*
*    DATA lv_text_ini TYPE string VALUE 'First Incident'.
*
*    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
*    ENTITY Incident CREATE BY \_Historial
*    FROM VALUE #( FOR key IN keys INDEX INTO i ( %tky    = key-%tky
*                                                 %target = VALUE #( ( %cid      = |ID_{ i }|
*                                                                      NewStatus = status_code-status_op
*                                                                      Text      = lv_text_ini
*                                                                      %control  = VALUE #( NewStatus = if_abap_behv=>mk-on
*                                                                                           Text      = if_abap_behv=>mk-on
*                                                                                         )
*                                                                    ) )
*                                               ) ).
*  ENDMETHOD.
*
*  METHOD validateDateFuture.
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*        ENTITY Incident
*        FIELDS ( CreationDate ChangedDate )
*        WITH CORRESPONDING #( keys )
*        RESULT DATA(incidents).
*
*    DATA(lv_fecha_mod) = cl_abap_context_info=>get_system_date(  ).
*
*    LOOP AT incidents INTO DATA(incident).
*
*      IF incident-ChangedDate >= lv_fecha_mod.
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*
*      ENDIF.
*      IF incident-CreationDate >= lv_fecha_mod.
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*
*      ENDIF.
*
*    ENDLOOP.
*
*  ENDMETHOD.
*
*  METHOD validateDateRange.
*
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*        ENTITY Incident
*        FIELDS ( CreationDate ChangedDate )
*        WITH CORRESPONDING #( keys )
*        RESULT DATA(incidents).
*
*    LOOP AT incidents INTO DATA(incident).
**      IF incident-CreationDate IS INITIAL. " si es inicial bloquear el estado transaccional
***  sobre el registro con la clave tecnica en el que aplica el bloqueo del estado transaccional
**        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
**      ENDIF.
**      IF incident-ChangedDate IS INITIAL.
**        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
**      ENDIF.
*
***  si la fecha de creacion es menor a la fecha actual
**      IF incident-CreationDate EQ cl_abap_context_info=>get_system_date(  ) AND incident-CreationDate IS NOT INITIAL.
**
**        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
**
**      ENDIF.
*
*      IF  incident-ChangedDate <=  incident-CreationDate.
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*
*      ENDIF.
*      IF  incident-ChangedDate >= cl_abap_context_info=>get_system_date(  ).
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*
*      ENDIF.
**      IF  incident-ChangedDate < incident-CreationDate AND incident-ChangedDate IS NOT INITIAL
**                                                       AND incident-CreationDate IS NOT INITIAL.
**        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
**      ELSEIF incident-ChangedDate > cl_abap_context_info=>get_system_date(  ).
**        incident-ChangedDate = cl_abap_context_info=>get_system_date(  ).
**      ELSE.
**        incident-ChangedDate = cl_abap_context_info=>get_system_date(  ).
**
**      ENDIF.
*
*
**      IF incident-ChangedDate <= incident-CreationDate AND incident-CreationDate IS NOT INITIAL
**                                                      AND incident-ChangedDate IS NOT INITIAL.
**
**        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
**      ENDIF.
*
*    ENDLOOP.
*  ENDMETHOD.
*
*  METHOD validateDeleteIncident.
*  ENDMETHOD.
*
*  METHOD validateStatusChange.
*  ENDMETHOD.
*
*  METHOD validationIncident.
*  ENDMETHOD.
*
*  METHOD get_next_incident_id.
*    SELECT SINGLE MAX( incident_id )
*    FROM zdt_inct_sc
**     FIELDS incident_id
*    INTO @DATA(lv_max_id).
*
*    rv_incident_id = lv_max_id + 1.
*
*  ENDMETHOD.
*
*  METHOD validationStatus.
*
*    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
*       ENTITY Incident
*       FIELDS ( Status )
*       WITH CORRESPONDING #( keys )
*       RESULT DATA(incidents).
*
*    DATA status TYPE SORTED TABLE OF zdt_status_sc WITH UNIQUE KEY client status_code.
*
** transportar el status de la tabla a la que defini recien
*    status = CORRESPONDING #( incidents DISCARDING DUPLICATES MAPPING status_code = Status EXCEPT * ).      "con except* se indica que no importan las otras columnas
*
**    eliminar los registros que tengan el dato vacios
*    DELETE status WHERE status_code IS INITIAL.
*
** comprobar clientes de la tabla con los clientes la tabla interna que declare recien
*    IF status IS NOT INITIAL.
*      SELECT FROM zdt_status_sc AS ddbb
*      INNER JOIN @incidents AS http_req ON ddbb~status_code EQ http_req~Status
*      FIELDS ddbb~status_code
*      INTO TABLE @DATA(valid_status).
*    ENDIF.
*
*    LOOP AT incidents INTO DATA(incident).
*      IF incident-Status IS INITIAL.
*
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*
*      ELSEIF incident-Status IS NOT INITIAL AND NOT line_exists( valid_status[ status_code = incident-Status ]  ).  "si me pasaste un valor, y este valor no existe en la tabla de los status validos tambien tengo error
*
*        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
*      ENDIF.
*    ENDLOOP.
*
*
*  ENDMETHOD.
*
*ENDCLASS.
