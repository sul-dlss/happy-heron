// JavaScript to disable form submissions if there are invalid fields
(function () {
  'use strict'

  window.addEventListener('turbo:load', function() {
    // Fetch all the forms we want to apply custom Bootstrap validation styles to
    var forms = document.querySelectorAll('.needs-validation')

    // Loop over them and prevent submission
    Array.prototype.slice.call(forms)
      .forEach(function (form) {
        form.addEventListener('submit', function (event) {
          console.log('submit')
          // Note that checkValidity and :invalid do not work in hidden inputs such as dropzone files.
          const invalidFileElem = form.querySelector('.hidden-file.is-invalid')
          if (event.submitter.id === 'save-draft-button') {            
            // limited client side validation for saving drafts
            const elem = invalidFileElem || form.querySelector('.date *:invalid') || form.querySelector('.date-range *:invalid')
            if(!elem) return
            event.preventDefault()
            event.stopPropagation()
            scrollToElement(elem)
            return
          }

          if (!form.checkValidity() || invalidFileElem) {
            event.preventDefault()
            event.stopPropagation()
            scrollToElement(form.querySelector(':invalid') || invalidFileElem)
          }

          form.classList.add('was-validated')
        }, false)
      })
  })

  function scrollToElement(elem) {
    const yOffset = -10

    // Hidden inputs won't provide correct position.
    if(elem.tagName === 'INPUT' && elem.type === 'hidden') {
      elem = elem.parentNode
    }

    const originalDisplay = elem.style.display
    // Allow hidden element to scroll into display.
    elem.style.display = 'block'
    const y = elem.getBoundingClientRect().top + window.pageYOffset + yOffset
    elem.focus({preventScroll: true})
    elem.style.display = originalDisplay
    // elem.focus() and elem.scrollIntoView() doesn't give us any margin, so we do this more complex method:
    window.scrollTo({top: y, behavior: 'smooth'})
  }
})()
