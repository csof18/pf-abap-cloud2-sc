@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS - Priority'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS

define view entity ZI_PRIORITY_SC
  as select from zdt_priority_sc as Priority
{
      @ObjectModel.text.element: [ 'PriorityDesc' ]
  key priority_code        as PriorityCode,
      priority_description as PriorityDesc
}
