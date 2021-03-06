angular
  .module 'enapparte'
  .directive 'inputSelectDate', ->
    link: (scope, element, attr) ->      
      $(element).datetimepicker
        format: "DD/MM/YYYY"
        locale: 'fr'
        defaultDate: new Date()
        minDate: new Date(new Date().getTime() - 23 * 60 * 60 * 1000)
        enabledDates: scope.performersAvailDates
        allowInputToggle: true

      ele = $(element).find('input')
      $(element).on "dp.change", ->
        ele.trigger('input')

  .directive 'inputSelectStartDate', ->
    link: (scope, element, attr) ->
      $(element).datetimepicker
        format: "DD/MM/YYYY"
        locale: 'fr'
        defaultDate: new Date()

      $(element).on "dp.change", ->
        $(element).find('input').trigger('input')

      scope.$watch 'startDate', (newValue)->
        if scope.startDate
          $("#endDate").data('DateTimePicker').minDate(newValue)
