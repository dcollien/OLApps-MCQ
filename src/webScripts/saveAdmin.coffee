quizData = request.data

quiz =
	title: quizData.title
	doneText: quizData.doneText
	showAnswers: (quizData.showAnswers is 'on')
	questionsJSON: quizData.questionsJSON
	allowMultipleSubmission: quizData.allowMultipleSubmission

storeData 'quiz', quiz

response.setStatusCode 303
response.setHeader 'Location', './admin'
