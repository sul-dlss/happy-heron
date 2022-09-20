describe('Clear dates', () => {
  const now = new Date()
  let work_id

  beforeEach(() => {
    const results = cy.appFactories([
      ['create', 'work_version_with_work_and_collection', {} ]
    ]).then((results) => {
      work_id = results[0].work_id
      
      cy.visit(`/works/${work_id}/edit`)
    })
  })

  it('clears single dates', () => {
    cy.get('#work_published_year').type('2021', {force: true}).should('have.value', '2021')
    cy.get('#work_published_month').select('February', {force: true}).should('have.value', '2')
    cy.get('#work_published_day').select('4', {force: true}).should('have.value', '4')

    cy.get('button[aria-label="Clear published date"]').click()

    cy.get('#work_published_year').should('have.value', '')
    cy.get('#work_published_month').should('have.value', '')
    cy.get('#work_published_day').should('have.value', '')

  })

  it('clears single approximate dates', () => {  
    cy.get('#work_created_year').type('2021', {force: true}).should('have.value', '2021')
    cy.get('#work_created_month').select('February', {force: true}).should('have.value', '2')
    cy.get('#work_created_approx0_').check({force: true}).should('be.checked')

    cy.get('button[aria-label="Clear created date"]').click()

    cy.get('#work_created_year').should('have.value', '')
    cy.get('#work_created_month').should('have.value', '')
    cy.get('#work_created_approx0_').not('be.checked')
  })

  it('clears date ranges', () => {
    cy.get('#work_created_type').check({force: true})

    cy.get('#work_created_range_start_year').type('2021', {force: true}).should('have.value', '2021')
    cy.get('#work_created_range_start_month').select('February', {force: true}).should('have.value', '2')
    cy.get('#work_created_range_start_day').select('4', {force: true}).should('have.value', '4')

    cy.get('#work_created_range_end_year').type('2022', {force: true}).should('have.value', '2022')
    cy.get('#work_created_range_end_month').select('March', {force: true}).should('have.value', '3')
    cy.get('#work_created_range_end_day').select('5', {force: true}).should('have.value', '5')

    cy.get('button[aria-label="Clear created date range"]').click()

    cy.get('#work_created_range_start_year').should('have.value', '')
    cy.get('#work_created_range_start_month').should('have.value', '')
    cy.get('#work_created_range_start_day').should('have.value', '')

    cy.get('#work_created_range_end_year').should('have.value', '')
    cy.get('#work_created_range_end_month').should('have.value', '')
    cy.get('#work_created_range_end_day').should('have.value', '')


  })
})