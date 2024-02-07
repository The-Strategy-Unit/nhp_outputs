# ui is created correctly

    Code
      mod_model_results_distribution_ui("id")
    Output
      <h1>Distribution of projections: activity distribution</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Notes</h3>
          </div>
          <div class="card-body">
            <p>
              Data is shown at trust level unless sites are selected from the 'Home' tab.
              A&amp;E results are not available at site level.
              See the
              <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site</a>
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
                  <label class="control-label" id="id-measure_selection-activity_type-label" for="id-measure_selection-activity_type">Activity Type</label>
                  <div>
                    <select id="id-measure_selection-activity_type" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-measure_selection-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                  </div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group shiny-input-container">
                  <label class="control-label" id="id-measure_selection-pod-label" for="id-measure_selection-pod">Point of Delivery</label>
                  <div>
                    <select id="id-measure_selection-pod" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-measure_selection-pod" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                  </div>
                </div>
              </div>
              <div class="col-sm-4">
                <div class="form-group shiny-input-container">
                  <label class="control-label" id="id-measure_selection-measure-label" for="id-measure_selection-measure">Measure</label>
                  <div>
                    <select id="id-measure_selection-measure" class="shiny-input-select"></select>
                    <script type="application/json" data-for="id-measure_selection-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
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
            <h3 class="card-title">Density</h3>
          </div>
          <div class="card-body">
            <div class="form-group shiny-input-container">
              <div class="checkbox">
                <label>
                  <input id="id-show_origin" type="checkbox" class="shiny-input-checkbox"/>
                  <span>Show Origin (zero)?</span>
                </label>
              </div>
            </div>
            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-a83147027a00fa8812473aa2d1142727" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-distribution" style="width:100%;height:800px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Density","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Empirical Cumulative Distribution</h3>
          </div>
          <div class="card-body">
            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-12f18e766a1116015fed39b1b08fb463" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-ecdf" style="width:100%;height:400px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Empirical Cumulative Distribution","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

