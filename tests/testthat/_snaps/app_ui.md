# ui is created correctly

    Code
      app_ui()
    Output
      <body data-help="0" data-fullscreen="0" data-dark="1" data-scrollToTop="0">
        <div class="wrapper">
          <nav data-fixed="false" class="main-header navbar navbar-expand navbar-white navbar-light">
            <ul class="navbar-nav">
              <li class="nav-item">
                <a class="nav-link" data-widget="pushmenu" href="#">
                  <i class="fa fa-bars" role="presentation" aria-label="bars icon"></i>
                </a>
              </li>
            </ul>
            <ul class="navbar-nav ml-auto navbar-right">
              <li class="nav-item">
                <a id="controlbar-toggle" class="nav-link" data-widget="control-sidebar" href="#">
                  <i class="fa fa-th" role="presentation" aria-label="th icon"></i>
                </a>
              </li>
            </ul>
          </nav>
          <aside id="sidebarId" data-fixed="true" data-minified="true" data-collapsed="false" data-disable="FALSE" class="main-sidebar sidebar-light-primary elevation-4">
            <div class="brand-link">NHP Model Results</div>
            <div class="sidebar" id="sidebarItemExpanded">
              <nav class="mt-2">
                <ul class="nav nav-pills nav-sidebar flex-column sidebar-menu nav-child-indent" data-widget="treeview" role="menu" data-accordion="true">
                  <li class="nav-item">
                    <a class="nav-link" id="tab-tab_home" href="#" data-target="#shiny-tab-tab_home" data-toggle="tab" data-value="tab_home">
                      <i class="fa fa-home nav-icon" role="presentation" aria-label="home icon"></i>
                      <p>Home</p>
                    </a>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Principal Projection
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="PrincipalProjection">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_phl" href="#" data-target="#shiny-tab-tab_phl" data-toggle="tab" data-value="tab_phl">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>High Level</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pd" href="#" data-target="#shiny-tab-tab_pd" data-toggle="tab" data-value="tab_pd">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Detailed</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pcf" href="#" data-target="#shiny-tab-tab_pcf" data-toggle="tab" data-value="tab_pcf">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Change Factors</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Model Results
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="ModelResults">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_mc" href="#" data-target="#shiny-tab-tab_mc" data-toggle="tab" data-value="tab_mc">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Core Activity</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_md" href="#" data-target="#shiny-tab-tab_md" data-toggle="tab" data-value="tab_md">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Results Distribution</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Capacity Conversion
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="CapacityConversion">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_cb" href="#" data-target="#shiny-tab-tab_cb" data-toggle="tab" data-value="tab_cb">
                          <i class="fa fa-angle-double-right" role="presentation" aria-label="angle-double-right icon" cl="fa fa-angle-double-right nav-icon"></i>
                          <p>Beds</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <hr/>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Run Model
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="RunModel">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_up" href="#" data-target="#shiny-tab-tab_up" data-toggle="tab" data-value="tab_up">
                          <i class="fa fa-sliders-h" role="presentation" aria-label="sliders-h icon" cl="fa fa-sliders-h nav-icon"></i>
                          <p>Upload Params</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_rm" href="#" data-target="#shiny-tab-tab_rm" data-toggle="tab" data-value="tab_rm">
                          <i class="fa fa-running" role="presentation" aria-label="running icon" cl="fa fa-running nav-icon"></i>
                          <p>Running Models</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <div id="sidebarMenu" class="sidebarMenuSelectedTabItem" data-value="null"></div>
                </ul>
              </nav>
            </div>
          </aside>
          <div class="content-wrapper">
            <section class="content">
              <div class="tab-content">
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_home">
                  <div class="row">
                    <div class="col-sm-6">
                      <h1>NHP Model</h1>
                    </div>
                    <div class="col-sm-6">
                      <div class="card bs4Dash">
                        <div class="card-header">
                          <h3 class="card-title">Results Selection</h3>
                          <div class="card-tools float-right">
                            <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                              <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                            </button>
                          </div>
                        </div>
                        <div class="card-body">
                          <div class="form-group shiny-input-container">
                            <label class="control-label" id="result_selection-dataset-label" for="result_selection-dataset">Dataset</label>
                            <div>
                              <select id="result_selection-dataset"></select>
                              <script type="application/json" data-for="result_selection-dataset" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                            </div>
                          </div>
                          <div class="form-group shiny-input-container">
                            <label class="control-label" id="result_selection-scenario-label" for="result_selection-scenario">Scenario</label>
                            <div>
                              <select id="result_selection-scenario"></select>
                              <script type="application/json" data-for="result_selection-scenario" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                            </div>
                          </div>
                          <div class="form-group shiny-input-container">
                            <label class="control-label" id="result_selection-create_datetime-label" for="result_selection-create_datetime">Model Run Time</label>
                            <div>
                              <select id="result_selection-create_datetime"></select>
                              <script type="application/json" data-for="result_selection-create_datetime" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                            </div>
                          </div>
                        </div>
                      </div>
                      <script type="application/json">{"title":"Results Selection","solidHeader":true,"width":6,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_up">
                  <div class="col-sm-12">
                    <div class="card bs4Dash">
                      <div class="card-header">
                        <h3 class="card-title">Upload File</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <div class="form-group shiny-input-container">
                          <label class="control-label" id="params_upload_ui-params_upload-label" for="params_upload_ui-params_upload">Upload Params Excel File</label>
                          <div class="input-group">
                            <label class="input-group-btn input-group-prepend">
                              <span class="btn btn-default btn-file">
                                Browse...
                                <input id="params_upload_ui-params_upload" name="params_upload_ui-params_upload" type="file" style="position: absolute !important; top: -99999px !important; left: -99999px !important;" accept=".xlsx"/>
                              </span>
                            </label>
                            <input type="text" class="form-control" placeholder="No file selected" readonly="readonly"/>
                          </div>
                          <div id="params_upload_ui-params_upload_progress" class="progress active shiny-file-input-progress">
                            <div class="progress-bar"></div>
                          </div>
                        </div>
                        <div id="params_upload_ui-status" class="shiny-text-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Upload File","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12 shinyjs-disabled">
                    <div class="card bs4Dash card-outline-tabs" id="params_box">
                      <div class="card-header p-0 border-bottom-0">
                        <ul class="nav nav-pills shiny-tab-input" id="params" data-tabsetid="4344">
                          <li class="nav-item">
                            <a href="#" data-toggle="tab" data-value="Run Settings" class="nav-link active" data-target="#tab-4344-1">Run Settings</a>
                          </li>
                          <li class="nav-item">
                            <a href="#" data-toggle="tab" data-value="Demographics" class="nav-link" data-target="#tab-4344-2">Demographics</a>
                          </li>
                          <li class="nav-item">
                            <a href="#" data-toggle="tab" data-value="Health Status Adjustment" class="nav-link" data-target="#tab-4344-3">Health Status Adjustment</a>
                          </li>
                          <li class="nav-item">
                            <a href="#" data-toggle="tab" data-value="IP Activity Mitigators" class="nav-link" data-target="#tab-4344-4">IP Activity Mitigators</a>
                          </li>
                          <li class="nav-item">
                            <a href="#" data-toggle="tab" data-value="OP Activity Mitigators" class="nav-link" data-target="#tab-4344-5">OP Activity Mitigators</a>
                          </li>
                          <li class="nav-item">
                            <a href="#" data-toggle="tab" data-value="AAE Activity Mitigators" class="nav-link" data-target="#tab-4344-6">AAE Activity Mitigators</a>
                          </li>
                          <li class="pt-2 px-3">
                            <h3 class="card-title"></h3>
                          </li>
                          <li class="ml-auto"></li>
                        </ul>
                      </div>
                      <div class="card-body">
                        <div class="tab-content" data-tabsetid="4344">
                          <div class="tab-pane active" data-value="Run Settings" id="tab-4344-1">
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-start_year-label" for="params_upload_ui-start_year">Start Year</label>
                              <input id="params_upload_ui-start_year" type="text" class="form-control" value=""/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-end_year-label" for="params_upload_ui-end_year">End Year</label>
                              <input id="params_upload_ui-end_year" type="text" class="form-control" value=""/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-model_iterations-label" for="params_upload_ui-model_iterations">Model Iterations</label>
                              <input id="params_upload_ui-model_iterations" type="text" class="form-control" value=""/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-user-label" for="params_upload_ui-user">Submitting User</label>
                              <input id="params_upload_ui-user" type="text" class="form-control" value=""/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-dataset-label" for="params_upload_ui-dataset">Dataset</label>
                              <div>
                                <select id="params_upload_ui-dataset"></select>
                                <script type="application/json" data-for="params_upload_ui-dataset" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                              </div>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-demographics_file-label" for="params_upload_ui-demographics_file">Demographics File</label>
                              <div>
                                <select id="params_upload_ui-demographics_file"><option value="demographic_factors.csv" selected>default</option></select>
                                <script type="application/json" data-for="params_upload_ui-demographics_file" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                              </div>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-scenario_name-label" for="params_upload_ui-scenario_name">Scenario Name</label>
                              <input id="params_upload_ui-scenario_name" type="text" class="form-control" value=""/>
                            </div>
                            <button class="btn btn-default action-button shinyjs-disabled" id="params_upload_ui-submit_model_run" type="button">Submit Model Run</button>
                            <a class="btn btn-default shiny-download-link  shinyjs-disabled" download href="" id="params_upload_ui-download_params" target="_blank">
                              <i class="fa fa-download" role="presentation" aria-label="download icon"></i>
                              Download params.json
                            </a>
                          </div>
                          <div class="tab-pane" data-value="Demographics" id="tab-4344-2">
                            <h4>Population Model Variant Probabilities</h4>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-demo_principal-label" for="params_upload_ui-demo_principal">Principal</label>
                              <input id="params_upload_ui-demo_principal" type="text" class="form-control" value=""/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-demo_high_migration-label" for="params_upload_ui-demo_high_migration">High Migration</label>
                              <input id="params_upload_ui-demo_high_migration" type="text" class="form-control" value=""/>
                            </div>
                          </div>
                          <div class="tab-pane" data-value="Health Status Adjustment" id="tab-4344-3">
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-hsa_lo-label" for="params_upload_ui-hsa_lo">Low Estimate (5th Percentile)</label>
                              <input id="params_upload_ui-hsa_lo" type="text" class="form-control" value=""/>
                            </div>
                            <div class="form-group shiny-input-container">
                              <label class="control-label" id="params_upload_ui-hsa_hi-label" for="params_upload_ui-hsa_hi">High Estimate (95th Percentile)</label>
                              <input id="params_upload_ui-hsa_hi" type="text" class="form-control" value=""/>
                            </div>
                          </div>
                          <div class="tab-pane" data-value="IP Activity Mitigators" id="tab-4344-4">
                            <div class="col-sm-12">
                              <div class="card bs4Dash">
                                <div class="card-header">
                                  <h3 class="card-title">Activity Avoidance</h3>
                                </div>
                                <div class="card-body">
                                  <div class="form-group shiny-input-container">
                                    <label class="control-label" id="params_upload_ui-ip_am_a-label" for="params_upload_ui-ip_am_a">Change Factor</label>
                                    <div>
                                      <select id="params_upload_ui-ip_am_a"></select>
                                      <script type="application/json" data-for="params_upload_ui-ip_am_a" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                                    </div>
                                  </div>
                                  <div class="row">
                                    <div class="col-sm-6">
                                      <div class="form-group shiny-input-container">
                                        <label class="control-label" id="params_upload_ui-ip_am_a_lo-label" for="params_upload_ui-ip_am_a_lo">Low Estimate (5th Percentile)</label>
                                        <input id="params_upload_ui-ip_am_a_lo" type="text" class="form-control" value=""/>
                                      </div>
                                    </div>
                                    <div class="col-sm-6">
                                      <div class="form-group shiny-input-container">
                                        <label class="control-label" id="params_upload_ui-ip_am_a_hi-label" for="params_upload_ui-ip_am_a_hi">High Estimate (85th Percentile)</label>
                                        <input id="params_upload_ui-ip_am_a_hi" type="text" class="form-control" value=""/>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                              <script type="application/json">{"title":"Activity Avoidance","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                            </div>
                            <div class="col-sm-12">
                              <div class="card bs4Dash">
                                <div class="card-header">
                                  <h3 class="card-title">Type Convesion (BADS)</h3>
                                </div>
                                <div class="card-body">
                                  <div class="form-group shiny-input-container">
                                    <label class="control-label" id="params_upload_ui-ip_am_tc_bads-label" for="params_upload_ui-ip_am_tc_bads">Change Factor</label>
                                    <div>
                                      <select id="params_upload_ui-ip_am_tc_bads"></select>
                                      <script type="application/json" data-for="params_upload_ui-ip_am_tc_bads" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                                    </div>
                                  </div>
                                  <div class="row">
                                    <div class="col-sm-3">
                                      <div class="form-group shiny-input-container">
                                        <label class="control-label" id="params_upload_ui-ip_am_tc_bads_br-label" for="params_upload_ui-ip_am_tc_bads_br">Baseline Rate</label>
                                        <input id="params_upload_ui-ip_am_tc_bads_br" type="text" class="form-control" value=""/>
                                      </div>
                                    </div>
                                    <div class="col-sm-3">
                                      <div class="form-group shiny-input-container">
                                        <label class="control-label" id="params_upload_ui-ip_am_tc_bads_split-label" for="params_upload_ui-ip_am_tc_bads_split">Split (OP:DC)</label>
                                        <input id="params_upload_ui-ip_am_tc_bads_split" type="text" class="form-control" value=""/>
                                      </div>
                                    </div>
                                    <div class="col-sm-3">
                                      <div class="form-group shiny-input-container">
                                        <label class="control-label" id="params_upload_ui-ip_am_tc_bads_lo-label" for="params_upload_ui-ip_am_tc_bads_lo">Low Estimate (5th Percentile)</label>
                                        <input id="params_upload_ui-ip_am_tc_bads_lo" type="text" class="form-control" value=""/>
                                      </div>
                                    </div>
                                    <div class="col-sm-3">
                                      <div class="form-group shiny-input-container">
                                        <label class="control-label" id="params_upload_ui-ip_am_tc_bads_hi-label" for="params_upload_ui-ip_am_tc_bads_hi">High Estimate (85th Percentile)</label>
                                        <input id="params_upload_ui-ip_am_tc_bads_hi" type="text" class="form-control" value=""/>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                              <script type="application/json">{"title":"Type Convesion (BADS)","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                            </div>
                            <div class="col-sm-12">
                              <div class="card bs4Dash">
                                <div class="card-header">
                                  <h3 class="card-title">Efficiencies</h3>
                                </div>
                                <div class="card-body">
                                  <div class="form-group shiny-input-container">
                                    <label class="control-label" id="params_upload_ui-ip_am_e-label" for="params_upload_ui-ip_am_e">Change Factor</label>
                                    <div>
                                      <select id="params_upload_ui-ip_am_e"></select>
                                      <script type="application/json" data-for="params_upload_ui-ip_am_e" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                                    </div>
                                  </div>
                                  <div class="row">
                                    <div class="col-sm-6">
                                      <div class="form-group shiny-input-container">
                                        <label class="control-label" id="params_upload_ui-ip_am_e_lo-label" for="params_upload_ui-ip_am_e_lo">Low Estimate (5th Percentile)</label>
                                        <input id="params_upload_ui-ip_am_e_lo" type="text" class="form-control" value=""/>
                                      </div>
                                    </div>
                                    <div class="col-sm-6">
                                      <div class="form-group shiny-input-container">
                                        <label class="control-label" id="params_upload_ui-ip_am_e_hi-label" for="params_upload_ui-ip_am_e_hi">High Estimate (85th Percentile)</label>
                                        <input id="params_upload_ui-ip_am_e_hi" type="text" class="form-control" value=""/>
                                      </div>
                                    </div>
                                  </div>
                                </div>
                              </div>
                              <script type="application/json">{"title":"Efficiencies","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                            </div>
                          </div>
                          <div class="tab-pane" data-value="OP Activity Mitigators" id="tab-4344-5">
                            <div class="col-sm-12">
                              <div class="card bs4Dash">
                                <div class="card-header">
                                  <h3 class="card-title">Activity Avoidance</h3>
                                </div>
                                <div class="card-body">
                                  <div class="form-group shiny-input-container">
                                    <label class="control-label" id="params_upload_ui-op_am_a-label" for="params_upload_ui-op_am_a">Change Factor</label>
                                    <div>
                                      <select id="params_upload_ui-op_am_a"></select>
                                      <script type="application/json" data-for="params_upload_ui-op_am_a" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                                    </div>
                                  </div>
                                  <table>
                                    <tr>
                                      <th>Age Group</th>
                                      <th>Specialty Group</th>
                                      <th>Low Estimate (5th Percentile)</th>
                                      <th>High Estimate (95th Percentile)</th>
                                    </tr>
                                    <tr>
                                      <td rowspan="2">Child</td>
                                      <td>surgical</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_a_lo_c1" id="params_upload_ui-op_am_a_lo_c1-label"></label>
                                          <input id="params_upload_ui-op_am_a_lo_c1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_a_hi_c1" id="params_upload_ui-op_am_a_hi_c1-label"></label>
                                          <input id="params_upload_ui-op_am_a_hi_c1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>non-surgical</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_a_lo_c2" id="params_upload_ui-op_am_a_lo_c2-label"></label>
                                          <input id="params_upload_ui-op_am_a_lo_c2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_a_hi_c2" id="params_upload_ui-op_am_a_hi_c2-label"></label>
                                          <input id="params_upload_ui-op_am_a_hi_c2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td rowspan="2">Adult</td>
                                      <td>surgical</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_a_lo_a1" id="params_upload_ui-op_am_a_lo_a1-label"></label>
                                          <input id="params_upload_ui-op_am_a_lo_a1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_a_hi_a1" id="params_upload_ui-op_am_a_hi_a1-label"></label>
                                          <input id="params_upload_ui-op_am_a_hi_a1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>non-surgical</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_a_lo_a2" id="params_upload_ui-op_am_a_lo_a2-label"></label>
                                          <input id="params_upload_ui-op_am_a_lo_a2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_a_hi_a2" id="params_upload_ui-op_am_a_hi_a2-label"></label>
                                          <input id="params_upload_ui-op_am_a_hi_a2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                  </table>
                                </div>
                              </div>
                              <script type="application/json">{"title":"Activity Avoidance","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                            </div>
                            <div class="col-sm-12">
                              <div class="card bs4Dash">
                                <div class="card-header">
                                  <h3 class="card-title">Type Convesion (F2F to Telephone)</h3>
                                </div>
                                <div class="card-body">
                                  <div class="form-group shiny-input-container">
                                    <label class="control-label" id="params_upload_ui-op_am_tc_tele-label" for="params_upload_ui-op_am_tc_tele">Change Factor</label>
                                    <div>
                                      <select id="params_upload_ui-op_am_tc_tele"></select>
                                      <script type="application/json" data-for="params_upload_ui-op_am_tc_tele" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                                    </div>
                                  </div>
                                  <table>
                                    <tr>
                                      <th>Age Group</th>
                                      <th>Specialty Group</th>
                                      <th>Low Estimate (5th Percentile)</th>
                                      <th>High Estimate (95th Percentile)</th>
                                    </tr>
                                    <tr>
                                      <td rowspan="2">Child</td>
                                      <td>non-surgical</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_tc_tele_lo_c1" id="params_upload_ui-op_am_tc_tele_lo_c1-label"></label>
                                          <input id="params_upload_ui-op_am_tc_tele_lo_c1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_tc_tele_hi_c1" id="params_upload_ui-op_am_tc_tele_hi_c1-label"></label>
                                          <input id="params_upload_ui-op_am_tc_tele_hi_c1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>surgical</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_tc_tele_lo_c2" id="params_upload_ui-op_am_tc_tele_lo_c2-label"></label>
                                          <input id="params_upload_ui-op_am_tc_tele_lo_c2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_tc_tele_hi_c2" id="params_upload_ui-op_am_tc_tele_hi_c2-label"></label>
                                          <input id="params_upload_ui-op_am_tc_tele_hi_c2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td rowspan="2">Adult</td>
                                      <td>non-surgical</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_tc_tele_lo_a1" id="params_upload_ui-op_am_tc_tele_lo_a1-label"></label>
                                          <input id="params_upload_ui-op_am_tc_tele_lo_a1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_tc_tele_hi_a1" id="params_upload_ui-op_am_tc_tele_hi_a1-label"></label>
                                          <input id="params_upload_ui-op_am_tc_tele_hi_a1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>surgical</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_tc_tele_lo_a2" id="params_upload_ui-op_am_tc_tele_lo_a2-label"></label>
                                          <input id="params_upload_ui-op_am_tc_tele_lo_a2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-op_am_tc_tele_hi_a2" id="params_upload_ui-op_am_tc_tele_hi_a2-label"></label>
                                          <input id="params_upload_ui-op_am_tc_tele_hi_a2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                  </table>
                                </div>
                              </div>
                              <script type="application/json">{"title":"Type Convesion (F2F to Telephone)","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                            </div>
                          </div>
                          <div class="tab-pane" data-value="AAE Activity Mitigators" id="tab-4344-6">
                            <div class="col-sm-12">
                              <div class="card bs4Dash">
                                <div class="card-header">
                                  <h3 class="card-title">Activity Avoidance</h3>
                                </div>
                                <div class="card-body">
                                  <div class="form-group shiny-input-container">
                                    <label class="control-label" id="params_upload_ui-aae_am_a-label" for="params_upload_ui-aae_am_a">Change Factor</label>
                                    <div>
                                      <select id="params_upload_ui-aae_am_a"></select>
                                      <script type="application/json" data-for="params_upload_ui-aae_am_a" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                                    </div>
                                  </div>
                                  <table>
                                    <tr>
                                      <th>Age Group</th>
                                      <th>Specialty Group</th>
                                      <th>Low Estimate (5th Percentile)</th>
                                      <th>High Estimate (95th Percentile)</th>
                                    </tr>
                                    <tr>
                                      <td rowspan="2">Child</td>
                                      <td>ambulance</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-aae_am_a_lo_c1" id="params_upload_ui-aae_am_a_lo_c1-label"></label>
                                          <input id="params_upload_ui-aae_am_a_lo_c1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-aae_am_a_hi_c1" id="params_upload_ui-aae_am_a_hi_c1-label"></label>
                                          <input id="params_upload_ui-aae_am_a_hi_c1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>walk-in</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-aae_am_a_lo_c2" id="params_upload_ui-aae_am_a_lo_c2-label"></label>
                                          <input id="params_upload_ui-aae_am_a_lo_c2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-aae_am_a_hi_c2" id="params_upload_ui-aae_am_a_hi_c2-label"></label>
                                          <input id="params_upload_ui-aae_am_a_hi_c2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td rowspan="2">Adult</td>
                                      <td>ambulance</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-aae_am_a_lo_a1" id="params_upload_ui-aae_am_a_lo_a1-label"></label>
                                          <input id="params_upload_ui-aae_am_a_lo_a1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-aae_am_a_hi_a1" id="params_upload_ui-aae_am_a_hi_a1-label"></label>
                                          <input id="params_upload_ui-aae_am_a_hi_a1" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                    <tr>
                                      <td>walk-in</td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-aae_am_a_lo_a2" id="params_upload_ui-aae_am_a_lo_a2-label"></label>
                                          <input id="params_upload_ui-aae_am_a_lo_a2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                      <td>
                                        <div class="form-group shiny-input-container">
                                          <label class="control-label shiny-label-null" for="params_upload_ui-aae_am_a_hi_a2" id="params_upload_ui-aae_am_a_hi_a2-label"></label>
                                          <input id="params_upload_ui-aae_am_a_hi_a2" type="text" class="form-control" value=""/>
                                        </div>
                                      </td>
                                    </tr>
                                  </table>
                                </div>
                              </div>
                              <script type="application/json">{"title":"Activity Avoidance","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                    <script type="application/json" data-for="params_box">{"solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_rm">
                  <h2>Running Models</h2>
                  <div id="running_models-running_models" class="shiny-html-output"></div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_phl">
                  <h1>High level activity estimates (principal projection)</h1>
                  <div class="row">
                    <div class="col-sm-12">
                      <div class="card bs4Dash">
                        <div class="card-header">
                          <h3 class="card-title">Activity Estimates</h3>
                          <div class="card-tools float-right">
                            <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                              <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                            </button>
                          </div>
                        </div>
                        <div class="card-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-bffa5cac4d97a1fe6f50710fd9e7421d" class="loader">Loading...</div>
                            </div>
                            <div style="height:400px" class="shiny-spinner-placeholder"></div>
                            <div id="principal_high_level-activity" class="shiny-html-output"></div>
                          </div>
                        </div>
                      </div>
                      <script type="application/json">{"title":"Activity Estimates","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                  </div>
                  <div class="row">
                    <div class="col-sm-4">
                      <div class="card bs4Dash">
                        <div class="card-header">
                          <h3 class="card-title">A&amp;E Attendances</h3>
                          <div class="card-tools float-right">
                            <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                              <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                            </button>
                          </div>
                        </div>
                        <div class="card-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-dc7200c858f45637138e285829883fc4" class="loader">Loading...</div>
                            </div>
                            <div id="principal_high_level-aae" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                          </div>
                        </div>
                      </div>
                      <script type="application/json">{"title":"A&amp;E Attendances","solidHeader":true,"width":4,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                    <div class="col-sm-4">
                      <div class="card bs4Dash">
                        <div class="card-header">
                          <h3 class="card-title">Inpatient Admissions</h3>
                          <div class="card-tools float-right">
                            <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                              <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                            </button>
                          </div>
                        </div>
                        <div class="card-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-eed46c210033380448e452a80ba25870" class="loader">Loading...</div>
                            </div>
                            <div id="principal_high_level-ip" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                          </div>
                        </div>
                      </div>
                      <script type="application/json">{"title":"Inpatient Admissions","solidHeader":true,"width":4,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                    <div class="col-sm-4">
                      <div class="card bs4Dash">
                        <div class="card-header">
                          <h3 class="card-title">Outpatient Attendances</h3>
                          <div class="card-tools float-right">
                            <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                              <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                            </button>
                          </div>
                        </div>
                        <div class="card-body">
                          <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                            <div class="load-container shiny-spinner-hidden load1">
                              <div id="spinner-c0023ed846a822f17d6763c73e8e4310" class="loader">Loading...</div>
                            </div>
                            <div id="principal_high_level-op" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                          </div>
                        </div>
                      </div>
                      <script type="application/json">{"title":"Outpatient Attendances","solidHeader":true,"width":4,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pd">
                  <h1>Detailed activity estimates (principal projection)</h1>
                  <div class="row">
                    <div class="col-sm-3">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="principal_detailed-measure_selection-activity_type-label" for="principal_detailed-measure_selection-activity_type">Activity Type</label>
                        <div>
                          <select id="principal_detailed-measure_selection-activity_type"></select>
                          <script type="application/json" data-for="principal_detailed-measure_selection-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                    <div class="col-sm-3">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="principal_detailed-measure_selection-pod-label" for="principal_detailed-measure_selection-pod">POD</label>
                        <div>
                          <select id="principal_detailed-measure_selection-pod"></select>
                          <script type="application/json" data-for="principal_detailed-measure_selection-pod" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                    <div class="col-sm-3">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="principal_detailed-measure_selection-measure-label" for="principal_detailed-measure_selection-measure">Measure</label>
                        <div>
                          <select id="principal_detailed-measure_selection-measure"></select>
                          <script type="application/json" data-for="principal_detailed-measure_selection-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                    <div class="col-sm-3">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="principal_detailed-aggregation-label" for="principal_detailed-aggregation">Aggregation</label>
                        <div>
                          <select id="principal_detailed-aggregation"></select>
                          <script type="application/json" data-for="principal_detailed-aggregation" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                    <div class="load-container shiny-spinner-hidden load1">
                      <div id="spinner-58186306013ecbda7eca20191a68d10e" class="loader">Loading...</div>
                    </div>
                    <div style="height:400px" class="shiny-spinner-placeholder"></div>
                    <div id="principal_detailed-results" class="shiny-html-output"></div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pcf">
                  <h1>Core change factor effects (principal projection)</h1>
                  <div class="row">
                    <div class="col-sm-4">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="principal_change_factor_effects-activity_type-label" for="principal_change_factor_effects-activity_type">Activity Type</label>
                        <div>
                          <select id="principal_change_factor_effects-activity_type"></select>
                          <script type="application/json" data-for="principal_change_factor_effects-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                    <div class="col-sm-4">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="principal_change_factor_effects-measure-label" for="principal_change_factor_effects-measure">Measure</label>
                        <div>
                          <select id="principal_change_factor_effects-measure"></select>
                          <script type="application/json" data-for="principal_change_factor_effects-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                    <div class="form-group shiny-input-container">
                      <div class="checkbox">
                        <label>
                          <input id="principal_change_factor_effects-include_baseline" type="checkbox" checked="checked"/>
                          <span>Include baseline?</span>
                        </label>
                      </div>
                    </div>
                  </div>
                  <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                    <div class="load-container shiny-spinner-hidden load1">
                      <div id="spinner-3c9e93c93a82e75ec212292ed4a9c563" class="loader">Loading...</div>
                    </div>
                    <div id="principal_change_factor_effects-change_factors" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                  </div>
                  <div id="principal_change_factor_effects-individual_change_factors" class="shinyjs-hide">
                    <h2>Individual Change Factors</h2>
                    <div class="form-group shiny-input-container">
                      <label class="control-label" id="principal_change_factor_effects-sort_type-label" for="principal_change_factor_effects-sort_type">Sort By</label>
                      <div>
                        <select id="principal_change_factor_effects-sort_type"><option value="alphabetical" selected>alphabetical</option>
      <option value="descending value">descending value</option></select>
                        <script type="application/json" data-for="principal_change_factor_effects-sort_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                      </div>
                    </div>
                    <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                      <div class="load-container shiny-spinner-hidden load1">
                        <div id="spinner-203dde89f63e37cee50922ad96b7744d" class="loader">Loading...</div>
                      </div>
                      <div class="row">
                        <div class="col-sm-6">
                          <div id="principal_change_factor_effects-admission_avoidance" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                        </div>
                        <div class="col-sm-6">
                          <div id="principal_change_factor_effects-los_reduction" style="width:100%; height:600px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_mc">
                  <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                    <div class="load-container shiny-spinner-hidden load1">
                      <div id="spinner-03457a0c1876f92902d98d26fe383899" class="loader">Loading...</div>
                    </div>
                    <div style="height:400px" class="shiny-spinner-placeholder"></div>
                    <div id="model_core_activity-core_activity" class="shiny-html-output"></div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_md">
                  <h1>Simulation Results</h1>
                  <div class="row">
                    <div class="col-sm-4">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="model_results_distribution-measure_selection-activity_type-label" for="model_results_distribution-measure_selection-activity_type">Activity Type</label>
                        <div>
                          <select id="model_results_distribution-measure_selection-activity_type"></select>
                          <script type="application/json" data-for="model_results_distribution-measure_selection-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                    <div class="col-sm-4">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="model_results_distribution-measure_selection-pod-label" for="model_results_distribution-measure_selection-pod">POD</label>
                        <div>
                          <select id="model_results_distribution-measure_selection-pod"></select>
                          <script type="application/json" data-for="model_results_distribution-measure_selection-pod" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                    <div class="col-sm-4">
                      <div class="form-group shiny-input-container">
                        <label class="control-label" id="model_results_distribution-measure_selection-measure-label" for="model_results_distribution-measure_selection-measure">Measure</label>
                        <div>
                          <select id="model_results_distribution-measure_selection-measure"></select>
                          <script type="application/json" data-for="model_results_distribution-measure_selection-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="form-group shiny-input-container">
                    <div class="checkbox">
                      <label>
                        <input id="model_results_distribution-show_origin" type="checkbox"/>
                        <span>Show Origin (zero)?</span>
                      </label>
                    </div>
                  </div>
                  <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                    <div class="load-container shiny-spinner-hidden load1">
                      <div id="spinner-fbda7f3f643a91a3f6d4fc96bed451ab" class="loader">Loading...</div>
                    </div>
                    <div id="model_results_distribution-distribution" style="width:100%; height:800px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_cb">
                  <div class="form-group shiny-input-container">
                    <label class="control-label" id="capacity_beds-occupancy_rate-label" for="capacity_beds-occupancy_rate">Occupancy Rate (%)</label>
                    <input id="capacity_beds-occupancy_rate" type="number" class="form-control" value="85" min="0" max="100" step="1"/>
                  </div>
                  <div class="row">
                    <div class="col-sm-9">
                      <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                        <div class="load-container shiny-spinner-hidden load1">
                          <div id="spinner-0f444a075564e49f270cf93e57eb527a" class="loader">Loading...</div>
                        </div>
                        <div id="capacity_beds-available_plot" style="width:100%; height:800px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
                      </div>
                    </div>
                    <div class="col-sm-3">
                      <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                        <div class="load-container shiny-spinner-hidden load1">
                          <div id="spinner-59c0d17cbbb58b0120d7dc5a718d1f00" class="loader">Loading...</div>
                        </div>
                        <div style="height:400px" class="shiny-spinner-placeholder"></div>
                        <div id="capacity_beds-available_table" class="shiny-html-output"></div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>
      </body>

