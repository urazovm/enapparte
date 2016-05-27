class DashboardCalendarController extends @NGController
  @register window.App, 'DashboardCalendarController'

  @$inject: [
    '$scope'
    '$http'
    '$element'
    '$rootScope'
    'Flash'
    '$state'
    'User_availabilities'
    '$stateParams'
  ]

  shows = []
  showId = ""
  events = []

  init: ->
    @User_availabilities
      .query()
      .then (user_availabilities)=>
        @scope.user_availabilities = user_availabilities
        @daysCountInMonth()
        @setWeekdayValue()

  countDayInMonth = (weekday) ->
    d = new Date
    month = d.getMonth()
    d.setDate 1
    weekdays = []
    while d.getDay() != weekday
      d.setDate d.getDate() + 1
    while d.getMonth() == month
      weekdays.push new Date(d.getTime())
      d.setDate d.getDate() + 7
    weekdays.length

  daysCountInMonth: ()=>
    @scope.daysInMonth = {}
    @scope.daysInMonth.sun = countDayInMonth(0)
    @scope.daysInMonth.mon = countDayInMonth(1)
    @scope.daysInMonth.tue = countDayInMonth(2)
    @scope.daysInMonth.wed = countDayInMonth(3)
    @scope.daysInMonth.thu = countDayInMonth(4)
    @scope.daysInMonth.fri = countDayInMonth(5)
    @scope.daysInMonth.sat = countDayInMonth(6)
    console.log @scope.daysInMonth

  checkAllDaySet: (dayName)=>
    if @scope.daysInMonth[dayName] == @scope.dayCount[dayName]
      true
    else
      false

  setWeekdayValue: ()=>
    i = 0
    @scope.dayCount = {sun: 0, mon: 0, tue: 0, wed: 0, thu: 0, fri: 0, sat: 0}
    while i < @scope.user_availabilities.length
      dateE = new Date(@scope.user_availabilities[i].start)
      console.log "user_availabilitie #{@scope.user_availabilities[i].start}"
      switch dateE.getDay()
        when 0 then  @scope.dayCount.sun++
        when 1 then  @scope.dayCount.mon++
        when 2 then  @scope.dayCount.tue++
        when 3 then  @scope.dayCount.wed++
        when 4 then  @scope.dayCount.thu++
        when 5 then  @scope.dayCount.fri++
        when 6 then  @scope.dayCount.sat++
      i++

    @scope.allDaySelected = {}
    @scope.allDaySelected.sun = @checkAllDaySet('sun')
    @scope.allDaySelected.mon = @checkAllDaySet('mon')
    @scope.allDaySelected.tue = @checkAllDaySet('tue')
    @scope.allDaySelected.wed = @checkAllDaySet('wed')
    @scope.allDaySelected.thu = @checkAllDaySet('thu')
    @scope.allDaySelected.fri = @checkAllDaySet('fri')
    @scope.allDaySelected.sat = @checkAllDaySet('sat')


  checkForMatch = (array, propertyToMatch, valueToMatch) ->
    i = 0
    while i < array.length
      if array[i][propertyToMatch] == valueToMatch
        return true
      i++
    false


  insert_available_date: ()=>
    availability = {available_at:@scope.available_at}
    scope = @scope
    @http(
        method: 'POST'
        url: '/api/v1/availabilities.json'
        data: {availability:availability}).then ((response) ->
          event = response
          scope.event_param = event
          if !checkForMatch(scope.user_availabilities, 'id', response.data.id)
            scope.user_availabilities.push response.data
          scope.setWeekdayValue()
          scope.$broadcast 'insert_success', event
          console.log "insert success controller"
          return
      ), (response) ->
          console.log 'insert error:'+response['status']
          return

  delete_available_date: ()=>
    id = @scope.id
    scope = @scope
    @http(
        method: 'DELETE'
        url: '/api/v1/availabilities/' + @scope.id + '.json'
        ).then ((response) ->
          scope.id = id
          scope.user_availabilities = $.grep(scope.user_availabilities, (user_availability) ->
            user_availability.id != id
          )
          scope.setWeekdayValue()
          scope.$broadcast 'delete_success'
          console.log "delete success controller"
          return
      ), (response) ->
          console.log 'delete error controller'+response['statusCode']
        return

  weekday_Click : (dayName) =>
    switch dayName
      when 'sun' then  @scope.weekday = 0
      when 'mon' then  @scope.weekday = 1
      when 'tue' then  @scope.weekday = 2
      when 'wed' then  @scope.weekday = 3
      when 'thu' then  @scope.weekday = 4
      when 'fri' then  @scope.weekday = 5
      when 'sat' then  @scope.weekday = 6

    if @scope.allDaySelected[dayName]
      @scope.$broadcast 'weekday_unset'
    else
      @scope.$broadcast 'weekday_set'


