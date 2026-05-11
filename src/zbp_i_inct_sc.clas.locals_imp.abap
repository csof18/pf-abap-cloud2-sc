CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

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

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD ChangeStatus.
  ENDMETHOD.

  METHOD setIncident.
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

ENDCLASS.
