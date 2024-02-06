# ui is created correctly

    Code
      mod_model_results_capacity_ui("id")
    Output
      <h1>Distribution of projections: capacity requirements distribution</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Notes</h3>
          </div>
          <div class="card-body">
            <p>
              Data is shown at trust level unless sites are selected from the 'Home' tab.
              See the
              <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site</a>
              for definitions of terms, along with the
              <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information/modelling_methodology/capacity_conversion/beds.html">calculation for beds.</a>
            </p>
          </div>
        </div>
        <script type="application/json">{"title":"Notes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Make selections</h3>
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
          </div>
        </div>
        <script type="application/json">{"title":"Make selections","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Density (beds)</h3>
          </div>
          <div class="card-body">
            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-4016b9eb5f929a3b7f7e0ca09908161f" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-beds" style="width:100%;height:800px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Density (beds)","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Empirical cumulative distribution (beds)</h3>
          </div>
          <div class="card-body">
            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-3e7a7c27777fa6948f1cadaa59af9556" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-beds_ecdf" style="width:100%;height:400px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Empirical cumulative distribution (beds)","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

