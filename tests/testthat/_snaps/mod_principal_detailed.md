# ui is created correctly

    Code
      mod_principal_detailed_ui("id")
    Output
      <h1>Principal projection: activity in detail</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Notes</h3>
          </div>
          <div class="card-body"><p>Bed days are defined as the difference in days between discharge and admission, plus one day.
      One bed day is added to account for zero length of stay spells/partial days at the beginning and end of a spell.
      See the <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site</a> for definitions of terms.</p>
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
                  <label class="control-label" id="id-measure_selection-activity_type-label" for="id-measure_selection-activity_type">Activity Type</label>
                  <div>
                    <select id="id-measure_selection-activity_type" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-measure_selection-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                  </div>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group shiny-input-container">
                  <label class="control-label" id="id-measure_selection-pod-label" for="id-measure_selection-pod">Point of Delivery</label>
                  <div>
                    <select id="id-measure_selection-pod" class="shiny-input-select" multiple="multiple"></select>
                    <script type="application/json" data-for="id-measure_selection-pod">{"plugins":["selectize-plugin-a11y"]}</script>
                  </div>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group shiny-input-container">
                  <label class="control-label" id="id-measure_selection-measure-label" for="id-measure_selection-measure">Measure</label>
                  <div>
                    <select id="id-measure_selection-measure" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-measure_selection-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                  </div>
                </div>
              </div>
              <div class="col-sm-3">
                <div class="form-group shiny-input-container">
                  <label class="control-label" id="id-aggregation-label" for="id-aggregation">Show Results By</label>
                  <div>
                    <select id="id-aggregation" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-aggregation" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
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
            <h3 class="card-title">Activity by sex and age or treatment specialty</h3>
          </div>
          <div class="card-body">
            <div data-spinner-id="spinner-c035842a1e32484a3ac51311d84d605f" class="shiny-spinner-output-container shiny-spinner-hideui">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-c035842a1e32484a3ac51311d84d605f" class="loader">Loading...</div>
              </div>
              <div style="height:400px" class="shiny-spinner-placeholder"></div>
              <div class="shiny-html-output gt_shiny" id="id-results"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Activity by sex and age or treatment specialty","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

