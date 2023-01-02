describe('Date input', () => {
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
    })
  })

  it('date with year, month, and day is valid and can be saved', () => {
    cy.get('#work_published_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.year div.invalid-feedback').should('contain', '')
    cy.get('#work_published_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_published_day').select('4', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.year div.invalid-feedback').should('contain', '')

    cy.get('#save-draft-button').click()
    // This wait for the async turbo call to finish.
    cy.wait('@editButton')
    cy.url().should('not.include', `/works/${work_id}/edit`)
  })

  it('date with year and month is valid and can be saved', () => {
    cy.get('#work_published_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.year div.invalid-feedback').should('contain', '')
    cy.get('#work_published_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.year div.invalid-feedback').should('contain', '')

    cy.intercept('GET', `/works/${work_id}/edit_button`).as('postWorkPage')
    cy.get('#save-draft-button').click()
    // This wait for the async turbo call to finish.
    cy.wait('@editButton')
    cy.url().should('not.include', `/works/${work_id}/edit`)
  })

  it('date with year is valid and can be saved', () => {
    cy.get('#work_published_year').type('2021', {force: true}).not('have.class', 'is-invalid')
    cy.get('div.year div.invalid-feedback').should('contain', '')
    cy.get('div.year div.invalid-feedback').should('contain', '')

    cy.get('#save-draft-button').click()
    cy.wait('@editButton')
    cy.url().should('not.include', `/works/${work_id}/edit`)
  })

  it('future year is invalid', () => {
    // Year is in future
    cy.get('#work_published_year').type(now.getFullYear() + 1, {force: true}).should('have.class', 'is-invalid')
    cy.get('div.year div.invalid-feedback').should('contain', 'must be in the past')
  })

  it('future month is invalid', () => {
    // Month is 0 based.
    // Skip if this is December.
    if(now.getMonth() != 11) {
      cy.get('#work_published_year').type(now.getFullYear(), {force: true}).not('have.class', 'is-invalid')
      cy.get('#work_published_month').select((now.getMonth()+2).toString()).should('have.class', 'is-invalid')
      cy.get('div.year div.invalid-feedback').should('contain', 'must be in the past')
      cy.get('#work_published_year').should('have.class', 'is-invalid')
    }
  })

  it('future day is invalid', () => {
    // Skip if this is near the end of the month.
    if(now.getDate() < 30) {
      cy.get('#work_published_year').type(now.getFullYear(), {force: true}).not('have.class', 'is-invalid')
      cy.get('#work_published_month').select((now.getMonth()+1).toString(), {force: true}).not('have.class', 'is-invalid')
      cy.get('#work_published_day').select((now.getDate() + 1).toString(), {force: true}).should('have.class', 'is-invalid')
      cy.get('div.year div.invalid-feedback').should('contain', 'must be in the past')
      cy.get('#work_published_year').should('have.class', 'is-invalid')
      cy.get('#work_published_month').should('have.class', 'is-invalid')
    }
  })

  it('day that does not exist is invalid', () => {
    cy.get('#work_published_year').type('2022', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_published_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_published_day').select('30', {force: true}).should('have.class', 'is-invalid')
    cy.get('#work_published_month').should('have.class', 'is-invalid')
    cy.get('#work_published_year').should('have.class', 'is-invalid')
    cy.get('div.year div.invalid-feedback').should('contain', 'must be a valid day')
  })

  it('missing year is invalid', () => {
    cy.get('#work_published_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_published_day').select('15').not('have.class', 'is-invalid')
    cy.get('#work_published_month').not('have.class', 'is-invalid')
    cy.get('#work_published_year').should('have.class', 'is-invalid').should('have.attr', 'required')
    cy.get('div.year div.invalid-feedback').should('contain', '')
  })

  it('missing month is invalid', () => {
    cy.get('#work_published_year').type(now.getFullYear(), {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_published_day').select('15', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_published_month').should('have.class', 'is-invalid').should('have.attr', 'required')
    cy.get('div.year div.invalid-feedback').should('contain', '')
  })

  it('invalid date cannot be saved', () => {
    cy.get('#work_published_month').select('February', {force: true}).not('have.class', 'is-invalid')
    cy.get('#work_published_year').should('have.class', 'is-invalid').should('have.attr', 'required')

    cy.get('#save-draft-button').click()
    cy.url().should('include', '/edit')
  })
})
