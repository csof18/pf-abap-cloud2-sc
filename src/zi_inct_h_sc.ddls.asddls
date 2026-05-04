@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Info del historial de los incidentes'
@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.usageType:{ serviceQuality: #B,
                         sizeCategory: #S,
                         dataClass: #MIXED
                        }
                        
 @ObjectModel.semanticKey: [ 'HisId' ]  
define view entity ZI_INCT_H_SC
  as select from zdt_inct_h_sc as IncidentHis
  association to parent ZI_INCT_SC as _Incident on _Incident.IncUuid = $projection.IncUuid
{
  key IncidentHis.inc_uuid              as IncUuid,
  key IncidentHis.his_uuid              as HisUuid,
      IncidentHis.his_id                as HisId,
      IncidentHis.previous_status       as PreviousStatus,
      IncidentHis.new_status            as NewStatus,
      IncidentHis.text                  as Text,
      IncidentHis.local_created_by      as LocalCreatedBy,
      IncidentHis.local_created_at      as LocalCreatedAt,
      IncidentHis.local_last_changed_by as LocalLastChangedBy,
      IncidentHis.local_last_changed_at as LocalLastChangedAt,
      IncidentHis.last_changed_at       as LastChangedAt,
     _Incident

}
