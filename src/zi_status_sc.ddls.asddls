@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS -Status'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_STATUS_SC as select from zdt_status_sc as Status
{
      key status_code as StatusCode,
  status_description as StatusDesc
}
