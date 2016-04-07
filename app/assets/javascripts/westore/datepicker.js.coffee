$ ->
  $('.datepicker').pickadate
    format: 'yyyy-mm-dd'
    formatSubmit: 'yyyy-mm-dd'
    min: new Date
    hiddenPrefix: ''
    hiddenSuffix: ''

  $('.timepicker').pickatime
    format: 'H:i'
    min: [7, 0]
    max: [22, 0]
