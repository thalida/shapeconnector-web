(function() {
  angular.module('shapeConnector', ['ngAnimate', 'ngTouch', 'ngSanitize', 'ngResource', 'ui.router']).config(function($stateProvider, $urlRouterProvider) {
    $stateProvider.state("home", {
      url: "/",
      templateUrl: "app/main/main.html",
      controller: "MainCtrl"
    });
    return $urlRouterProvider.otherwise('/');
  });

}).call(this);

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbImluZGV4LmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtFQUFBLE9BQU8sQ0FBQyxNQUFSLENBQWUsZ0JBQWYsRUFBaUMsQ0FBQyxXQUFELEVBQWMsU0FBZCxFQUF5QixZQUF6QixFQUF1QyxZQUF2QyxFQUFxRCxXQUFyRCxDQUFqQyxDQUNFLENBQUMsTUFESCxDQUNVLFNBQUMsY0FBRCxFQUFpQixrQkFBakI7SUFDTixjQUNFLENBQUMsS0FESCxDQUNTLE1BRFQsRUFFSTtNQUFBLEdBQUEsRUFBSyxHQUFMO01BQ0EsV0FBQSxFQUFhLG9CQURiO01BRUEsVUFBQSxFQUFZLFVBRlo7S0FGSjtXQU1BLGtCQUFrQixDQUFDLFNBQW5CLENBQTZCLEdBQTdCO0VBUE0sQ0FEVjtBQUFBIiwiZmlsZSI6ImluZGV4LmpzIiwic291cmNlUm9vdCI6Ii9zb3VyY2UvIiwic291cmNlc0NvbnRlbnQiOlsiYW5ndWxhci5tb2R1bGUgJ3NoYXBlQ29ubmVjdG9yJywgWyduZ0FuaW1hdGUnLCAnbmdUb3VjaCcsICduZ1Nhbml0aXplJywgJ25nUmVzb3VyY2UnLCAndWkucm91dGVyJ11cbiAgLmNvbmZpZyAoJHN0YXRlUHJvdmlkZXIsICR1cmxSb3V0ZXJQcm92aWRlcikgLT5cbiAgICAkc3RhdGVQcm92aWRlclxuICAgICAgLnN0YXRlIFwiaG9tZVwiLFxuICAgICAgICB1cmw6IFwiL1wiLFxuICAgICAgICB0ZW1wbGF0ZVVybDogXCJhcHAvbWFpbi9tYWluLmh0bWxcIixcbiAgICAgICAgY29udHJvbGxlcjogXCJNYWluQ3RybFwiXG5cbiAgICAkdXJsUm91dGVyUHJvdmlkZXIub3RoZXJ3aXNlICcvJ1xuXG4iXX0=