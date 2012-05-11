if OpenLearning.isAdmin( request.user )
	quizData = retrieveData 'quiz', ['title', 'doneText', 'showAnswers', 'questionsJSON', 'allowMultipleSubmission']

	quiz =
		title: quizData.title
		doneText: quizData.doneText
		showAnswers: quizData.showAnswers
		questions: JSON.parse quizData.questionsJSON
		allowMultipleSubmission: quizData.allowMultipleSubmission
  
	response.writeJSON quiz
else
	response.writeJSON { 'error': 'Not Allowed' }
