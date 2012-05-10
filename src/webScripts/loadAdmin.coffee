quizData = retrieveData 'quiz', ['title', 'doneText', 'showAnswers', 'questionsJSON']

quiz =
  'title': quizData.title
  'doneText': quizData.doneText
  'showAnswers': quizData.showAnswers
  'questions': JSON.parse quizData.questionsJSON
  
response.writeJSON quiz
