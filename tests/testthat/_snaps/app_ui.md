# ui is created correctly

    Code
      app_ui()
    Output
      <body data-help="0" data-fullscreen="0" data-dark="1" data-scrollToTop="0" class="sidebar-mini">
        <div class="wrapper">
          <nav data-fixed="false" class="main-header navbar navbar-expand navbar-white navbar-light">
            <ul class="navbar-nav">
              <li class="nav-item">
                <a class="nav-link" data-widget="pushmenu" href="#">
                  <i class="fas fa-bars" role="presentation" aria-label="bars icon" verify_fa="FALSE"></i>
                </a>
              </li>
            </ul>
            <ul class="navbar-nav ml-auto navbar-right">
              <li class="nav-item">
                <a id="controlbar-toggle" class="nav-link" data-widget="control-sidebar" href="#">
                  <i class="fas fa-table-cells" role="presentation" aria-label="table-cells icon" verify_fa="FALSE"></i>
                </a>
              </li>
            </ul>
          </nav>
          <aside id="sidebarId" data-fixed="true" data-minified="TRUE" data-collapsed="FALSE" data-disable="FALSE" class="main-sidebar sidebar-light-primary elevation-4">
            <div class="brand-link">NHP Model Results</div>
            <div class="sidebar" id="sidebarItemExpanded">
              <nav class="mt-2">
                <ul class="nav nav-pills nav-sidebar flex-column sidebar-menu nav-child-indent" data-widget="treeview" role="menu" data-accordion="true">
                  <li class="nav-item">
                    <a class="nav-link" id="tab-tab_home" href="#" data-target="#shiny-tab-tab_home" data-toggle="tab" data-value="tab_home">
                      <i class="fas fa-house nav-icon" role="presentation" aria-label="house icon" verify_fa="FALSE"></i>
                      <p>Home</p>
                    </a>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Principal projection
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="Principalprojection">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_ps" href="#" data-target="#shiny-tab-tab_ps" data-toggle="tab" data-value="tab_ps">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Summary</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pcf" href="#" data-target="#shiny-tab-tab_pcf" data-toggle="tab" data-value="tab_pcf">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Impact of changes</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_phl" href="#" data-target="#shiny-tab-tab_phl" data-toggle="tab" data-value="tab_phl">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Summary by year</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_pd" href="#" data-target="#shiny-tab-tab_pd" data-toggle="tab" data-value="tab_pd">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Activity in detail</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Distribution of projections
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="Distributionofprojections">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_mc" href="#" data-target="#shiny-tab-tab_mc" data-toggle="tab" data-value="tab_mc">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Activity summary</p>
                        </a>
                      </li>
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_md" href="#" data-target="#shiny-tab-tab_md" data-toggle="tab" data-value="tab_md">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Activity distribution</p>
                        </a>
                      </li>
                    </ul>
                  </li>
                  <li class="nav-item has-treeview">
                    <a href="#" class="nav-link">
                      <p>
                        Information
                        <i class="right fas fa-angle-left"></i>
                      </p>
                    </a>
                    <ul class="nav nav-treeview" data-expanded="Information">
                      <li class="nav-item">
                        <a class="nav-link treeview-link" id="tab-tab_params" href="#" data-target="#shiny-tab-tab_params" data-toggle="tab" data-value="tab_params">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Input parameters</p>
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
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_home">result_selection</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_ps">params_upload</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pcf">running_models</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_phl">principal_summary</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pd">principal_change_factor_effects</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_mc">principal_high_level</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_md">principal_detailed</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_params">
                  <h1>Information: input parameters</h1>
                  <div class="col-sm-12">
                    <div class="card bs4Dash">
                      <div class="card-header">
                        <h3 class="card-title">Notes</h3>
                      </div>
                      <div class="card-body">
                        <p>
                          This page contains a reminder of the parameter values you provided to the model inputs app.
                          Further information about the model and these outputs can be found on the
                          <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site.</a>
                        </p>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Notes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Years</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <div id="info_params-params_years" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Years","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Demographic factors</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <div id="info_params-params_demographic_factors" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Demographic factors","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Baseline adjustment</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_baseline_adjustment_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_baseline_adjustment_op" class="shiny-html-output"></div>
                        <p>A&amp;E</p>
                        <div id="info_params-params_baseline_adjustment_aae" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Baseline adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Covid adjustment</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_covid_adjustment_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_covid_adjustment_op" class="shiny-html-output"></div>
                        <p>A&amp;E</p>
                        <div id="info_params-params_covid_adjustment_aae" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Covid adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Waiting list adjustment</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_waiting_list_adjustment_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_waiting_list_adjustment_op" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Waiting list adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Expatriation</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_expat_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_expat_op" class="shiny-html-output"></div>
                        <p>A&amp;E</p>
                        <div id="info_params-params_expat_aae" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Expatriation","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Repatriation (local)</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_repat_local_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_repat_local_op" class="shiny-html-output"></div>
                        <p>A&amp;E</p>
                        <div id="info_params-params_repat_local_aae" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Repatriation (local)","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Repatriation (non-local)</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_repat_nonlocal_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_repat_nonlocal_op" class="shiny-html-output"></div>
                        <p>A&amp;E</p>
                        <div id="info_params-params_repat_nonlocal_aae" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Repatriation (non-local)","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Non-demographic adjustment</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_non_demographic_adjustment_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_non_demographic_adjustment_op" class="shiny-html-output"></div>
                        <p>A&amp;E</p>
                        <div id="info_params-params_non_demographic_adjustment_aae" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Non-demographic adjustment","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Activity avoidance</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_activity_avoidance_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_activity_avoidance_op" class="shiny-html-output"></div>
                        <p>A&amp;E</p>
                        <div id="info_params-params_activity_avoidance_aae" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Activity avoidance","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Efficiencies</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Inpatients</p>
                        <div id="info_params-params_efficiencies_ip" class="shiny-html-output"></div>
                        <p>Outpatients</p>
                        <div id="info_params-params_efficiencies_op" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Efficiencies","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Bed occupancy</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Day and night</p>
                        <div id="info_params-params_bed_occupancy_day_night" class="shiny-html-output"></div>
                        <p>Specialty mapping</p>
                        <div id="info_params-params_bed_occupancy_specialty_mapping" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Bed occupancy","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash collapsed-card">
                      <div class="card-header">
                        <h3 class="card-title">Time profile mappings</h3>
                        <div class="card-tools float-right">
                          <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                            <i class="fas fa-plus" role="presentation" aria-label="plus icon" verify_fa="FALSE"></i>
                          </button>
                        </div>
                      </div>
                      <div class="card-body">
                        <p>Activity avoidance</p>
                        <div id="info_params-params_time_profile_mappings_activity_avoidance" class="shiny-html-output"></div>
                        <p>Efficiencies</p>
                        <div id="info_params-params_time_profile_mappings_efficiencies" class="shiny-html-output"></div>
                        <p>Others</p>
                        <div id="info_params-params_time_profile_mappings_others" class="shiny-html-output"></div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Time profile mappings","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                </div>
              </div>
            </section>
          </div>
        </div>
      </body>

