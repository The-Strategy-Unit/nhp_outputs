# ui is created correctly

    Code
      app_ui()
    Output
      <body data-help="0" data-fullscreen="0" data-dark="0" data-scrollToTop="0" class="sidebar-mini">
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
                      <p>Home</p>
                    </a>
                  </li>
                  <li class="nav-header">Site Selection</li>
                  <div class="form-group shiny-input-container">
                    <label class="control-label shiny-label-null" for="site_selection" id="site_selection-label"></label>
                    <div>
                      <select id="site_selection" class="shiny-input-select" multiple="multiple"></select>
                      <script type="application/json" data-for="site_selection">{"plugins":["selectize-plugin-a11y"]}</script>
                    </div>
                  </div>
                  <li class="nav-header">Results</li>
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
                        <a class="nav-link treeview-link" id="tab-tab_plos" href="#" data-target="#shiny-tab-tab_plos" data-toggle="tab" data-value="tab_plos">
                          <i class="fas fa-angles-right" role="presentation" aria-label="angles-right icon" verify_fa="FALSE" cl="fas fa-angles-right nav-icon"></i>
                          <p>Length of stay</p>
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
                  <li class="nav-header">Information</li>
                  <li class="nav-item">
                    <a class="nav-link" id="tab-tab_downloads" href="#" data-target="#shiny-tab-tab_downloads" data-toggle="tab" data-value="tab_downloads">
                      <p>Downloads</p>
                    </a>
                  </li>
                  <li class="nav-item">
                    <a class="nav-link" id="tab-tab_params" href="#" data-target="#shiny-tab-tab_params" data-toggle="tab" data-value="tab_params">
                      <p>Input parameters</p>
                    </a>
                  </li>
                  <div id="sidebarMenu" class="sidebarMenuSelectedTabItem" data-value="null"></div>
                </ul>
              </nav>
            </div>
          </aside>
          <div class="content-wrapper">
            <section class="content">
              <div class="tab-content">
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_home">home</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_ps">principal_summary</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_plos">
                  <h1>Principal projection: length of stay summary</h1>
                  <div class="col-sm-12">
                    <div class="card bs4Dash">
                      <div class="card-header">
                        <h3 class="card-title">Notes</h3>
                      </div>
                      <div class="card-body">
                        <p>
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
                        <h3 class="card-title">Bed days summary by length of stay and point of delivery</h3>
                      </div>
                      <div class="card-body">
                        <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                          <div class="load-container shiny-spinner-hidden load1">
                            <div id="spinner-1857099327b1aff77d32fa5ed14cd0bc" class="loader">Loading...</div>
                          </div>
                          <div style="height:400px" class="shiny-spinner-placeholder"></div>
                          <div id="principal_summary_los-summary_los_table_beddays" class="shiny-html-output"></div>
                        </div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Bed days summary by length of stay and point of delivery","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                  <div class="col-sm-12">
                    <div class="card bs4Dash">
                      <div class="card-header">
                        <h3 class="card-title">Admissions summary by length of stay and point of delivery</h3>
                      </div>
                      <div class="card-body">
                        <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                          <div class="load-container shiny-spinner-hidden load1">
                            <div id="spinner-27905ce65da0feb456001ecf156cc1d8" class="loader">Loading...</div>
                          </div>
                          <div style="height:400px" class="shiny-spinner-placeholder"></div>
                          <div id="principal_summary_los-summary_los_table_admissions" class="shiny-html-output"></div>
                        </div>
                      </div>
                    </div>
                    <script type="application/json">{"title":"Admissions summary by length of stay and point of delivery","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
                  </div>
                </div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pcf">principal_change_factor_effects</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_phl">principal_high_level</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_pd">principal_detailed</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_mc">model_core_activity</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_md">model_results_distribution</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_downloads">info_downloads</div>
                <div role="tabpanel" class="tab-pane container-fluid" id="shiny-tab-tab_params">info_params</div>
              </div>
            </section>
          </div>
        </div>
      </body>

