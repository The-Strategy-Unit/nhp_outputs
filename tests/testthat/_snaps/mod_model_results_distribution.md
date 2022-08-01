# ui is created correctly

    Code
      mod_model_results_distribution_ui("id")
    Output
      <h1>Simulation Results</h1>
      <div class="row">
        <div class="col-sm-4">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-measure_selection-activity_type-label" for="id-measure_selection-activity_type">Activity Type</label>
            <div>
              <select id="id-measure_selection-activity_type"></select>
              <script type="application/json" data-for="id-measure_selection-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-measure_selection-pod-label" for="id-measure_selection-pod">Point of Delivery</label>
            <div>
              <select id="id-measure_selection-pod"></select>
              <script type="application/json" data-for="id-measure_selection-pod" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
        <div class="col-sm-4">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-measure_selection-measure-label" for="id-measure_selection-measure">Measure</label>
            <div>
              <select id="id-measure_selection-measure"></select>
              <script type="application/json" data-for="id-measure_selection-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
      </div>
      <div class="form-group shiny-input-container">
        <div class="checkbox">
          <label>
            <input id="id-show_origin" type="checkbox"/>
            <span>Show Origin (zero)?</span>
          </label>
        </div>
      </div>
      <div class="shiny-spinner-output-container shiny-spinner-hideui ">
        <div class="load-container shiny-spinner-hidden load1">
          <div id="spinner-a71b5978ac666a965ce98a74cc882b7a" class="loader">Loading...</div>
        </div>
        <div id="id-distribution" style="width:100%; height:800px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
      </div>

