# ui is created correctly

    Code
      mod_principal_change_factor_effects_ui("id")
    Output
      <h1>Principal projection: impact of changes</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header border-0">
            <h3 class="card-title"></h3>
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
                  <label class="control-label" id="id-measure-label" for="id-measure">Measure</label>
                  <div>
                    <select id="id-measure" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                  </div>
                </div>
              </div>
              <div class="form-group shiny-input-container">
                <div class="checkbox">
                  <label>
                    <input id="id-include_baseline" type="checkbox" class="shiny-input-checkbox" checked="checked"/>
                    <span>Include baseline?</span>
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>
        <script type="application/json">{"solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Impact of Changes</h3>
          </div>
          <div class="card-body">
            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-e50b7789e5c6936391faab18e81a96e7" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-change_factors" style="width:100%;height:600px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Impact of Changes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Individual Change Factors</h3>
          </div>
          <div class="card-body">
            <div class="form-group shiny-input-container">
              <label class="control-label" id="id-sort_type-label" for="id-sort_type">Sort By</label>
              <div>
                <select id="id-sort_type" class="shiny-input-select"><option value="alphabetical" selected>alphabetical</option>
      <option value="descending value">descending value</option></select>
                <script type="application/json" data-for="id-sort_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
              </div>
            </div>
            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-7fe157d749ee969d53dc2207c0ebf017" class="loader">Loading...</div>
              </div>
              <div class="row">
                <div class="col-sm-6">
                  <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-activity_avoidance" style="width:100%;height:600px;"></div>
                </div>
                <div class="col-sm-6">
                  <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-efficiencies" style="width:100%;height:600px;"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Individual Change Factors","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

