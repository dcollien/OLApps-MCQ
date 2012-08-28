include "mustache.js"
include "util.js"

template = include "adminTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"


# POST and GET controllers
post = ->
	quizData = request.data
	
	try
		questions = JSON.parse( quizData.questionsJSON )
		OpenLearning.activity.setTotalMarks questions.length
	catch error
		quizData.questionsJSON = '[]'
	
	view =
		title: quizData.title
		doneText: quizData.doneText
		showAnswers: (quizData.showAnswers is 'on')
		questionsJSON: quizData.questionsJSON
		allowMultipleSubmission: quizData.allowMultipleSubmission
		isEmbedded: true # this app is embedded in the activity page

	# set activity page data
	try
		OpenLearning.page.setData view, request.user
	catch err
		view.error = 'Something went wrong: Unable to save data'
	
	return view

get = ->
	view = {}

	# get activity page data
	try
		view = OpenLearning.page.getData( request.user )
	catch err
		view.error = 'Something went wrong: Unable to load data'

	if not view.questionsJSON?
		view.questionsJSON = '[]'

	return view


checkPermission 'write', accessDeniedTemplate, ->
	if request.method is 'POST'
		view = post()
	else
		view = get()

	view.jquery_spin = mediaURL( 'jquery-spin.js' )
	view.spin_button = mediaURL( 'spin-button.png' )
	view.spin_up = mediaURL( 'spin-up.png' )
	view.spin_down = mediaURL( 'spin-down.png' )

	render template, view

