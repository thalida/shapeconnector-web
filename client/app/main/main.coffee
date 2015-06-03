'use strict'

app
.config ($stateProvider) ->
  $stateProvider
  .state 'main',
    url: '/main'
    templateUrl: 'app/main/main.html'
    controller: 'MainCtrl'
