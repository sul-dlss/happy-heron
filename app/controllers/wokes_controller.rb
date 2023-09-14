class WokesController < ObjectsController
  def new
    @form = Forms::Work.new(collection_id: params[:collection_id])
  end

  def create
    @form = Forms::Work.new(work_params.merge(
      collection_id: params[:collection_id],
      depositor: current_user,
      owner: current_user
    ).merge(addl_params))

    if @form.save
      redirect_to work_path(@form.work)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    work = Work.find(params[:id])
    @form = Forms::Work.new_from_model(work)
  end

  def update
    @form = Forms::Work.new(work_params.merge(
      id: params[:id]
    ).merge(addl_params))

    if @form.save
      redirect_to work_path(@form.work)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def addl_params
    {
      work_type: "text", # Hardcoded for now
      license: "Apache-2.0",   # Hardcoded for now
      _deposit: deposit_button_pushed? # This indicates that full validation should be performed.
    }
  end

  def work_params
    params.require(:work).permit(
      :title, :abstract, :collection_id,
      contact_emails_attributes: [:id, :email, :_destroy],
      authors_attributes: contributor_attributes,
      contributors_attributes: contributor_attributes
    )
  end

  def contributor_attributes
    [
      :id, :first_name, :last_name, :_destroy,
      :full_name, :orcid, :role_term, :with_orcid, :weight,
      affiliations_attributes: [:id, :label, :uri, :department, :_destroy]
    ]
  end
end
