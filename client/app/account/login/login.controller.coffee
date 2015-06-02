'use strict'

angular.module 'shapeConnectorApp'
.controller 'LoginCtrl', ($scope, Auth, $location) ->
  $scope.user = {}
  $scope.errors = {}
  $scope.login = (form) ->
    $scope.submitted = true

    if form.$valid
      # Logged in, redirect to home
      Auth.login
        email: $scope.user.email
        password: $scope.user.password

      .then ->
        $location.path '/'

      .catch (err) ->
        $scope.errors.other = err.message

