include 'moustache.js'

template = include 'quizTemplate.html'


# Collect Data
quiz = retrieveData 'quiz', ['title', 'doneText', 'showAnswers', 'questionsJSON', 'allowMultipleSubmission']

hasQuizData = false
if quiz.questionsJSON
	quiz.questions = JSON.parse( quiz.questionsJSON )
	hasQuizData = true
	
user = 'test'
if request.user
	user = request.user
	
userData = (retrieveData user, ['quizData']).quizData

# function to render and mark a quiz
renderAndMark = (userData) ->
	isAnswered = false

	# has this quiz been answered?
	if userData
		isAnswered = true
	
	questions = []
	
	# numbering starts at 1
	questionNumber = 1
	
	# we'll collect marks as we go
	marks = 0
	for questionData in quiz.questions

		isCorrect = false
		
		if isAnswered
			# if this question's been answered, determine if it was answered correctly
			isCorrect = (userData['question' + questionNumber] is questionData.correct)
		
			if isCorrect
				# woohoo! give a mark
				marks += 1
		
		# collate data to render each answer
		answers = []
		if questionData.answers
			for answerData in questionData.answers
				
				selected = false
				showAsCorrect = false
				if isAnswered
					# if this quiz has been answered, figure out if this answer was selected 
					selected = (userData['question' + questionNumber] is answerData.value)
					# highlight this if it's the correct answer to the question
					showAsCorrect = (answerData.value is questionData.correct)
				
				# this is the data we need to render the answer
				answer = 
					text: answerData.text
					selected: selected
					showAsCorrect: showAsCorrect
					value: answerData.value

				answers.push answer

		# this is the data we need to render a question	
		question =
			number: questionNumber
			text: questionData.text
			correct: isCorrect
			answers: answers
			
		questions.push question
		questionNumber += 1
		

	# total number of questions
	totalQuestions = questions.length

	if isAnswered
		quizResult = marks + '/' + totalQuestions
		resultText = 'Result:'
	else
		resultText = 'Total Questions:'
		quizResult = totalQuestions
	
	isDisabled = userData and (not userData.canSubmit)
	
	view = 
		answered: isAnswered
		disabled: isDisabled
		questions: questions
		resultText: resultText
		quizResult: quizResult
		doneText: quiz.doneText
		csrf_token: request.csrfFormInput

	response.writeData Mustache.render( template, view )
	
	return marks
	

if hasQuizData
	
	canSubmit = quiz.allowMultipleSubmission or not userData
	
	if request.method is 'POST' and canSubmit
		# submission
		
		quizData = request.data
		quizData.canSubmit = canSubmit
		
		storeData user, { quizData: quizData }
		marks = renderAndMark( quizData )
		
		taskMarksUpdate = { }

		taskMarksUpdate[request.user] =
			mark: marks
			completed: true
		
		OpenLearning.setMarks( taskMarksUpdate )
	else
		quizData = userData
		
		if quizData
			quizData.canSubmit = canSubmit
		
		# show submission (or fresh quiz, if no user data exists)
		renderAndMark( quizData )
else
	# Admin needs to set up the quiz
	response.writeText "Quiz has not been set up."
