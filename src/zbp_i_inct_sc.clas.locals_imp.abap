CLASS lhc_incidenthis DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR IncidentHis RESULT result.

ENDCLASS.

CLASS lhc_incidenthis IMPLEMENTATION.

  METHOD get_instance_features.

    result = VALUE #( FOR key IN keys ( %tky          = key-%tky
                                        %update       = if_abap_behv=>fc-o-disabled
                                        %delete       = if_abap_behv=>fc-o-disabled
                                       ) ).

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

    METHODS validationIncident FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validationIncident.

    METHODS validationStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validationStatus.

    METHODS validationPriorityCode FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validationPriorityCode.
    METHODS validateResponsible FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateResponsible.

    METHODS get_next_incident_id
      RETURNING VALUE(rv_incident_id) TYPE zdt_inct_sc-incident_id.

    METHODS get_next_history_id
      RETURNING VALUE(rv_history_id) TYPE zdt_inct_h_sc-his_id.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(incidents)
      FAILED failed.

*   configuracion comportamiento dinamico por instancia
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
                                                 ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.

*   usuario logeado
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

    DATA(lv_auth) = COND abp_behv_auth(  WHEN lv_user IS NOT INITIAL
                                         THEN if_abap_behv=>auth-allowed
                                         ELSE if_abap_behv=>auth-unauthorized ).


*   crear incidente -> permitir o no que x usuario pueda crear un nuevo incidente
    IF requested_authorizations-%create EQ if_abap_behv=>mk-on.
      result-%create = lv_auth.
    ENDIF.

    IF requested_authorizations-%update EQ if_abap_behv=>mk-on .
      result-%update = lv_auth.
    ENDIF.

    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.
      result-%delete = lv_auth.
    ENDIF.

  ENDMETHOD.

  METHOD ChangeStatus.

    DATA: status_for_update TYPE TABLE FOR UPDATE zi_inct_sc,
          history_to_create TYPE TABLE FOR CREATE zi_inct_sc\_Historial,
          lv_error          TYPE abap_boolean.

*  validar param obligatorios
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<keys>)
    WHERE %param-NewStatus IS INITIAL
    OR %param-Observation IS INITIAL.
      lv_error = abap_true.
      APPEND VALUE #( %tky = <keys>-%tky ) TO failed-incident.

      APPEND VALUE #( %tky = <keys>-%tky
                      %msg = new_message_with_text(
                             severity = if_abap_behv_message=>severity-error
                             text = 'Campos Nuevo Estado y Observación incompletos' )
                             %element-Status = if_abap_behv=>mk-on
                    ) TO reported-incident.
    ENDLOOP.

    CHECK lv_error NE abap_true.

* leer incidente actual
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    FIELDS ( Status ChangedDate zzresponzag )
    WITH CORRESPONDING #( keys )
    RESULT DATA(incidents).

    DATA(lv_next_his_id) = get_next_history_id(  ).



*    validacion  y preparar cambios
    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).

      DATA(ls_key) = VALUE #( keys[ KEY id
                                    %tky = <incident>-%tky ] OPTIONAL ).
      CHECK ls_key IS NOT INITIAL.

      DATA(new_status)      = ls_key-%param-NewStatus.
      DATA(new_text_status) = ls_key-%param-Observation.
      DATA(new_responsible) = ls_key-%param-Responsible.
      DATA(lv_current_user) = cl_abap_context_info=>get_user_technical_name( ).

      DATA(lv_responsible) = COND #( WHEN new_responsible IS NOT INITIAL
                                     THEN new_responsible
                                     ELSE <incident>-zzresponzag ).

      IF <incident>-zzresponzag EQ lv_current_user.
*        IF <incident>-zzresponzag NE lv_current_user.      "para probas mas facil deberia ir asi
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'Solo el responsable o Administrador puede cambiar el estado' )
                        %element-Status = if_abap_behv=>mk-on
                        %element-zzresponzag = if_abap_behv=>mk-on
                      ) TO reported-incident.
        CONTINUE.
      ENDIF.

      IF new_status = status_code-status_ip
      AND lv_responsible IS INITIAL.
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text = 'Debe asignar un responsable' )
                               %element-zzresponzag = if_abap_behv=>mk-on
                      ) TO reported-incident.
        CONTINUE.
      ENDIF.

*   validar cambios de estado
      IF <incident>-Status   = status_code-status_cn
        OR <incident>-Status = status_code-status_co
        OR <incident>-Status = status_code-status_cl.

        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                               severity        = if_abap_behv_message=>severity-error
                               text            = 'No se puede cambiar el estado del incidente' )
                               %element-Status = if_abap_behv=>mk-on  "PROBAR - ANDA??
                      ) TO reported-incident.

        CONTINUE.
      ENDIF.

