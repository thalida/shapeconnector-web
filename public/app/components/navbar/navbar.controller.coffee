'use strict'

angular.module 'shapeConnectorApp'
.controller 'NavbarCtrl', ($scope, $location) ->
  $scope.menu = [
    title: 'Home'
    link: '/'
  ]
  $scope.isCollapsed = true

  $scope.isActive = (route) ->
    route is $location.path()