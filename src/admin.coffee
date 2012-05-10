csrfToken = '<input type="hidden" name="csrfmiddlewaretoken" value="' + request.csrfToken + '">'

html = include 'adminTemplate.html'


html = html.replace '{{ csrf_token }}', csrfToken

response.writeData html
