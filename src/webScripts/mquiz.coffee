include 'moustache.js'

quiz = retrieveData 'quiz', ['title', 'doneText', 'showAnswers', 'questionsJSON']

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

		isCorrect = false
		
		if isAnswered
			isCorrect = (userData['question' + questionNumber] is questionData.correct)

		if isCorrect
			marks += 1

		answers = []
		
		if questionData.answers
			for answerData in questionData.answers
				
				selected = false
				showAsCorrect = false
				if isAnswered
					selected = (userData['question' + questionNumber] is answerData.value)
					showAsCorrect = (answerData.value is questionData.correct)
				
				answer = 
					text: answerData.text
					selected: selected
					showAsCorrect: showAsCorrect

				answers.push answer

			
		question =
			number: questionNumber
			text: questionData.text
			correct: isCorrect
			answers: answers
			
		questions.push question
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
		csrf_token: request.csrfFormInput

	response.writeData Mustache.render( template, view )
	
	return marks
	
if quiz.questionsJSON
	quiz.questions = JSON.parse( quiz.questionsJSON )
	
	if request.method is 'POST'
		storeData request.user, { quizData: request.data }
		marks = render( )
		
		taskMarksUpdate = { }

		taskMarksUpdate[request.user] =
			mark: marks
			completed: true
		
		#setMarks( taskMarksUpdate )
	else
		render( )
else
	response.writeText "Quiz has not been set up."
