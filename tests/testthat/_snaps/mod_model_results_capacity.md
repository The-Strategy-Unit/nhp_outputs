# ui is created correctly

    Code
      mod_model_results_capacity_ui("id")
    Output
      <h1>Distribution of projections: capacity requirements distribution</h1>
      <div class="row">
        <div class="col-sm-12">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Beds</h3>
              <div class="card-tools float-right">
                <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                  <i class="fas fa-minus" role="presentation" aria-label="minus icon"></i>
                </button>
              </div>
            </div>
            <div class="card-body">
              <div class="row">
                <div class="col-sm-3">
                  <div class="form-group shiny-input-container">
                    <label class="control-label" id="id-beds_quarter-label" for="id-beds_quarter">Quarter</label>
                    <div>
                      <select id="id-beds_quarter" class="shiny-input-select"><option value="q1" selected>Q1</option>
      <option value="q2">Q2</option>
      <option value="q3">Q3</option>
      <option value="q4">Q4</option></select>
                      <script type="application/json" data-for="id-beds_quarter" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                    </div>
                  </div>
                </div>
                <div class="col-sm-3">
                  <div class="form-group shiny-input-container">
                    <label class="control-label" id="id-beds_ward_type-label" for="id-beds_ward_type">Ward Type</label>
                    <div>
                      <select id="id-beds_ward_type" class="shiny-input-select"></select>
                      <script type="application/json" data-for="id-beds_ward_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                    </div>
                  </div>
                </div>
              </div>
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-47cb56358f5f381d24443e735b9811da" class="loader">Loading...</div>
                </div>
                <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-beds" style="width:100%;height:800px;"></div>
              </div>
            </div>
          </div>
          <script type="application/json">{"title":"Beds","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
      </div>