*    PE no puede ir a  CL ni CO
      IF <incident>-Status = status_code-status_pe AND ( new_status = status_code-status_co
                                                    OR   new_status = status_code-status_cl ) .

        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text = 'Un incidente Pending no puede ser Completed o Closed' )
                               %element-Status = if_abap_behv=>mk-on  "PROBAR - ANDA??
                      ) TO reported-incident.
        CONTINUE.
      ENDIF.


*   estado igual al actual
      IF <incident>-Status = new_status.
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = new_message_with_text(
                               severity = if_abap_behv_message=>severity-error
                               text = 'El nuevo estado debe ser diferente al actual' )
                               %element-Status = if_abap_behv=>mk-on
                      ) TO reported-incident.


        CONTINUE.

      ENDIF.

*      preparar update status del incidente
      APPEND VALUE #( %tky   = <incident>-%tky
                      status = new_status
                      ChangedDate = cl_abap_context_info=>get_system_date(  )
                      zzresponzag = lv_responsible
                     ) TO status_for_update.

*     preparar creacion del historial
      DATA(lv_idx) = sy-tabix.
      APPEND VALUE #( %tky = <incident>-%tky
                      %target = VALUE #( ( %cid = |HIS_{ lv_idx }|
                      HisId          = lv_next_his_id + lv_idx - 1
                      PreviousStatus = <incident>-Status
                      NewStatus      = new_status
                      Text           = new_text_status
                      %control       = VALUE #(  HisId           = if_abap_behv=>mk-on
                                                  PreviousStatus  = if_abap_behv=>mk-on
                                                  NewStatus       = if_abap_behv=>mk-on
                                                  Text            = if_abap_behv=>mk-on
                                                 )
                                             ) )
                     ) TO history_to_create.

    ENDLOOP.

*    Actualizar cambios solo si hay registros validos
    IF status_for_update IS NOT INITIAL.
      MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
      ENTITY Incident
      UPDATE FIELDS ( Status ChangedDate zzresponzag )
      WITH status_for_update.

    ENDIF.

*   crear historial
    IF history_to_create IS NOT INITIAL.
      MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
      ENTITY Incident
      CREATE BY \_Historial
      FROM history_to_create.
    ENDIF.

*   devolver resultados
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(inc_result).

    result = VALUE #( FOR incident IN inc_result ( %tky  = incident-%tky
                                                   %param = incident ) ).

  ENDMETHOD.

  METHOD setIncident.

*  lectura dentro de un read entity
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(incidents).

* obteniendo el siguiente ID
    DATA(lv_max_id) = get_next_incident_id(  ).

*      modificacion
    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident
    UPDATE FIELDS ( IncidentId Status CreationDate ChangedDate )
    WITH VALUE #( FOR key IN keys INDEX INTO i ( %tky            = key-%tky
                                                 IncidentId      = lv_max_id + i - 1
                                                 Status          = status_code-status_op
                                                 CreationDate    = cl_abap_context_info=>get_system_date(  )
                                                 ChangedDate     = cl_abap_context_info=>get_system_date(  )
                                                 ) ).    "maneja la clave tecnica->necesita la clave tencica para identificar los registros afectados

  ENDMETHOD.

  METHOD createInitialHistory.

    DATA lv_text_ini TYPE string VALUE 'First Incident'.
    DATA(lv_next_his_id) = get_next_history_id(  ).

    MODIFY ENTITIES OF zi_inct_sc IN LOCAL MODE
    ENTITY Incident CREATE BY \_Historial
    FROM VALUE #( FOR key IN keys INDEX INTO i ( %tky    = key-%tky
                                                 %target = VALUE #( ( %cid           = |ID_{ i }|
                                                                      HisId          = lv_next_his_id + i - 1
                                                                      PreviousStatus = ''
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
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
        ENTITY Incident
        FIELDS ( ChangedDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(incidents).

    LOOP AT incidents INTO DATA(incidente).
      IF incidente-ChangedDate GT cl_abap_context_info=>get_system_date(  ).

        APPEND VALUE #( %tky = incidente-%tky ) TO failed-incident.

        APPEND VALUE #( %tky = incidente-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'Fecha de modificacion futura' )
                         %element-ChangedDate = if_abap_behv=>mk-on
                            ) TO reported-incident.
      ENDIF.
    ENDLOOP.

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
                                                       text    = |No se puede eliminar { incidente-IncidentId } solo si tiene estado Open | )
                        %element-Status = if_abap_behv=>mk-on ) TO reported-incident.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD validationIncident.
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
       ENTITY Incident
       FIELDS ( Title Description zzresponzag )
       WITH CORRESPONDING #( keys )
       RESULT DATA(incidents).

    LOOP AT incidents INTO DATA(incident).
      IF incident-Title IS INITIAL.
        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = incident-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'El campo Title es obligatorio' )
                        %element-Title = if_abap_behv=>mk-on
                      ) TO reported-incident.
      ENDIF.

      IF incident-Description IS INITIAL.
        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = incident-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'El campo Description es obligatorio' )
                        %element-Description = if_abap_behv=>mk-on
                      ) TO reported-incident.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validationStatus.

    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
       ENTITY Incident
       FIELDS ( Status )
       WITH CORRESPONDING #( keys )
       RESULT DATA(incidents).

    DATA status TYPE SORTED TABLE OF zdt_status_sc WITH UNIQUE KEY client status_code.

