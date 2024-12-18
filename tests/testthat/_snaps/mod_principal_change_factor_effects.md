# ui is created correctly

    Code
      mod_principal_change_factor_effects_ui("id")
    Output
      <h1>Principal projection: impact of changes</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Notes</h3>
          </div>
          <div class="card-body">
            <p>
              These results should be regarded as rough, high-level estimates of the number of rows added/removed due to each parameter.
              Bed days are defined as the difference in days between discharge and admission, plus one day.
              One bed day is added to account for zero length of stay spells/partial days at the beginning and end of a spell.
              See the
              <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information/user_guide/glossary.html">model project information site</a>
              for definitions of terms.
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
              <div class="col-sm-4">
                <div class="form-group shiny-input-container">
                  <label class="control-label" id="id-activity_type-label" for="id-activity_type">Activity Type</label>
                  <div>
                    <select id="id-activity_type" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                  </div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group shiny-input-container">
                  <label class="control-label" id="id-pods-label" for="id-pods">Point of Delivery</label>
                  <div>
                    <select id="id-pods" class="shiny-input-select" multiple="multiple"></select>
                    <script type="application/json" data-for="id-pods">{"plugins":["selectize-plugin-a11y"]}</script>
                  </div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group shiny-input-container">
                  <label class="control-label" id="id-measure-label" for="id-measure">Measure</label>
                  <div>
                    <select id="id-measure" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
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
            <h3 class="card-title">Impact of changes</h3>
          </div>
          <div class="card-body">
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="id-include_baseline" type="checkbox" class="shiny-input-checkbox" checked="checked"/>
                  <span>Include baseline?</span>
                </label>
              </div>
            </div>
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="id-redistribute_model_interaction_term" type="checkbox" class="shiny-input-checkbox" checked="checked"/>
                  <span>Redistribute Model Interaction Term?</span>
                </label>
              </div>
            </div>
            <div data-spinner-id="spinner-fac52137bd9b9ca575e47193636bb3fb" class="shiny-spinner-output-container shiny-spinner-hideui">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-fac52137bd9b9ca575e47193636bb3fb" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-change_factors" style="width:100%;height:600px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Impact of changes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Individual change factors</h3>
          </div>
          <div class="card-body">
            <div class="form-group shiny-input-container">
              <label class="control-label" id="id-sort_type-label" for="id-sort_type">Sort By</label>
              <div>
                <select id="id-sort_type" class="shiny-input-select"><option value="Descending value" selected>Descending value</option>
      <option value="Alphabetical">Alphabetical</option></select>
                <script type="application/json" data-for="id-sort_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div data-spinner-id="spinner-02d712da1fde4b737e463658c00feed6" class="shiny-spinner-output-container shiny-spinner-hideui">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-02d712da1fde4b737e463658c00feed6" class="loader">Loading...</div>
              </div>
              <div class="row">
                <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-activity_avoidance" style="width:100%;height:600px;"></div>
                <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-efficiencies" style="width:100%;height:600px;"></div>
              </div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Individual change factors","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

