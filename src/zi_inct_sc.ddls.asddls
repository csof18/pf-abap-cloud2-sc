@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Info basica de incidentes'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.semanticKey: [ 'IncidentId' ]
@AbapCatalog.extensibility: { extensible: true,
                              dataSources: [ 'Incident' ],
                              elementSuffix: 'ZAG',
                              allowNewDatasources: false,
                              quota: { maximumFields: 500,
                                        maximumBytes: 50000 },
                              allowNewCompositions: true
                             }
define root view entity ZI_INCT_SC
  as select from zdt_inct_sc as Incident

  composition [0..*] of ZI_INCT_H_SC   as _Historial

  association [1..1] to ZI_STATUS_SC   as _Status   on _Status.StatusCode = $projection.Status
  association [1..1] to ZI_PRIORITY_SC as _Priority on _Priority.PriorityCode = $projection.Priority
{
  key inc_uuid                       as IncUuid,
      Incident.status                as Status,
      Incident.priority              as Priority,
      Incident.incident_id           as IncidentId,
      Incident.title                 as Title,
      Incident.description           as Description,
      Incident.creation_date         as CreationDate,
      Incident.changed_date          as ChangedDate,
      @Semantics.user.createdBy: true
      Incident.local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      Incident.local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      Incident.local_last_changed_by as LocalLastChangedBy,
      //      local ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      Incident.local_last_changed_at as LocalLastChangedAt,
      //      total ETag
      @Semantics.systemDateTime.lastChangedAt: true
      Incident.last_changed_at       as LastChangedAt,
      _Historial,
      _Status,
      _Priority
}
