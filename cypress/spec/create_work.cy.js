describe('Create work', () => {
    let work_id

    beforeEach(() => {
      const results = cy.appFactories([
        ['create', 'work_version_with_work_and_collection', 'with_required_associations', {} ]
      ]).then((results) => {
        cy.log(results[0])
        work_id = results[0].work_id

        cy.visit(`/works/${work_id}/edit`)
    })
    })

    it('deposits a work correctly after uploading a file', () => {

      // try to deposit
      cy.get('input.btn[value="Deposit"]').click()

      // there is a message telling us we need to upload a file
      cy.get('div.invalid-feedback').should('contain', 'You must attach a file')

      // now upload a file
      cy.get('div.dropzone').selectFile('cypress/fixtures/test.txt', {
        action: 'drag-drop'
      })

      // wait for the upload to finish
      cy.wait(1000)

      // now try to deposit again
      cy.get('input.btn[value="Deposit"]').click()

      // successful deposit!
      cy.url().should('include', `/works/${work_id}/next_step`)
      cy.contains('You have successfully deposited your work')
    })

    it('does not allow saving with a duplicate filename', () => {

      // try to deposit
      cy.get('input.btn[value="Deposit"]').click()

      // there is a message telling us we need to upload a file
      cy.get('div.invalid-feedback').should('contain', 'You must attach a file')

      // upload a file
      cy.get('div.dropzone').selectFile('cypress/fixtures/test2.txt', {
        action: 'drag-drop'
      })

      // wait for the upload to finish
      cy.wait(1000)

      // save the deposit
      cy.get('input.btn[value="Save as draft"]').click()

      // successful save
      cy.url().should('include', `/works/${work_id}`)

      // edit the work again
      cy.visit(`/works/${work_id}/edit`)

      // upload the same file again
      cy.get('div.dropzone').selectFile('cypress/fixtures/test2.txt', {
        action: 'drag-drop'
      })

      // wait for the upload to finish
      cy.wait(1000)

      // try to save the deposit
      cy.get('input.btn[value="Save as draft"]').click()

      // there is a message telling us we cannot have duplicate filenames
      cy.get('#error_explanation').should('contain', 'Attached files must all have a unique filename.')

      // and we are still on the edit page
      cy.url().should('include', `/works/${work_id}/edit`)
    })

    it('deposits a work correctly if globus is selected (without the need to upload a file)', () => {

      // try to deposit
      cy.get('input.btn[value="Deposit"]').click()

      // there is a message telling us we need to upload a file
      cy.get('div.invalid-feedback').should('contain', 'You must attach a file')

      // now select globus upload option
      cy.get('#work_upload_type_globus').check()

      // now try to deposit again
      cy.get('input.btn[value="Deposit"]').click()

      // successful deposit!
      cy.url().should('include', `/works/${work_id}/next_step`)
      cy.contains('You have successfully deposited your work')
    })
})
