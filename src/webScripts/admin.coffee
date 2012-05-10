include 'moustache.js'

template = include 'adminTemplate.html'

view = csrf_token: request.csrfFormInput

response.writeData Mustache.render( template, view )
