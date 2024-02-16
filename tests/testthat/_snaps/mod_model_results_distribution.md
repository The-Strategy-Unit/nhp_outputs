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
              <div class="form-group shiny-input-container">
                <div class="checkbox">
                  <label>
                    <input id="id-show_origin" type="checkbox" class="shiny-input-checkbox"/>
                    <span>Show Origin (zero)?</span>
                  </label>
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
            <h3 class="card-title">Beeswarm (model-run distribution)</h3>
          </div>
          <div class="card-body">
            The <span style="color:red">red dashed line</span> is the principal value (<!--html_preserve--><span id="id-p_bee" class="shiny-text-output"></span><!--/html_preserve-->) and the <span style="color:darkgrey">grey continuous line</span> is the baseline value (<!--html_preserve--><span id="id-b_bee" class="shiny-text-output"></span><!--/html_preserve-->)
            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-b48ec1189daabe57db8f00bbc7a75abd" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-beeswarm" style="width:100%;height:400px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Beeswarm (model-run distribution)","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">S-curve (empirical cumulative distribution function)</h3>
          </div>
          <div class="card-body">
            The <span style="color:red">red dashed line</span> is the principal value (<!--html_preserve--><span id="id-p_ecdf" class="shiny-text-output"></span><!--/html_preserve--> at <!--html_preserve--><span id="id-p_ecdf_pcnt" class="shiny-text-output"></span><!--/html_preserve-->), the <span style="color:darkgrey">grey dashed lines</span> are the 10th (<!--html_preserve--><span id="id-p10_ecdf" class="shiny-text-output"></span><!--/html_preserve-->) and the 90th (<!--html_preserve--><span id="id-p90_ecdf" class="shiny-text-output"></span><!--/html_preserve-->) percentiles and the <span style="color:darkgrey">grey continuous line</span> is the baseline value (<!--html_preserve--><span id="id-b_ecdf" class="shiny-text-output"></span><!--/html_preserve-->)
            <div class="shiny-spinner-output-container shiny-spinner-hideui ">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-12f18e766a1116015fed39b1b08fb463" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item" id="id-ecdf" style="width:100%;height:400px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"S-curve (empirical cumulative distribution function)","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

