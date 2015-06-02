(function() {
  angular.module("shapeConnector").controller("MainCtrl", function($scope) {
    $scope.awesomeThings = [
      {
        'title': 'AngularJS',
        'url': 'https://angularjs.org/',
        'description': 'HTML enhanced for web apps!',
        'logo': 'angular.png'
      }, {
        'title': 'BrowserSync',
        'url': 'http://browsersync.io/',
        'description': 'Time-saving synchronised browser testing.',
        'logo': 'browsersync.png'
      }, {
        'title': 'GulpJS',
        'url': 'http://gulpjs.com/',
        'description': 'The streaming build system.',
        'logo': 'gulp.png'
      }, {
        'title': 'Jasmine',
        'url': 'http://jasmine.github.io/',
        'description': 'Behavior-Driven JavaScript.',
        'logo': 'jasmine.png'
      }, {
        'title': 'Karma',
        'url': 'http://karma-runner.github.io/',
        'description': 'Spectacular Test Runner for JavaScript.',
        'logo': 'karma.png'
      }, {
        'title': 'Protractor',
        'url': 'https://github.com/angular/protractor',
        'description': 'End to end test framework for AngularJS applications built on top of WebDriverJS.',
        'logo': 'protractor.png'
      }, {
        'title': 'Sass (Node)',
        'url': 'https://github.com/sass/node-sass',
        'description': 'Node.js binding to libsass, the C version of the popular stylesheet preprocessor, Sass.',
        'logo': 'node-sass.png'
      }, {
        'title': 'CoffeeScript',
        'url': 'http://coffeescript.org/',
        'description': 'CoffeeScript, \'a little language that compiles into JavaScript\'.',
        'logo': 'coffeescript.png'
      }
    ];
    return angular.forEach($scope.awesomeThings, function(awesomeThing) {
      return awesomeThing.rank = Math.random();
    });
  });

}).call(this);

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIm1haW4vbWFpbi5jb250cm9sbGVyLmNvZmZlZSJdLCJuYW1lcyI6W10sIm1hcHBpbmdzIjoiQUFBQTtFQUFBLE9BQU8sQ0FBQyxNQUFSLENBQWUsZ0JBQWYsQ0FDRSxDQUFDLFVBREgsQ0FDYyxVQURkLEVBQzBCLFNBQUMsTUFBRDtJQUN0QixNQUFNLENBQUMsYUFBUCxHQUF1QjtNQUNyQjtRQUNFLE9BQUEsRUFBUyxXQURYO1FBRUUsS0FBQSxFQUFPLHdCQUZUO1FBR0UsYUFBQSxFQUFlLDZCQUhqQjtRQUlFLE1BQUEsRUFBUSxhQUpWO09BRHFCLEVBT3JCO1FBQ0UsT0FBQSxFQUFTLGFBRFg7UUFFRSxLQUFBLEVBQU8sd0JBRlQ7UUFHRSxhQUFBLEVBQWUsMkNBSGpCO1FBSUUsTUFBQSxFQUFRLGlCQUpWO09BUHFCLEVBYXJCO1FBQ0UsT0FBQSxFQUFTLFFBRFg7UUFFRSxLQUFBLEVBQU8sb0JBRlQ7UUFHRSxhQUFBLEVBQWUsNkJBSGpCO1FBSUUsTUFBQSxFQUFRLFVBSlY7T0FicUIsRUFtQnJCO1FBQ0UsT0FBQSxFQUFTLFNBRFg7UUFFRSxLQUFBLEVBQU8sMkJBRlQ7UUFHRSxhQUFBLEVBQWUsNkJBSGpCO1FBSUUsTUFBQSxFQUFRLGFBSlY7T0FuQnFCLEVBeUJyQjtRQUNFLE9BQUEsRUFBUyxPQURYO1FBRUUsS0FBQSxFQUFPLGdDQUZUO1FBR0UsYUFBQSxFQUFlLHlDQUhqQjtRQUlFLE1BQUEsRUFBUSxXQUpWO09BekJxQixFQStCckI7UUFDRSxPQUFBLEVBQVMsWUFEWDtRQUVFLEtBQUEsRUFBTyx1Q0FGVDtRQUdFLGFBQUEsRUFBZSxtRkFIakI7UUFJRSxNQUFBLEVBQVEsZ0JBSlY7T0EvQnFCLEVBcUNyQjtRQUNFLE9BQUEsRUFBUyxhQURYO1FBRUUsS0FBQSxFQUFPLG1DQUZUO1FBR0UsYUFBQSxFQUFlLHlGQUhqQjtRQUlFLE1BQUEsRUFBUSxlQUpWO09BckNxQixFQTJDckI7UUFDRSxPQUFBLEVBQVMsY0FEWDtRQUVFLEtBQUEsRUFBTywwQkFGVDtRQUdFLGFBQUEsRUFBZSxvRUFIakI7UUFJRSxNQUFBLEVBQVEsa0JBSlY7T0EzQ3FCOztXQWtEdkIsT0FBTyxDQUFDLE9BQVIsQ0FBZ0IsTUFBTSxDQUFDLGFBQXZCLEVBQXNDLFNBQUMsWUFBRDthQUNwQyxZQUFZLENBQUMsSUFBYixHQUFvQixJQUFJLENBQUMsTUFBTCxDQUFBO0lBRGdCLENBQXRDO0VBbkRzQixDQUQxQjtBQUFBIiwiZmlsZSI6Im1haW4vbWFpbi5jb250cm9sbGVyLmpzIiwic291cmNlUm9vdCI6Ii9zb3VyY2UvIiwic291cmNlc0NvbnRlbnQiOlsiYW5ndWxhci5tb2R1bGUgXCJzaGFwZUNvbm5lY3RvclwiXG4gIC5jb250cm9sbGVyIFwiTWFpbkN0cmxcIiwgKCRzY29wZSkgLT5cbiAgICAkc2NvcGUuYXdlc29tZVRoaW5ncyA9IFtcbiAgICAgIHtcbiAgICAgICAgJ3RpdGxlJzogJ0FuZ3VsYXJKUycsXG4gICAgICAgICd1cmwnOiAnaHR0cHM6Ly9hbmd1bGFyanMub3JnLycsXG4gICAgICAgICdkZXNjcmlwdGlvbic6ICdIVE1MIGVuaGFuY2VkIGZvciB3ZWIgYXBwcyEnLFxuICAgICAgICAnbG9nbyc6ICdhbmd1bGFyLnBuZydcbiAgICAgIH0sXG4gICAgICB7XG4gICAgICAgICd0aXRsZSc6ICdCcm93c2VyU3luYycsXG4gICAgICAgICd1cmwnOiAnaHR0cDovL2Jyb3dzZXJzeW5jLmlvLycsXG4gICAgICAgICdkZXNjcmlwdGlvbic6ICdUaW1lLXNhdmluZyBzeW5jaHJvbmlzZWQgYnJvd3NlciB0ZXN0aW5nLicsXG4gICAgICAgICdsb2dvJzogJ2Jyb3dzZXJzeW5jLnBuZydcbiAgICAgIH0sXG4gICAgICB7XG4gICAgICAgICd0aXRsZSc6ICdHdWxwSlMnLFxuICAgICAgICAndXJsJzogJ2h0dHA6Ly9ndWxwanMuY29tLycsXG4gICAgICAgICdkZXNjcmlwdGlvbic6ICdUaGUgc3RyZWFtaW5nIGJ1aWxkIHN5c3RlbS4nLFxuICAgICAgICAnbG9nbyc6ICdndWxwLnBuZydcbiAgICAgIH0sXG4gICAgICB7XG4gICAgICAgICd0aXRsZSc6ICdKYXNtaW5lJyxcbiAgICAgICAgJ3VybCc6ICdodHRwOi8vamFzbWluZS5naXRodWIuaW8vJyxcbiAgICAgICAgJ2Rlc2NyaXB0aW9uJzogJ0JlaGF2aW9yLURyaXZlbiBKYXZhU2NyaXB0LicsXG4gICAgICAgICdsb2dvJzogJ2phc21pbmUucG5nJ1xuICAgICAgfSxcbiAgICAgIHtcbiAgICAgICAgJ3RpdGxlJzogJ0thcm1hJyxcbiAgICAgICAgJ3VybCc6ICdodHRwOi8va2FybWEtcnVubmVyLmdpdGh1Yi5pby8nLFxuICAgICAgICAnZGVzY3JpcHRpb24nOiAnU3BlY3RhY3VsYXIgVGVzdCBSdW5uZXIgZm9yIEphdmFTY3JpcHQuJyxcbiAgICAgICAgJ2xvZ28nOiAna2FybWEucG5nJ1xuICAgICAgfSxcbiAgICAgIHtcbiAgICAgICAgJ3RpdGxlJzogJ1Byb3RyYWN0b3InLFxuICAgICAgICAndXJsJzogJ2h0dHBzOi8vZ2l0aHViLmNvbS9hbmd1bGFyL3Byb3RyYWN0b3InLFxuICAgICAgICAnZGVzY3JpcHRpb24nOiAnRW5kIHRvIGVuZCB0ZXN0IGZyYW1ld29yayBmb3IgQW5ndWxhckpTIGFwcGxpY2F0aW9ucyBidWlsdCBvbiB0b3Agb2YgV2ViRHJpdmVySlMuJyxcbiAgICAgICAgJ2xvZ28nOiAncHJvdHJhY3Rvci5wbmcnXG4gICAgICB9LFxuICAgICAge1xuICAgICAgICAndGl0bGUnOiAnU2FzcyAoTm9kZSknLFxuICAgICAgICAndXJsJzogJ2h0dHBzOi8vZ2l0aHViLmNvbS9zYXNzL25vZGUtc2FzcycsXG4gICAgICAgICdkZXNjcmlwdGlvbic6ICdOb2RlLmpzIGJpbmRpbmcgdG8gbGlic2FzcywgdGhlIEMgdmVyc2lvbiBvZiB0aGUgcG9wdWxhciBzdHlsZXNoZWV0IHByZXByb2Nlc3NvciwgU2Fzcy4nLFxuICAgICAgICAnbG9nbyc6ICdub2RlLXNhc3MucG5nJ1xuICAgICAgfSxcbiAgICAgIHtcbiAgICAgICAgJ3RpdGxlJzogJ0NvZmZlZVNjcmlwdCcsXG4gICAgICAgICd1cmwnOiAnaHR0cDovL2NvZmZlZXNjcmlwdC5vcmcvJyxcbiAgICAgICAgJ2Rlc2NyaXB0aW9uJzogJ0NvZmZlZVNjcmlwdCwgXFwnYSBsaXR0bGUgbGFuZ3VhZ2UgdGhhdCBjb21waWxlcyBpbnRvIEphdmFTY3JpcHRcXCcuJyxcbiAgICAgICAgJ2xvZ28nOiAnY29mZmVlc2NyaXB0LnBuZydcbiAgICAgIH1cbiAgICBdXG4gICAgYW5ndWxhci5mb3JFYWNoICRzY29wZS5hd2Vzb21lVGhpbmdzLCAoYXdlc29tZVRoaW5nKSAtPlxuICAgICAgYXdlc29tZVRoaW5nLnJhbmsgPSBNYXRoLnJhbmRvbSgpXG4iXX0=