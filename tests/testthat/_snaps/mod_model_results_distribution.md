# ui is created correctly

    Code
      mod_model_results_distribution_ui("id")
    Output
      <h1>Distribution of projections: activity distribution</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header border-0">
            <h3 class="card-title"></h3>
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
        <script type="application/json">{"solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header border-0">
            <h3 class="card-title"></h3>
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
                <div id="spinner-c81c421b688934d6755397da8393b958" class="loader">Loading...</div>
              </div>
              <div class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme html-fill-item-overflow-hidden html-fill-item" id="id-distribution" style="width:100%;height:800px;"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

