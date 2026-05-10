@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - history'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_DT_INCT_H_SC
  as projection on ZI_INCT_H_SC
{
  key IncUuid,
  key HisUuid,
      HisId,
      PreviousStatus,
      NewStatus,
      @Search.defaultSearchElement: true
      Text,
      @Semantics.user.createdBy: true
      LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      /* Associations */
      _Incident : redirected to parent ZC_DT_INCT_SC
}
