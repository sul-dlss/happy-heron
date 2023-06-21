describe('Work type modal', () => {
  let collection_id

  beforeEach(() => {
    const results = cy.appFactories([
      ['create', 'collection_version_with_collection', {} ]
    ]).then((results) => {
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

  // clicking submit without select a work type leaves user on the work type options modal and not the new work form
  it('requires a work type', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('button[type="submit"]').click()
      cy.url().should('not.include', `/collections/${collection_id}/works.new`)
      cy.get('#text').should('exist')
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
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=mixed+material&subtype%5B%5D=3D+model&subtype%5B%5D=Working+paper`)
  })

  // the tests below show that you do not need to select a subtype for these work types and that clicking submit after
  //  selecting the work type indicated in the test allows you to immediately go to the new work form URL with no validation errors
  it('requires 0 subtypes for text type', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#text').click()
      cy.get('button[type="submit"]').click()
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=text`)
  })

  it('requires 0 subtypes for data type', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#data').click()
      cy.get('button[type="submit"]').click()
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=data`)
  })


  it('requires 0 subtypes for software type', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('input[type="radio"][value="software, multimedia"]').click()
      cy.get('button[type="submit"]').click()
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=software`)
  })

  it('requires 0 subtypes for image type', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#image').click()
      cy.get('button[type="submit"]').click()
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=image`)
  })

  it('requires 0 subtypes for sound type', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#sound').click()
      cy.get('button[type="submit"]').click()
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=sound`)
  })

  it('requires 0 subtypes for video type', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#video').click()
      cy.get('button[type="submit"]').click()
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=video`)
  })

  it('requires a manual entry for other type', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#other').click()
      cy.get('button[type="submit"]').click() // will stay on the work type modal window
      cy.get('#subtype_other').should('have.attr', 'required')  // the other textbox field is required, so you can't proceed without it
      cy.get('#subtype_other').type('cuneiform', {force: true}).should('have.value', 'cuneiform')
      cy.get('button[type="submit"]').click() // now will proceed to create the work
    })
    cy.url().should('include', `/collections/${collection_id}/works/new?work_type=other&subtype%5B%5D=cuneiform`)
  })

  it('expands text subtypes when more options clicked', () => {
    cy.get('#workTypeModal').within(() => {
      cy.get('#text').click()
      cy.get('.subtype-item:visible').should('have.length', 9) // has the correct number of top level subtypes for a text type
      cy.get('.more-options').click() // expand subtypes
      cy.get('.subtype-item:visible').should('have.length', 57) // has the correct number of all subtypes for a text type
      cy.get('.more-options').click() // collapse subtypes
      cy.get('.subtype-item:visible').should('have.length', 9) // back to fewer subtypes
    })
  })
})
