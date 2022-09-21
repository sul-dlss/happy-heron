describe('Date range', () => {
  const now = new Date()
  let work_id

  beforeEach(() => {
    const results = cy.appFactories([
      ['create', 'work_version_with_work_and_collection', {} ]
    ]).then((results) => {
      work_id = results[0].work_id
      
      // This stubs out edit button calls.
      cy.intercept('GET', '**edit_button**', '').as('editButton')
      cy.visit(`/works/${work_id}/edit`)
      cy.get('#work_created_type').check({force: true})
    })
  })

  it('toggles between single date and date range', () => {
    cy.get('#work_created_range_start_year').should('be.visible').not('be.disabled')
    cy.get('#work_created_range_start_month').should('be.visible').not('be.disabled')
    cy.get('#work_created_range_start_day').should('be.visible').not('be.disabled')
    cy.get('#work_created_range_approx0_').should('be.visible').not('be.disabled')

    cy.get('#work_created_range_end_year').should('be.visible').not('be.disabled')
    cy.get('#work_created_range_end_month').should('be.visible').not('be.disabled')
    cy.get('#work_created_range_end_day').should('be.visible').not('be.disabled')
    cy.get('#work_created_range_approx3_').should('be.visible').not('be.disabled')

    cy.get('#work_created_year').not('be.visible').should('be.disabled')
    cy.get('#work_created_month').not('be.visible').should('be.disabled')
    cy.get('#work_created_day').not('be.visible').should('be.disabled')
    cy.get('#work_created_approx0_').not('be.visible').should('be.disabled')

    cy.get('#work_created_range_start_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_day').select('4', {force: true}).not('have.class', 'is-invalid')

    cy.get('#work_created_range_end_year').type('2022', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_month').select('March', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_day').select('5', {force: true}).not('have.class', 'is-invalid')

    cy.get('#work_created_type').uncheck({force: true})

    cy.get('#work_created_range_start_year').not('be.visible').should('be.disabled')
    cy.get('#work_created_range_start_month').not('be.visible').should('be.disabled')
    cy.get('#work_created_range_start_day').not('be.visible').should('be.disabled')
    cy.get('#work_created_range_approx0_').not('be.visible').should('be.disabled')

    cy.get('#work_created_range_end_year').not('be.visible').should('be.disabled')
    cy.get('#work_created_range_end_month').not('be.visible').should('be.disabled')
    cy.get('#work_created_range_end_day').not('be.visible').should('be.disabled')
    cy.get('#work_created_range_approx3_').not('be.visible').should('be.disabled')

    cy.get('#work_created_year').should('be.visible').not('be.disabled').should('have.value', '2021')
    cy.get('#work_created_month').should('be.visible').not('be.disabled').should('have.value', '2')
    cy.get('#work_created_day').should('be.visible').not('be.disabled').should('have.value', '4')
    cy.get('#work_created_approx0_').should('be.visible').should('be.disabled')
  })

  it('range with start and end date is valid and can be saved', () => {
    cy.get('#work_created_range_start_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_day').select('4', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', '')

    cy.get('#work_created_range_end_year').type('2022', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_month').select('March', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_day').select('5', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', '')

    cy.get('#save-draft-button').click({force: true})
    // This wait for the async turbo call to finish.
    cy.wait('@editButton')
    cy.url().should('not.include', `/works/${work_id}/edit`)
  })

  it('range without start date is invalid', () => {
    cy.get('#work_created_range_end_year').type('2022', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', '')
    cy.get('#work_created_range_start_year').should('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', 'start must be provided')
  })

  it('range without end date is invalid', () => {
    cy.get('#work_created_range_start_year').type('2022', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', '')
    cy.get('#work_created_range_end_year').should('have.class', 'is-invalid')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', 'end must be provided')
  })

  it('does not save invalid range', () => {
    cy.get('#work_created_range_start_year').type('2022', {force: true})
    cy.get('#work_created_range_end_year').should('have.class', 'is-invalid')

    cy.get('#save-draft-button').click({force: true})
    cy.url().should('include', `/works/${work_id}/edit`)

  })

  it('range invalid when start date same as end date, year only provided', () => {
    cy.get('#work_created_range_start_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_year').type('2021', {force: true}).not('have.class', 'is-invalid')

    cy.get('#work_created_range_start_year').should('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', 'start must be before end')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', '')
  })

  it('range invalid when start date same as end date, year and month only provided', () => {
    cy.get('#work_created_range_start_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_month').select('February', {force: true}).not('have.class', 'is-invalid')

    cy.get('#work_created_range_start_year').should('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').should('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', 'start must be before end')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', '')
  })

  it('range invalid when start date same as end date, year, month, and day provided', () => {
    cy.get('#work_created_range_start_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_day').select('4', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_day').select('4', {force: true}).not('have.class', 'is-invalid')

    cy.get('#work_created_range_start_year').should('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').should('have.class', 'is-invalid')
    cy.get('#work_created_range_start_day').should('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', 'start must be before end')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', '')
  })

  it('range invalid when start date after end date, year only provided', () => {
    cy.get('#work_created_range_start_year').type('2022', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_year').type('2021', {force: true}).not('have.class', 'is-invalid')

    cy.get('#work_created_range_start_year').should('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', 'start must be before end')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', '')
  })

  it('range invalid when start date after end date, year and month only provided', () => {
    cy.get('#work_created_range_start_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').select('March', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_month').select('February', {force: true}).not('have.class', 'is-invalid')

    cy.get('#work_created_range_start_year').should('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').should('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', 'start must be before end')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', '')
  })

  it('range invalid when start date after as end date, year, month, and day provided', () => {
    cy.get('#work_created_range_start_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_start_day').select('5', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_created_range_end_day').select('4', {force: true}).not('have.class', 'is-invalid')

    cy.get('#work_created_range_start_year').should('have.class', 'is-invalid')
    cy.get('#work_created_range_start_month').should('have.class', 'is-invalid')
    cy.get('#work_created_range_start_day').should('have.class', 'is-invalid')
    cy.get('div.start-date div.year div.invalid-feedback').should('contain', 'start must be before end')
    cy.get('div.end-date div.year div.invalid-feedback').should('contain', '')
  })
})