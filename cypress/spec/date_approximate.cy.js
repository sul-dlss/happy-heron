describe('Date approximate', () => {
  const now = new Date()
  
  beforeEach(() => {
    const results = cy.appFactories([
      ['create', 'work_version_with_work_and_collection', {} ]
    ]).then((results) => {
      const work_id = results[0].work_id      
      cy.visit(`/works/${work_id}/edit`)
    })
  })

  it('day disabled if approximate checked', () => {
    cy.get('#work_created_approx0_').check({force: true})
    cy.get('#work_created_day').should('have.prop', 'disabled', true)
    cy.get('#work_created_approx0_').uncheck({force: true})
    cy.get('#work_created_day').should('have.prop', 'disabled', false)
  })

  it('approximate disabled if day selected', () => {
    cy.get('#work_created_day').select('4', {force: true})
    cy.get('#work_created_approx0_').should('have.prop', 'disabled', true)
    cy.get('#work_created_day').select('', {force: true})
    cy.get('#work_created_approx0_').should('have.prop', 'disabled', false)
  })
})