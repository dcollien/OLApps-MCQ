include "mustache.js"
include "util.js"

template = include "adminTemplate.html"
accessDeniedTemplate = include "accessDeniedTemplate.html"


# POST and GET controllers
post = ->
	quizData = request.data
	
	view =
		title: quizData.title
		doneText: quizData.doneText
		showAnswers: (quizData.showAnswers is 'on')
		questions: JSON.parse( quizData.questionsJSON )
		allowMultipleSubmission: quizData.allowMultipleSubmission
		isEmbedded: true # this app is embedded in the activity page

	try
		OpenLearning.activity.setTotalMarks questions.length
	catch error
		view.error = "Something went wrong: Unable to set marks"

	# set activity page data
	try
		OpenLearning.page.setData view, request.user
	catch err
		view.error = 'Something went wrong: Unable to save data'
	
	view.message = "Quiz Saved"

	return view

get = ->
	view = {}

	# get activity page data
	try
		view = OpenLearning.page.getData( request.user ).data
	catch err
		view.error = 'Something went wrong: Unable to load data'

	if not view.questions?
		view.questions = []
	
	view.questionsJSON = JSON.stringify( view.questions )

	return view


checkPermission 'write', accessDeniedTemplate, ->
	if request.method is 'POST'
		view = post()
	else
		view = get()

	view.jquery_json = mediaURL( 'jquery-json.js' )

	render template, view

