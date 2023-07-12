describe('Create work version', () => {
    let work_id

    beforeEach(() => {
      const results = cy.appFactories([
        ['create', 'work_version_with_work_and_collection', 'with_required_associations', {globus_endpoint: 'jstanford/work333/version1'} ]
      ]).then((results) => {
        cy.log(results[0])
        work_id = results[0].work_id
      })
    })

    it('deposits a work correctly after uploading a file', () => {
      cy.visit(`/works/${work_id}/edit`)

      // select browser upload option
      cy.get('#work_upload_type_browser').check()

      // try to deposit
      cy.get('input.btn[value="Deposit"]', {force: true}).click()

      // there is a message telling us we need to upload a file
      cy.get('div.invalid-feedback').should('contain', 'You must attach a file')

      // now upload a file
      cy.get('#uploaded-files-panel div.dropzone').selectFile('cypress/fixtures/test.txt', {
        action: 'drag-drop'
      })

      // wait for the upload to finish
      cy.wait(1000)

      // now try to deposit again
      cy.get('input.btn[value="Deposit"]', {force: true}).click()

      // successful deposit!
      cy.url().should('include', `/works/${work_id}/next_step`)
      cy.contains('You have successfully deposited your work')
    })

    it('deposits a work correctly after uploading a zip file', () => {
      cy.visit(`/works/${work_id}/edit`)

      // select zipfile upload option
      cy.get('#work_upload_type_zipfile').check()

      // try to deposit
      cy.get('input.btn[value="Deposit"]', {force: true}).click()

      // there is a message telling us we need to upload a file
      cy.get('div.invalid-feedback').should('contain', 'You must attach a file')

      // now upload a file
      cy.get('#zip-files-panel div.dropzone').selectFile('cypress/fixtures/test.zip', {
        action: 'drag-drop'
      })

      // wait for the upload to finish
      cy.wait(1000)

      // now try to deposit again
      cy.get('input.btn[value="Deposit"]', {force: true}).click()

      // successful deposit!
      cy.url().should('include', `/works/${work_id}/next_step`)
      cy.contains('You have successfully deposited your work')
    })

    it('is not able to deposit when globus upload option is selected until user selects checkbox', () => {
      cy.visit(`/works/${work_id}/edit`)

      // try to deposit
      cy.get('input.btn[value="Deposit"]', {force: true}).click()

      // there is a message telling us we need to upload a file
      cy.get('div.invalid-feedback').should('contain', 'You must attach a file')

      // globus-specific message is not present
      cy.contains('Deposit is disabled until file transfer is complete.').should('not.be.visible')

      // now select globus upload option
      cy.get('#work_upload_type_globus').check()

      // globus-specific message appears
      cy.contains('Deposit is disabled until file transfer is complete.').should('be.visible')

      // deposit button should be disabled
      cy.get('input.btn[value="Deposit"]', {force: true}).should('be.disabled')

      // switch back to file upload option
      cy.get('#work_upload_type_browser').check()

      // deposit button should be enabled
      cy.get('input.btn[value="Deposit"]', {force: true}).should('be.enabled')

      // now select globus upload option again
      cy.get('#work_upload_type_globus').check()

      // and check all files upload checkbox
      cy.get('#work_fetch_globus_files').check()

      // deposit button should be enabled
      cy.get('input.btn[value="Deposit"]', {force: true}).should('be.enabled')
    })
})
