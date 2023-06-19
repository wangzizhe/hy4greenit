within Hy4GreenIT;
model Hy4GreenIT

  inner TransiEnt.SimCenter simCenter(
    redeclare TransiEnt.Basics.Media.Gases.Gas_VDIWA_SG7_var gasModel2,
                                      redeclare TransiEnt.Basics.Media.Gases.VLE_VDIWA_H2_SRK gasModel3, redeclare TransiEnt.Basics.Media.Gases.VLE_VDIWA_NG7_H2_SRK_var gasModel1,
    phi_H2max=0.1)                                                                                annotation (Placement(transformation(extent={{-208,72},{-188,92}})));
  TransiEnt.Producer.Gas.Electrolyzer.Systems.FeedInStation_Storage feedInStation(
    redeclare TransiEnt.Basics.Interfaces.Electrical.ActivePowerPort epp,
    usePowerPort=true,
    useFluidAdapter=true,
    P_el_n=1e4,
    initOption=0,
    start_pressure=true,
    includeHeatTransfer=false,
    eta_n=0.75,
    t_overload=600,
    m_flow_start=0,
    StoreAllHydrogen=true,
    k=1e8,
    V_geo=50,
    p_out=3500000,
    p_start=5000000,
    redeclare model Dynamics = TransiEnt.Producer.Gas.Electrolyzer.Base.ElectrolyzerDynamics1stOrder,
    integrateMassFlow=false,
    useFluidModelsForSummary=false)
                     annotation (Placement(transformation(extent={{-72,-2},{-92,18}})));
  TransiEnt.Components.Boundaries.Electrical.ActivePower.Frequency ElectricGrid annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=180,
        origin={-26,8})));
  inner TransiEnt.ModelStatistics                                         modelStatistics annotation (Placement(transformation(extent={{-188,72},{-168,92}})));
  TransiEnt.Producer.Electrical.Photovoltaics.PVProfiles.SolarProfileLoader solarProfileLoader(REProfile=TransiEnt.Producer.Electrical.Photovoltaics.PVProfiles.SolarData.Solar2015_Gesamt_900s, P_el_n=1e6) annotation (Placement(transformation(extent={{-122,60},{-102,80}})));
  TransiEnt.Components.Electrical.FuelCellSystems.FuelCell.SOFC
       FC(
    Syngas=simCenter.gasModel2,
    T_n=75 + 273,
    no_Cells=10,
    A_cell=0.0625,
    cp=850,
    ka=0.3,
    usePowerPort=true,
    T_stack(start=25 + 273),
    v_n=0.733,
    redeclare TransiEnt.Basics.Interfaces.Electrical.ApparentPowerPort epp,
    redeclare TransiEnt.Components.Boundaries.Electrical.ApparentPower.ApparentPower powerBoundary(
      useInputConnectorP=true,
      useInputConnectorQ=false,
      useCosPhi=true,
      cosphi_boundary=1) "PQ-Boundary for ApparentPowerPort") annotation (Placement(transformation(extent={{66,-68},{108,-26}})));
 TransiEnt.Components.Electrical.PowerTransformation.SimpleTransformer PowerConverter(
    UseRatio=false,
    U_S=0.733,
    eta=1,
    U_P=230)
           annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={126,28})));
  TransiEnt.Components.Boundaries.Electrical.ApparentPower.ApparentPower LocalDemand(
    useInputConnectorQ=false,
    Q_el_set_const=0,
    useCosPhi=false) annotation (Placement(transformation(extent={{128,64},{108,84}})));
  TransiEnt.Components.Sensors.ElectricReactivePower GridMeter annotation (Placement(transformation(
        extent={{-10,10},{10,-10}},
        rotation=0,
        origin={156,92})));
  ClaRa.Components.BoundaryConditions.BoundaryGas_Txim_flow SourceAir(
    variable_m_flow=false,
    variable_xi=false,
    m_flow_const=2.55e-7,
    xi_const={0.01,0.7},
    T_const=25 + 273,
    medium=FC.Air)    annotation (Placement(transformation(
        extent={{6.5,-9},{-6.5,9}},
        rotation=180,
        origin={38.5,-71})));
  ClaRa.Components.BoundaryConditions.BoundaryGas_pTxi SinkAir(
    variable_p=false,
    variable_xi=false,
    p_const=1e5,
    T_const=200 + 273.15,
    medium=FC.Air)        annotation (Placement(transformation(
        extent={{-7,-8},{7,8}},
        rotation=180,
        origin={143,-70})));
  ClaRa.Components.BoundaryConditions.BoundaryGas_pTxi SinkSyngas(
    variable_p=false,
    variable_xi=false,
    p_const=1e5,
    T_const=200 + 273.15,
    medium=FC.Syngas)     annotation (Placement(transformation(
        extent={{-6,-9},{6,9}},
        rotation=180,
        origin={142,-11})));
  TransiEnt.Components.Boundaries.Electrical.ApparentPower.FrequencyVoltage
                                                       ElectricGrid1(
    Use_input_connector_f=false,
    Use_input_connector_v=false,
    v_boundary=230) annotation (Placement(transformation(extent={{184,80},{204,100}})));
