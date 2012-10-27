include 'mustache.js'
include 'util.js'

template = include 'quizTemplate.html'
markupTemplate = include 'markup.html'

# Collect Data
quiz = OpenLearning.page.getData( request.user ).data

hasQuizData = true
if quiz.questionsJSON
	try
		quiz.questions = JSON.parse( quiz.questionsJSON )
	catch error
	  	hasQuizData = false
else if not quiz.questions
	hasQuizData = false

user = 'test'
if request.user
	user = request.user

submissionData = null
submissionURL = ''
try
	submissionData = (OpenLearning.activity.getSubmission user)
	userData = submissionData.submission.metadata
	submissionURL = submissionData.url
catch error
	userData = null

if (Object.keys(userData).length is 0)
	userData = null

# function to render and mark a quiz
renderAndMark = (userData, isAnswerChanged=false) ->
	isAnswered = false

	# has this quiz been answered?
	if userData
		isAnswered = true
	
	questions = []
	
	# numbering starts at 1
	questionNumber = 1
	
	# is submission disabled
	isDisabled = userData and (not userData.canSubmit)
	
	# we'll collect marks as we go
	marks = 0
	for questionData in quiz.questions

		isCorrect = false

		selectedAnswers = userData['question' + questionNumber]

		if selectedAnswers not instanceof Array
			if selectedAnswers instanceof String
				selectedAnswers = [selectedAnswers]
			else
				# FIXME we shouldn't be getting an Object but convert it anyway
				selectedAnswers = (selectedAnswers[x] for x of selectedAnswers)

		if questionData.correct instanceof String
			correctAnswers = [questionData.correct]
		else
			correctAnswers = questionData.correct
		
		if isAnswered
			# if this question's been answered, determine if it was answered correctly
			isCorrect = (selectedAnswers.join() is correctAnswers.join())
		
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
					selected = (answerData.value in selectedAnswers)
					# highlight this if it's the correct answer to the question (and the user can't submit)
					showAsCorrect = (answerData.value in correctAnswers) and isDisabled
				
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
			isDropdown: questionData.type is "dropdown"
			isRadio: questionData.type is "radio"
			isCheckbox: questionData.type is "checkbox"
			
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
	
	
	view = 
		answered: isAnswered
		disabled: isDisabled
		questions: questions
		resultText: resultText
		quizResult: quizResult
		doneText: quiz.doneText
		submissionURL: submissionURL
		isAnswerChanged: isAnswerChanged
		completed: (marks == totalQuestions)

	render( template, view )
	
	return [marks, view]
	

if hasQuizData
	
	canSubmit = quiz.allowMultipleSubmission or (not userData)
	
	if request.method is 'POST' and canSubmit and request.data.action == 'saveQuiz'
		# submission
		
		quizData = request.data
		quizData.canSubmit = canSubmit


		[marks, view] = renderAndMark( quizData, true )

		markup = Mustache.render markupTemplate, view

		# TODO: markup
		OpenLearning.activity.saveSubmission user, { markup: markup, metadata: quizData }, 'content'

		updateMarks = true
		# only update marks if completed, if they can submit lots
		if quiz.allowMultipleSubmission and not view.completed
			updateMarks = false
			
		if updateMarks
			taskMarksUpdate = { }

			taskMarksUpdate[request.user] =
				mark: marks
				completed: true
				comment: 'Marked by Quiz Activity'
			
			OpenLearning.activity.submit( request.user )
			OpenLearning.activity.setMarks( taskMarksUpdate )
	else
		quizData = userData
		
		if quizData
			quizData.canSubmit = canSubmit
		
		# show submission (or fresh quiz, if no user data exists)
		renderAndMark( quizData )
else
	# Admin needs to set up the quiz
	response.writeText "Quiz has not been set up."
