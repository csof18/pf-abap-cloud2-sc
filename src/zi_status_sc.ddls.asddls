@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS -Status'
@Metadata.ignorePropagatedAnnotations: true
@AbapCatalog.extensibility: { extensible: true,
                              elementSuffix: 'ZAG',
                              allowNewDatasources: false,
                              dataSources: [ 'Status' ],
                              quota: { maximumFields: 500,
                                       maximumBytes: 5000
                                     }
                             }
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_STATUS_SC
  as select from zdt_status_sc as Status
{
      @ObjectModel.text.element: [ 'StatusDesc' ]
  key status_code        as StatusCode,
      status_description as StatusDesc
}
