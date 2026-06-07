//@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Incidents'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true


define root view entity ZC_DT_INCT_SC
  provider contract transactional_query
  //provider contract transactional_interface
  as projection on ZI_INCT_SC
{
      @Search.ranking: #HIGH
  key IncUuid,
      @ObjectModel.text.element: [ 'StatusText' ]
      Status,

      @ObjectModel.text.element: [ 'PriorityText' ]
      Priority,

      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.8
      @Search.defaultSearchElement: true
      IncidentId,

      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.8
      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      Title,

      @Search.ranking: #MEDIUM
      @Search.fuzzinessThreshold: 0.7
      @Consumption.filter.hidden: true
      @Search.defaultSearchElement: true
      Description,

      @Search.ranking: #LOW
      @Search.fuzzinessThreshold: 0.8
      @EndUserText.label: 'Creation Date'
      @Search.defaultSearchElement: true
      CreationDate,

      @Search.ranking: #LOW
      @Search.fuzzinessThreshold: 0.8
      @EndUserText.label: 'Changed Date'
      @Search.defaultSearchElement: true
      ChangedDate,

      @Search.ranking: #LOW
      @Semantics.user.createdBy: true
      LocalCreatedBy,

      @Search.ranking: #LOW
      @Semantics.systemDateTime.createdAt: true
      LocalCreatedAt,

      @Search.ranking: #LOW
      @Semantics.user.localInstanceLastChangedBy: true
      LocalLastChangedBy,

      @Search.ranking: #LOW
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      @Search.ranking: #LOW
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,

      _Status.StatusDesc     as StatusText,
      _Priority.PriorityDesc as PriorityText,

      /*Composition*/
      _Historial : redirected to composition child ZC_DT_INCT_H_SC,

      /* Associations */
      _Priority,
      _Status
}
