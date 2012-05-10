include 'moustache.js'

quiz = retrieveData 'quiz', ['title', 'doneText', 'showAnswers', 'questionsJSON']

if quiz.questions
	quiz.questions = JSON.parse( quiz.questionsJSON )
	render( )
else
	response.writeText "Quiz has not been set up."

render = ->
	userData = (retrieveData request.user, ['quizData']).quizData
	isAnswered = false

	# has this quiz been answered?
	if userData
		isAnswered = true

	template = include 'mquizTemplate.html'
	
	questions = []
	
	questionNumber = 1
	marks = 0
	for questionData in quiz.questions

		isCorrect = (userData['question' + questionNumber] is questionData.correct)

		marks += 1 if isCorrect

		answers = []
		
		if questionData.answers
			for answerData in questionData.answers
				answer = 
					text: answerData.text
					selected: (userData['question' + questionNumber] is answerData.value) if isAnswered else false
					showAsCorrect: (answerData.value is questionData.correct) if isAnswered else false

				answers.push answer
			
				question =
					number: questionNumber
					text: questionData.text
					correct: isCorrect
					answers: answers

				questionNumber += 1

	totalQuestions = questionNumber

	if isAnswered
		quizResult = marks + '/' + totalQuestions
		resultText = 'Result:'
	else
		resultText = 'Total Questions:'
		quizResult = totalQuestions
		
	view = 
		answered: isAnswered
		questions: questions
		resultText: resultText
		quizResult: quizResult
		doneText: quiz.doneText

	response.writeData Mustache.render( template, view )
