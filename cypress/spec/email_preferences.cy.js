describe('Email preferences', () => {
  let collection_id

  beforeEach(() => {
    const results = cy.appFactories([
      ['create', 'collection_version_with_collection', {} ]
    ]).then((results) => {
      collection_id = results[0].collection_id

      cy.visit(`/collections/${collection_id}/mail_preferences/edit`)
    })
  })

  it('selects all', () => {
    cy.get('#new_item').click().not('be.checked')
    cy.get('#submit_for_review').should('be.checked')

    cy.get('#selectAll').click()

    cy.get('#new_item').should('be.checked')
    cy.get('#submit_for_review').should('be.checked')

  })

  it('selects none', () => {
    cy.get('#new_item').click().not('be.checked')
    cy.get('#submit_for_review').should('be.checked')

    cy.get('#selectNone').click()

    cy.get('#new_item').not('be.checked')
    cy.get('#submit_for_review').not('be.checked')

  })

})