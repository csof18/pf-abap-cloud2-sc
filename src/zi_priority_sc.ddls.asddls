@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Priority'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PRIORITY_SC as select from zdt_priority_sc as Priority
{
      key priority_code as PriorityCode,
  priority_description as PriorityDesc
}
