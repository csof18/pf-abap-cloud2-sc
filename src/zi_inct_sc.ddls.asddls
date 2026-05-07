@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Info basica de incidentes'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.semanticKey: [ 'IncidentId' ]
//@ObjectModel.usageType:{ serviceQuality: #B,
//                         sizeCategory: #S,
//                         dataClass: #MIXED
//                        }

define root view entity ZI_INCT_SC
  as select from zdt_inct_sc as Incident
 
  composition [0..*] of ZI_INCT_H_SC    as _Historial
 
  association [1..1] to zdt_status_sc   as _Status   on _Status.status_code = $projection.Status
  association [1..1] to zdt_priority_sc as _Priority on _Priority.priority_code = $projection.Priority
{
  key inc_uuid                       as IncUuid,
      Incident.status                as Status,
      Incident.priority              as Priority,
      Incident.incident_id           as IncidentId,
      Incident.title                 as Title,
      Incident.description           as Description,
      Incident.creation_date         as CreationDate,
      Incident.changed_date          as ChangedDate,
      Incident.local_created_by      as LocalCreatedBy,
      Incident.local_created_at      as LocalCreatedAt,
      Incident.local_last_changed_by as LocalLastChangedBy,
      Incident.local_last_changed_at as LocalLastChangedAt,
      Incident.last_changed_at       as LastChangedAt,
      _Historial,
      _Status,
      _Priority
}
