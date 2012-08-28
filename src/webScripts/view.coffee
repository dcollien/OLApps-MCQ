include 'mustache.js'
include 'util.js'

template = include 'quizTemplate.html'


# Collect Data
quiz = OpenLearning.page.getData( request.user )

hasQuizData = false
if quiz.questionsJSON
	try
		quiz.questions = JSON.parse( quiz.questionsJSON )
		hasQuizData = true
	catch error
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
renderAndMark = (userData) ->
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
					# highlight this if it's the correct answer to the question (and the user can't submit)
					showAsCorrect = (answerData.value is questionData.correct) and isDisabled
				
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
	
	
	view = 
		answered: isAnswered
		disabled: isDisabled
		questions: questions
		resultText: resultText
		quizResult: quizResult
		doneText: quiz.doneText
		submissionURL: submissionURL

	render( template, view )
	
	return marks
	

if hasQuizData
	
	canSubmit = quiz.allowMultipleSubmission or (not userData)
	
	if request.method is 'POST' and canSubmit
		# submission
		
		quizData = request.data
		quizData.canSubmit = canSubmit

		# TODO: markup
		OpenLearning.activity.saveSubmission user, { markup: 'This is a quiz submission', metadata: quizData }, 'content'

		marks = renderAndMark( quizData )
		
		taskMarksUpdate = { }

		taskMarksUpdate[request.user] =
			mark: marks
			completed: true
			comment: 'Marked by Quiz Activity'
		
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
