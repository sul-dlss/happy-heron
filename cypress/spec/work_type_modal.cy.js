describe('Clear dates', () => {
  // const now = new Date()
  let collection_id

  beforeEach(() => {
    const results = cy.appFactories([
      ['create', 'collection_version_with_collection', {} ]
    ]).then((results) => {
      console.log(results)
      collection_id = results[0].collection_id

      // This stubs out edit link calls.
      cy.intercept('GET', '**edit_link**', '').as('editLink')

      cy.visit(`/collections/${collection_id}`)
      // This wait for the async turbo call to finish.
      cy.wait('@editLink')
      cy.get(`button[data-destination="/collections/${collection_id}/works/new"]`).click()
      // This wait for the async turbo call to finish.
      cy.wait('@editLink')  
    })
  })

  it('requires 1 subtype for music', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#music').click()
      cy.get('button[type="submit"]').click()
      cy.get('div.subtype-item input').first().then(($input) => {
        cy.wrap($input).invoke('prop', 'validity')
        .should('deep.include', {
          valid: false,
          customError: true
        })
        cy.wrap($input).invoke('prop', 'validationMessage').should('equal', 'Please select 1 or more subtype options.')
      })
      cy.get('div.subtype-container[data-work-type-target="subtype"] div.subtype-item input').last().click()
      cy.get('button[type="submit"]').click()      
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=music&subtype%5B%5D=Video`)
  })

  it('requires 2 subtypes for mixed materials', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('input[value="mixed material"]').click()
      cy.get('button[type="submit"]').click()
      cy.get('div.subtype-item input').first().then(($input) => {
        cy.wrap($input).invoke('prop', 'validity')
        .should('deep.include', {
          valid: false,
          customError: true
        })
        cy.wrap($input).invoke('prop', 'validationMessage').should('equal', 'Please select 2 or more subtype options.')
      })
      cy.get('div.subtype-container[data-work-type-target="subtype"] div.subtype-item input').first().click()
      cy.get('div.subtype-container[data-work-type-target="subtype"] div.subtype-item input').last().click()
      cy.get('button[type="submit"]').click()      
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=mixed+material&subtype%5B%5D=Data&subtype%5B%5D=Video`)
  })

  it('requires 0 subtypes for other types', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#text').click()
      cy.get('button[type="submit"]').click()
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=text`)
  })

})