*   transportar el status de la tabla
    status = CORRESPONDING #( incidents DISCARDING DUPLICATES MAPPING status_code = Status EXCEPT * ).

*    eliminar los registros que tengan el dato vacios
    DELETE status WHERE status_code IS INITIAL.

*   comprobar clientes de la tabla con los clientes la tabla interna declarada
    IF status IS NOT INITIAL.
      SELECT FROM zdt_status_sc AS ddbb
      INNER JOIN @status AS http_req ON ddbb~status_code EQ http_req~status_code
      FIELDS ddbb~status_code
      INTO TABLE @DATA(valid_status).
    ENDIF.

    LOOP AT incidents INTO DATA(incident).
      IF incident-Status IS INITIAL.

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = incident-%tky
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'El campo Status es obligatorio' )
                        %element-Status = if_abap_behv=>mk-on
                      ) TO reported-incident.
*      si el valor no es valido
      ELSEIF incident-Status IS NOT INITIAL AND NOT line_exists( valid_status[ status_code = incident-Status ]  ).

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = incident-%tky
                       %msg = new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text     = 'El valor de Status no es válido' )
                       %element-Status = if_abap_behv=>mk-on
                     ) TO reported-incident.
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

    priority = CORRESPONDING #( incidents DISCARDING DUPLICATES MAPPING priority_code = Priority EXCEPT * ).      "con except* se indica que no importan las otras columnas

*   eliminar los registros que tengan el dato vacios
    DELETE priority WHERE priority_code IS INITIAL.

*   comprobar clientes de la tabla con los clientes la tabla interna
    IF priority IS NOT INITIAL.
      SELECT FROM zdt_priority_sc AS ddbb
      INNER JOIN @priority AS http_req ON ddbb~priority_code EQ http_req~priority_code
      FIELDS ddbb~priority_code
      INTO TABLE @DATA(valid_priority).
    ENDIF.

    LOOP AT incidents INTO DATA(incident).
      IF incident-Priority IS INITIAL.

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.
        APPEND VALUE #( %tky = incident-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text = 'El campo Priority es obligatorio' )
                        %element-Priority = if_abap_behv=>mk-on
                      ) TO reported-incident.

*   si el dato es equivocado
      ELSEIF NOT line_exists( valid_priority[ priority_code = incident-Priority ]  ).
        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.

        APPEND VALUE #( %tky = incident-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text = 'El valor de Priority no es válido' )
                        %element-Priority = if_abap_behv=>mk-on
                      ) TO reported-incident.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateResponsible.
    READ ENTITIES OF zi_inct_sc IN LOCAL MODE
      ENTITY Incident
      FIELDS ( IncUuid Status zzresponzag )
      WITH CORRESPONDING #( keys )
      RESULT DATA(incidents).

    IF incidents IS INITIAL.
      RETURN.
    ENDIF.

*   valores persistidos anteriores
    SELECT FROM zdt_inct_sc
      FIELDS inc_uuid,
             status,
             zzresponzag
      FOR ALL ENTRIES IN @incidents
      WHERE inc_uuid = @incidents-IncUuid
      INTO TABLE @DATA(persisted_incidents).

    LOOP AT incidents INTO DATA(incident).

      DATA(persisted_incident) =
        VALUE #( persisted_incidents[
          inc_uuid = incident-IncUuid
        ] OPTIONAL ).


      IF persisted_incident IS INITIAL.

        IF incident-zzresponzag IS NOT INITIAL
        AND incident-Status NE status_code-status_ip.
          APPEND VALUE #(
            %tky = incident-%tky
          ) TO failed-incident.

          APPEND VALUE #(
            %tky = incident-%tky
            %element-zzresponzag = if_abap_behv=>mk-on
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = 'No es posible cambiar el responsable'
            )
          ) TO reported-incident.
        ENDIF.

        CONTINUE.
      ENDIF.

*      Si Responsible no cambio, sigue
      IF incident-zzresponzag = persisted_incident-zzresponzag.
        CONTINUE.
      ENDIF.

*      Solo cambiar Responsible cuando Status = IP
      IF incident-Status <> status_code-status_ip.

        APPEND VALUE #(
          %tky = incident-%tky
        ) TO failed-incident.

        APPEND VALUE #(
          %tky = incident-%tky
          %element-zzresponzag = if_abap_behv=>mk-on
          %msg = new_message_with_text(
            severity = if_abap_behv_message=>severity-error
            text     = 'El responsable solo puede modificarse al cambiar el estado a In Progress'
          )
        ) TO reported-incident.

      ENDIF.

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


ENDCLASS.
