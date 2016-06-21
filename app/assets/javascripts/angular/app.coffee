@App = angular
  .module 'enapparte', [
    'rails'
    'ngSanitize'
    'cgNotify'
    'angularUtils.directives.dirPagination'
    'underscore'
    'angularMoment'
    'ui.bootstrap'
    'Devise'
    'focus-if'
    'ui.router'
    'ui.router.tabs'
    'ui.bootstrap.datetimepicker'
    'ngAnimate'
    'anim-in-out'
    'stripe'
    'credit-cards'
    'ui.select'
    'ngProgress'
    'angular-bind-html-compile'
  ]

@App.config ['AuthProvider', (AuthProvider)->
]

@App.config ["$httpProvider", ($httpProvider) ->
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
]

@App.config ['uiSelectConfig', (uiSelectConfig) ->
  uiSelectConfig.theme = 'bootstrap'
]

# @App.config ['dateTimePickerConfig', (dateTimePickerConfig)->
#   # dateTimePickerConfig.defaults
# ]

@App.config [()->
  Stripe.setPublishableKey(window.StripePublishableKey)
]

@App.run ['$rootScope', 'Auth', '$state', 'Flash', '$timeout', ($rootScope, Auth, $state, Flash, $timeout)->

  Auth.currentUser().then (user)->
      $rootScope.currentUser = user

  $rootScope.$on '$stateChangeSuccess', (e)->
    $rootScope.rootPath = false
    unless $state.current.name.startsWith 'home'
      $(window).off('.affix')
      $("#header")
        .removeClass("affix-top, affix-bottom, full-main-content")
        .addClass("affix")
        .removeData("bs.affix")
    $timeout (->
      if !($state.current.name in ['home', 'home.signin', 'home.signup', 'shows.search', 'contact', 'about', 'performer', 'faq', 'terms', 'concept', 'concept.works', 'artists.show', 'society']) && !Auth.isAuthenticated()
        $state.go 'home'
        Flash.showError $rootScope, "You need to sign in or sign up before continuing."
    ), 500

]
@App.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider)->
  $urlRouterProvider.otherwise('/')

  $stateProvider
    .state 'home',
      url: '/'
      templateUrl: 'root.html'
      controller: 'RootController'

    .state 'artists',
      url: '/artists'
      abstract: true
      template: '<ui-view />'

    .state 'artists.show',
      url: '/:id'
      templateUrl: 'artists/show.html'
      controller: 'ArtistsController'

    .state 'about', {
      url: '/about',
      templateUrl: 'pages/about.html',
      controller: 'RootController'
      onEnter: ['$anchorScroll', ($anchorScroll)->
        $anchorScroll(0)
      ]
    }
    .state 'performer', {
      url: '/performer',
      templateUrl: 'pages/become_performer.html'
      onEnter: ['$anchorScroll', ($anchorScroll)->
        $anchorScroll(0)
      ]
    }
    .state 'faq', {
      url: '/faq',
      templateUrl: 'pages/faq.html'
      onEnter: ['$anchorScroll', ($anchorScroll)->
        $anchorScroll(0)
      ]
    }
    .state 'terms', {
      url: '/terms',
      templateUrl: 'pages/terms.html'
      onEnter: ['$anchorScroll', ($anchorScroll)->
        $anchorScroll(0)
      ]
    }
    .state 'concept', { url: '/concept', templateUrl: 'pages/concept.html', controller: 'RootController' }
    .state 'concept.works', {
      url: 'howItWorks',
      onEnter: ['$uibModal', '$state', ($uibModal, $state)->
        $uibModal.open
          animation: true
          templateUrl: 'pages/how_it_works.html'
          controller: 'ConceptController'
        .result
        .finally ()->
          $state.go '^'
      ]
    }
    .state 'contact', {
      url: '/contact',
      templateUrl: 'pages/contact.html',
      controller: 'ContactController'
      onEnter: ['$anchorScroll', ($anchorScroll)->
        $anchorScroll(0)
      ]
    }
    .state 'society', {
      url: '/society',
      templateUrl: 'pages/society.html',
      controller: 'SocietyController'
      onEnter: ['$anchorScroll', ($anchorScroll)->
        $anchorScroll(0)
      ]
    }
    .state 'shows', { abstract: true, url: '/shows', templateUrl: 'shows/index.html' }
    .state 'shows.search', { url: '/:id/search', templateUrl: 'shows/search.html' }
    .state 'shows.detail', { url: '/:id/detail', templateUrl: 'shows/detail.html' }
    .state 'shows.payment', { url: '/:id/payment?date&spectators', templateUrl: 'shows/payment.html', params: { show: null } }
      .state 'shows.payment_finish', { url: '/payment_finish', templateUrl: 'shows/payment_finish.html' }
    .state 'shows.edit', { url: '/:id/edit', templateUrl: 'shows/edit.html', params: { id: null } }
    .state 'shows.new', {url: '/new', templateUrl: 'shows/edit.html'}

    .state 'dashboard', { abstract: true, url: '/dashboard', templateUrl: 'dashboard/tabs.html' }
      .state 'dashboard.index', { url: '/index', templateUrl: 'dashboard/index.html' }

      .state 'dashboard.profile', { abstract: true, url: '/profile', templateUrl: 'dashboard/profile/tabs.html' }
      .state 'dashboard.profile.personal', { url: '/personal', templateUrl: 'dashboard/profile/personal.html' }
      .state 'dashboard.profile.reviews', { abstract: true, url: '/reviews', templateUrl: 'dashboard/profile/reviews/tabs.html' }
      .state 'dashboard.profile.reviews.received', { url: '/received', templateUrl: 'dashboard/profile/reviews/received.html' }
      .state 'dashboard.profile.reviews.sent', { url: '/sent', templateUrl: 'dashboard/profile/reviews/sent.html' }

      .state 'dashboard.messages', { url: '/messages', templateUrl: 'dashboard/messages/index.html' }

      .state 'dashboard.shows', { url: '/shows', templateUrl: 'dashboard/shows/index.html' }

      .state 'dashboard.performances', { abstract: true, url: '/performances', templateUrl: 'dashboard/performances/index.html' }
      .state 'dashboard.performances.current', { url: '/current', templateUrl: 'dashboard/performances/current.html' }
      .state 'dashboard.performances.history', { url: '/history', templateUrl: 'dashboard/performances/history.html' }
      .state 'dashboard.performances.cancelled', { url: '/cancelled', templateUrl: 'dashboard/performances/cancelled.html' }

      .state 'dashboard.reservations', { abstract: true, url: '/reservations', templateUrl: 'dashboard/reservations/index.html' }
      .state 'dashboard.reservations.current', { url: '/current', templateUrl: 'dashboard/reservations/current.html' }
      .state 'dashboard.reservations.history', { url: '/history', templateUrl: 'dashboard/reservations/history.html' }
      .state 'dashboard.reservations.cancelled', { url: '/cancelled', templateUrl: 'dashboard/reservations/cancelled.html' }

      .state 'dashboard.account', { abstract: true, url: '/account', templateUrl: 'dashboard/account/index.html' }
      .state 'dashboard.account.payment', { url: '/payment', templateUrl: 'dashboard/account/payment.html' }
      .state 'dashboard.account.information', { url: '/information', templateUrl: 'dashboard/account/information.html' }
      .state 'dashboard.account.security', { url: '/security', templateUrl: 'dashboard/account/security.html' }
      .state 'dashboard.calendar', {url: '/:id/calendar', templateUrl: 'dashboard/calendar/index.html'}

      .state 'dashboard.gallery', {url: '/gallery', templateUrl: 'dashboard/showcases/index.html'}
    .state 'home.signin', {
      url: 'signin',
      onEnter: ['$uibModal', '$state', '$uibModalStack', ($uibModal, $state, $uibModalStack)->
        $uibModalStack.dismissAll('closing')
        $uibModal.open
          animation: true
          templateUrl: 'devise/log_in.html'
          controller: 'SignInController'
        .result
        .finally ()->
          $state.go '^'
      ]
    }
    .state 'home.signup', {
      url: 'signup',
      onEnter: ['$uibModal', '$state', '$uibModalStack', ($uibModal, $state, $uibModalStack)->
        $uibModalStack.dismissAll('closing')
        $uibModal.open
          animation: true
          templateUrl: 'devise/sign_up.html'
          controller: 'SignUpController'
        .result
        .finally ()->
          $state.go '^'
      ]
    }
    .state 'home.forgot_password', {
      url: 'signup',
      onEnter: ['$uibModal', '$state', '$uibModalStack', ($uibModal, $state, $uibModalStack)->
        $uibModalStack.dismissAll('closing')
        $uibModal.open
          animation: true
          templateUrl: 'devise/forgot_password.html'
          controller: 'ForgotPasswordController'
        .result
        .finally ()->
          $state.go '^'
      ]
    }

]
