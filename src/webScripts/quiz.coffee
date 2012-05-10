quiz = retrieveData 'quiz', ['title', 'doneText', 'showAnswers', 'questionsJSON']
quiz.questions = JSON.parse( quiz.questionsJSON )

renderQuiz = (postAnswers=null) ->
  csrfToken = '<input type="hidden" name="csrfmiddlewaretoken" value="' + request.csrfToken + '">'
    
  renderQuestion = ( number, question ) ->
    html = "<tr><th>" + number + "</th><td>" + response.escape( question.text ) + "</td><td>"
    
    if postAnswers
      if postAnswers['question' + number] is question.correct
        html += '<span class="label label-success">Correct</span>'
      else
        html += '<span class="label label-important">Incorrect</span>'
    
    for answer in question.answers
      checked = ''
      disabled = ''
      answerText = response.escape( answer.text )
      
      if postAnswers
        disabled = 'disabled="disabled"'
        answerColor = '#000'
        
        if postAnswers['question' + number] is answer.value
          checked = 'checked="checked"'
          answerColor = '#080'
          
        if answer.value is question.correct and quiz.showAnswers
          answerText = '<b style="color: ' + answerColor + '">' + answerText + '</b>'
      
      html += '<label class="radio" style="margin-top: 4px">'
      html += '<input type="radio" name="question' + number + '" value="' + response.escape( answer.value ) + '" ' + checked + ' ' + disabled + '>'
      html += response.escape( answerText )
      html += '</label>'
    
    html += '</td></tr>'
      
    return html
  
  footer = '<center><button type="submit" class="btn btn-primary">'
  footer += response.escape( quiz.doneText ) + '</button></center>'
  
  
  html = include 'quizTemplate.html'
  
  quizRows = ''
  
  marks = 0
  
  questionNumber = 1
  for question in quiz.questions
    quizRows += renderQuestion questionNumber, question
    
    if postAnswers and postAnswers['question' + questionNumber] is question.correct
      marks += 1
    
    questionNumber += 1

  if postAnswers
    quizResult = marks + '/' + quiz.questions.length
    resultText = 'Result:'
  else
    resultText = 'Total Questions:'
    quizResult = quiz.questions.length
  
  html = html.replace '{{ quizTitle }}', response.escape( quiz.title )
  html = html.replace '{{ csrf_token }}', csrfToken
  html = html.replace '{{ quizRows }}', quizRows
  html = html.replace '{{ resultText }}', response.escape( resultText )
  html = html.replace '{{ quizResult }}', response.escape( quizResult )
  
  if not postAnswers
    html = html.replace '{{ quizFooter }}', footer
  else
    if quiz.thankyou
      html = html.replace '{{ quizFooter }}', response.escape( quiz.thankyou )
    else
      html = html.replace '{{ quizFooter }}', ''
  
  response.writeData html
  return marks
  

if request.method is 'POST'
  storeData request.user, { quizData: request.data }
  quiz.thankyou = 'Marks Saved'
  marks = renderQuiz request.data
  
  taskMarksUpdate = { }
  
  taskMarksUpdate[request.user] =
    mark: marks
  
  setMarks( taskMarksUpdate )
else
  userData = retrieveData request.user, ['quizData']
  quizData = userData.quizData
  if quizData
    renderQuiz quizData
  else
    renderQuiz()


