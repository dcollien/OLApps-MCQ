quizData = request.data

try
	questions = JSON.parse quizData.questionsJSON
	OpenLearning.setTotalMarks( questions.length )
catch error
	quizData.questionsJSON = '[]'

quiz =
	title: quizData.title
	doneText: quizData.doneText
	showAnswers: (quizData.showAnswers is 'on')
	questionsJSON: quizData.questionsJSON
	allowMultipleSubmission: quizData.allowMultipleSubmission

OpenLearning.setTotalMarks( questions.length )

storeData 'quiz', quiz

response.setStatusCode 303
response.setHeader 'Location', './admin'
