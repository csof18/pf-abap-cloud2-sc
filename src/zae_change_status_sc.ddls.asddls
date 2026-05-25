@EndUserText.label: 'Abstract entity change status'

@ObjectModel.resultSet.sizeCategory: #XS
define abstract entity ZAE_CHANGE_STATUS_SC
  //  with parameters parameter_name : parameter_type
{
      @ObjectModel.text.element: [ 'Observation' ]
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_STATUS_SC',     //averiguar que valor iria aca
                                                 element: 'StatusCode' },
                                       useForValidation: true }]
  NewStatus   : zde_status_sc;
  Observation : zde_text;
}