TransiEnt.Components.Electrical.FuelCellSystems.FuelCell.Controller.PowerController PowerController(k=100)
                                                                                                    annotation (Placement(transformation(rotation=0, extent={{66,28},{46,48}})));
  Real_ph_to_Ideal_pT                         real_ph_to_Ideal_pT(
                                                            real=simCenter.gasModel1, ideal=simCenter.gasModel2)
                                                            annotation (Placement(transformation(extent={{-36,-54},{-16,-34}})));
  TransiEnt.Basics.Tables.ElectricGrid.PowerData.GenericPowerDataTable P_load(relativepath="electricity/ElectricityDemand_VDI4665_ExampleHousehold_RG1_HH_2012_900s.txt") annotation (Placement(transformation(extent={{70,84},{90,104}})));
  Modelica.Blocks.Sources.RealExpression massFlow_FeedIn(y=0.1) annotation (Placement(transformation(extent={{-162,6},{-142,26}})));
  ClaRa.Components.BoundaryConditions.BoundaryGas_Txim_flow SourceSyngas(
    variable_T=false,
    m_flow_const=5.1e-2,
    variable_m_flow=false,
    variable_xi=false,
    xi_const={0.11,0.04,0.13,0.25,0.04,0.12},
    T_const=80 + 273.15,
    medium=FC.Syngas)                annotation (Placement(transformation(extent={{24,-24},{40,-8}})));
