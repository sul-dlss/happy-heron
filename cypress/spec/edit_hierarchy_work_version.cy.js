describe('Create work version', () => {
  let work_id

  beforeEach(() => {
    const results = cy.appFactories([
      ['create', 'work_version_with_work_and_collection', 'with_required_associations', 'with_hierachical_files' ]
    ]).then((results) => {
      cy.log(results[0])
      work_id = results[0].work_id
    })
  })

  it('deposits a work correctly after uploading a file', () => {
    cy.visit(`/works/${work_id}/edit`)

    // Hierarchy is displayed
    cy.get('.file-level strong').should('contain', 'dir1')
    cy.get('.file-level strong').should('contain', 'dir2')
    cy.get('.file-level').should('contain', 'sul.svg')
    
    // Add a file to root.
    cy.get('[data-dropzone-previews-container=".dropzone-files-previews"] > fieldset > div.dropzone', {force: true}).selectFile('cypress/fixtures/test.txt', {
      action: 'drag-drop'
    })

    // wait for the upload to finish
    cy.wait(1000)
    cy.get('.dz-success-mark').should('have.length', 1)
    
    
    // Add a file to dir1.
    cy.get('[data-show-id-value="dropzone-dir-1-row"]').click()
    cy.get('[data-dropzone-previews-container=".dropzone-dir-1-previews"] > fieldset > div.dropzone', {force: true}).selectFile('cypress/fixtures/test.txt', {
      action: 'drag-drop'
    })

    // wait for the upload to finish
    cy.wait(1000)
    cy.get('.dz-success-mark').should('have.length', 2)

    // Upload a duplicate file to dir1.
    cy.get('[data-dropzone-previews-container=".dropzone-dir-1-previews"] > fieldset > div.dropzone', {force: true}).selectFile('cypress/fixtures/test.txt', {
      action: 'drag-drop'
    })

    cy.wait(1000)
    cy.contains('Duplicate file')
  })
})
