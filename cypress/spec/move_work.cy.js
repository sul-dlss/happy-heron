describe('Move work to a new collection', () => {
  before(() => {
    cy.app('clean')
    cy.appFactories([
      ['create', 'collection_version_with_collection', {collection_druid: 'druid:bc123df4568', doi_option: 'yes'} ],
      ['create', 'collection_version_with_collection', {collection_druid: 'druid:bc123df4569', doi_option: 'depositor-selects'} ]
    ])
  })

  beforeEach(() => {
    const results = cy.appFactories([
      ['create', 'work_version_with_work_and_collection', {} ]
    ]).then((results) => {
      const work_id = results[0].work_id

      // This stubs out edit button calls.
      cy.intercept('GET', '**edit_button**', '').as('editButton')

      cy.visit(`/works/${work_id}`)
      // This wait for the async turbo call to finish.
      cy.wait('@editButton')
      cy.get('#adminFunctionsSelect').select(`/works/${work_id}/move/edit`, {force: true})
    })
  })

  describe('When no results', () => {
    it('displays message', () => {
      cy.get('#druid').type('druid:bc123d')
      cy.get('#workAdminSection').not('include.text', 'No search results found')
      cy.get('#druid').type('f4567')
      cy.get('#workAdminSection').should('include.text', 'No search results found')
      cy.get('input[type="submit"]').should('be.disabled')
    })  
  })

  describe('When work cannot be moved to collection', () => {
    it('displays message', () => {
      cy.get('#druid').type('druid:bc123df4568')
      cy.get('#workAdminSection').should('include.text', 'MyString')
      cy.get('#workAdminSection').should('include.text', 'Cannot move to this collection')
      cy.get('input[type="submit"]').should('be.disabled')
    })  
  })

  describe('When work can be moved to collection', () => {
    it('displays message', () => {
      cy.get('#druid').type('druid:bc123df4569')
      cy.get('#workAdminSection').should('include.text', 'MyString')
      cy.get('input[type="submit"]').not('be.disabled')
    })  
  })
})