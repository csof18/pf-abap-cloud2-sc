@EndUserText.label: 'Abstract entity change status'

@ObjectModel.resultSet.sizeCategory: #XS
define abstract entity ZAE_CHANGE_STATUS_SC
{
  @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_STATUS_SC',
                                                   element: 'StatusCode' },
                                       useForValidation: true }]
  @EndUserText.label: 'Status'
  NewStatus   : zde_status_sc;

  @EndUserText.label: 'Observation'
  Observation : zde_text;

  @EndUserText.label: 'Responsible'
  Responsible : zde_responsable_sc;
}