equation
  connect(ElectricGrid.epp, feedInStation.epp) annotation (Line(
      points={{-36,8},{-72,8}},
      color={0,135,135},
      thickness=0.5));
  connect(SourceAir.gas_a,FC. feeda) annotation (Line(
      points={{45,-71},{56,-71},{56,-59.6},{66,-59.6}},
      color={118,106,98},
      thickness=0.5,
      smooth=Smooth.None));
  connect(SinkSyngas.gas_a,FC. drainh) annotation (Line(
      points={{136,-11},{136,-12},{116,-12},{116,-34.4},{108,-34.4}},
      color={118,106,98},
      thickness=0.5,
      smooth=Smooth.None));
  connect(SinkAir.gas_a,FC. draina) annotation (Line(
      points={{136,-70},{118,-70},{118,-59.6},{108,-59.6}},
      color={118,106,98},
      thickness=0.5,
      smooth=Smooth.None));
  connect(SourceSyngas.gas_a,FC.feedh) annotation(Line(
      color={118,106,98},
      thickness=0.5,
      smooth=Smooth.None,
      points={{40,-16},{58,-16},{58,-34.4},{66,-34.4}}));
  connect(LocalDemand.epp,GridMeter. epp_IN) annotation (Line(
      points={{128,74},{140,74},{140,92},{146.8,92}},
      color={0,127,0},
      smooth=Smooth.None));
  connect(ElectricGrid1.epp, GridMeter.epp_OUT) annotation (Line(points={{184,90},{184,92},{165.4,92}}, color={0,127,0}));
  connect(PowerController.V_cell,FC.v_stack)  annotation (Line(points={{65,32.6},{92,32.6},{92,-24},{118,-24},{118,-42},{114,-42},{114,-47},{87,-47}},
                                                                                                    color={0,0,127}));
  connect(PowerController.y,FC. I_load) annotation (Line(points={{45,38},{40,38},{40,6},{56,6},{56,-48.26},{69.78,-48.26}},color={0,0,127}));
  connect(GridMeter.P,PowerController. deltaP) annotation (Line(points={{152.2,84.2},{152.2,44},{65,44}},                                  color={0,0,127}));
  connect(PowerConverter.epp_p,GridMeter. epp_IN) annotation (Line(points={{126,38},{126,58},{146,58},{146,92},{146.8,92}},
                                                                                                                         color={0,127,0}));
  connect(FC.epp,PowerConverter. epp_n) annotation (Line(
      points={{87,-34.82},{87,-14},{106,-14},{106,8},{126,8},{126,18}},
      color={0,127,0},
      thickness=0.5));
  connect(P_load.value, LocalDemand.P_el_set) annotation (Line(
      points={{88,94},{124,94},{124,86}},
      color={0,135,135},
      pattern=LinePattern.Dash));
  connect(feedInStation.gasPortOut, real_ph_to_Ideal_pT.gasPortIn) annotation (Line(
      points={{-82,-1.9},{-82,-44},{-36,-44}},
      color={255,255,0},
      thickness=1.5));
  connect(solarProfileLoader.y1, feedInStation.P_el_set) annotation (Line(points={{-101,70},{-82,70},{-82,18.4}},   color={0,0,127}));
  connect(massFlow_FeedIn.y, feedInStation.m_flow_feedIn) annotation (Line(points={{-141,16},{-92,16}}, color={0,0,127}));
  connect(real_ph_to_Ideal_pT.gasPortOut, FC.feedh) annotation (Line(
      points={{-16,-44},{2,-44},{2,-34},{6,-34},{6,-34.4},{66,-34.4}},
      color={255,170,85},
      thickness=1.5));
  annotation (
    Diagram(coordinateSystem(extent={{-220,-120},{220,120}}), graphics={
        Text(
          extent={{-138,96},{-86,90}},
          textColor={217,67,180},
          textStyle={TextStyle.Bold},
          textString="Solar Panel",
          fontSize=12),
        Text(
          extent={{-84,38},{-18,14}},
          textColor={217,67,180},
          textStyle={TextStyle.Bold},
          textString="Electrolysis 
+
Tank",    fontSize=12),
        Text(
          extent={{-80,-14},{-40,-24}},
          textColor={162,29,33},
          textString="Output H2",
          fontSize=12,
          textStyle={TextStyle.Bold}),
        Text(
          extent={{18,-24},{58,-44}},
          textColor={162,29,33},
          fontSize=12,
          textString="Input H2
",        textStyle={TextStyle.Bold}),
        Text(
          extent={{116,-22},{156,-40}},
          textColor={162,29,33},
          textString="Input Water",
          fontSize=12,
          textStyle={TextStyle.Bold}),
        Text(
          extent={{54,26},{112,0}},
          textColor={162,29,33},
          textString="Output Electricity
",        fontSize=12,
          textStyle={TextStyle.Bold}),
        Text(
          extent={{124,-116},{58,-90}},
          textColor={217,67,180},
          textStyle={TextStyle.Bold},
          fontSize=12,
          textString="Fuel Cell Stack"),
        Text(
          extent={{180,60},{216,36}},
          textColor={217,67,180},
          textStyle={TextStyle.Bold},
          fontSize=12,
          textString="Consumer"),
        Rectangle(
          extent={{-132,86},{-92,50}},
          lineColor={217,67,180},
          lineThickness=1),
        Rectangle(
          extent={{-102,26},{-62,-8}},
          lineColor={217,67,180},
          lineThickness=1),
        Rectangle(
          extent={{14,50},{168,-96}},
          lineColor={217,67,180},
          lineThickness=1),
        Rectangle(
          extent={{64,108},{216,56}},
          lineColor={217,67,180},
          lineThickness=1)}),
    Icon(coordinateSystem(extent={{-220,-120},{220,120}}), graphics={
        Rectangle(extent={{-60,80},{60,0}}, lineColor={28,108,200}),
        Line(points={{0,0},{0,-80}}, color={28,108,200}),
        Line(points={{-80,-80},{80,-80}}, color={28,108,200}),
        Ellipse(extent={{-120,120},{120,-120}}, lineColor={28,108,200})}),
    experiment(StopTime=86400, __Dymola_Algorithm="Dassl"));
end Hy4GreenIT;
