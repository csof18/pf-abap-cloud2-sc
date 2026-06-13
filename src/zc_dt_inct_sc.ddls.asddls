@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection - Incidents'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@AbapCatalog.extensibility: { extensible: true,
                              dataSources: [ 'Incident' ],
                              elementSuffix: 'ZAG',
                              allowNewDatasources: false,
                              allowNewCompositions: true,
                              quota: { maximumFields: 500,
                                       maximumBytes: 5000
                                     }
                             }

define root view entity ZC_DT_INCT_SC
  provider contract transactional_query
  as projection on ZI_INCT_SC as Incident
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
      @Consumption.filter.hidden: true
      LocalCreatedBy,

      @Search.ranking: #LOW
      @Semantics.systemDateTime.createdAt: true
      @Consumption.filter.hidden: true
      LocalCreatedAt,

      @Search.ranking: #LOW
      @Semantics.user.localInstanceLastChangedBy: true
      @Consumption.filter.hidden: true
      LocalLastChangedBy,

      @Search.ranking: #LOW
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      @Consumption.filter.hidden: true
      LocalLastChangedAt,

      @Search.ranking: #LOW
      @Semantics.systemDateTime.lastChangedAt: true
      @Consumption.filter.hidden: true
      LastChangedAt,

      _Status.StatusDesc     as StatusText,
      _Priority.PriorityDesc as PriorityText,

      /*Composition*/
      _Historial : redirected to composition child ZC_DT_INCT_H_SC,

      /* Associations */
      _Priority,
      _Status
}
