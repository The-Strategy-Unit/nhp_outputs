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
            <p>Bed days are defined as the difference in days between discharge and admission, plus one day.
      One bed day is added to account for zero length of stay spells/partial days at the beginning and end of a spell.
      See the <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site</a> for definitions of terms.</p>
      
            <p>
              Regard these results as rough, high-level estimates of the number of
              rows added/removed due to each parameter.
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
            <p>This chart shows the impacts of different factors on activity changes between the model baseline and in the model horizon years based on the principal projection.
      Note that:</p>
      <ul>
      <li>yellow bars are used to indicate the impact of factors which are increasing projected activity relative to the baseline year</li>
      <li>black bars are used to indicate the impact of factors which are reducing projected activity relative to the baseline year</li>
      <li>the red bar at the bottom of the chart shows the principal projection of activity in the horizon year</li>
      <li>the ‘model interaction term’ shows the effects of factors compounding within the model</li>
      </ul>
      <p>Note that the decomposition of activity changes over the model factors impact of changes should be viewed as indicative rather than precise exact figures.</p>
      
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="id-include_baseline" type="checkbox" class="shiny-input-checkbox" checked="checked"/>
                  <span>Include baseline?</span>
                </label>
              </div>
            </div>
            <div data-spinner-id="spinner-<id>" class="shiny-spinner-output-container shiny-spinner-hideui">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-<id>" class="loader">Loading...</div>
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
            <p>These bar charts display the estimated impact at the model horizon of each TPMA on avoiding activity.
      However they do not account for interaction effects between TPMAs caused by overlaps between some activity avoidance TPMA cohorts.
      This means that the impact attributed to each individual mitigator may be slightly overstated.
      The overall size of this interaction effect can be viewed in the ‘step_counts’ sheet of the Excel download of the results (see ‘Downloads’ in the sidebar).</p>
      
            <div class="form-group shiny-input-container">
              <label class="control-label" id="id-sort_type-label" for="id-sort_type">Sort By</label>
              <div>
                <select id="id-sort_type" class="shiny-input-select"><option value="Descending value" selected>Descending value</option>
      <option value="Alphabetical">Alphabetical</option></select>
                <script type="application/json" data-for="id-sort_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div data-spinner-id="spinner-<id>" class="shiny-spinner-output-container shiny-spinner-hideui">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-<id>" class="loader">Loading...</div>
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

