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
          if (event.submitter.id === 'save-draft-button') return // do not run client side validation for saving drafts
          if (!form.checkValidity()) {
            event.preventDefault()
            event.stopPropagation()
            scrollToFirstInvalidElement(form)
          }

          form.classList.add('was-validated')
        }, false)
      })
  })

  function scrollToFirstInvalidElement(form) {
    const yOffset = -10
    const elem = form.querySelector(':invalid')
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
