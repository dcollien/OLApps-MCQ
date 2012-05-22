include "mustache.js"
template = include "adminTemplate.html"

if OpenLearning.isAdmin( request.user )
	if request.method is 'POST'
		# store data
		quizData = request.data
		
		try
			questions = JSON.parse( quizData.questionsJSON )
			OpenLearning.setTotalMarks questions.length
		catch error
			quizData.questionsJSON = '[]'
		
		quiz =
			title: quizData.title
			doneText: quizData.doneText
			showAnswers: (quizData.showAnswers is 'on')
			questionsJSON: quizData.questionsJSON
			allowMultipleSubmission: quizData.allowMultipleSubmission

		storeData 'quiz', quiz
		
	view = retrieveData 'quiz', ['title', 'doneText', 'showAnswers', 'questionsJSON', 'allowMultipleSubmission']
	
  	view.csrf_token = request.csrfFormInput
	
	response.writeData Mustache.render( template, view )
else
	response.setStatusCode 403
	response.writeText 'Error: Not Allowed'
