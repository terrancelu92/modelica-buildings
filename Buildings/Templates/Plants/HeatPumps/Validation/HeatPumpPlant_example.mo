within Buildings.Templates.Plants.HeatPumps.Validation;
model HeatPumpPlant_example
  extends Modelica.Icons.Example;
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conInt(k=0)
    annotation (Placement(transformation(extent={{-80,-10},{-60,10}})));
  HHW_CHW_plant                                       hHW_CHW_plant(datAll(pla(
        ctl(dpHeaWatRemSet_max(each displayUnit="Pa") = {110000},
            dpChiWatRemSet_max(each displayUnit="Pa") = {4000}),
        pumHeaWatPri(dp_nominal(each displayUnit="Pa") = fill(40500, 2)),
        pumHeaWatSec(m_flow_nominal=fill(1.4, hHW_CHW_plant.pumHeaWatSec.nPum),
            dp_nominal=fill(120000, hHW_CHW_plant.pumHeaWatSec.nPum)),
        hp(
          mHeaWatHp_flow_nominal=1.1*120000/(4200*12),
          capHeaHp_nominal=2e5/2,
          mChiWatHp_flow_nominal=1.1*120000/(4200*12),
          capCooHp_nominal=2e5/2),
        pumChiWatSec(dp_nominal(each displayUnit="Pa") = fill(10000,
            hHW_CHW_plant.pumChiWatSec.nPum)))), ctl(
      triHeaWat=-0.03,
      kCtlDpHeaWat=0.1,
      TiCtlDpHeaWat=60,
      ctlPumHeaWatSec(ctlDpRem(r=110000)),
      kCtlDpChiWat=1,
      TiCtlDpChiWat=180))
    annotation (Placement(transformation(extent={{0,0},{20,20}})));
  Buildings.Controls.OBC.CDL.Integers.Sources.Constant conInt1(k=1)
    annotation (Placement(transformation(extent={{-40,-30},{-20,-10}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Ramp ram(height=4, duration=14400)
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Buildings.Controls.OBC.CDL.Conversions.RealToInteger reaToInt
    annotation (Placement(transformation(extent={{-40,60},{-20,80}})));
  BoundaryConditions.WeatherData.ReaderTMY3           weather(filNam=
        Modelica.Utilities.Files.loadResource(
        "modelica://Buildings/Resources/weatherdata/USA_NY_Buffalo-Greater.Buffalo.Intl.AP.725280_TMY3.mos"))
                                                            "Weather data"
    annotation (Placement(transformation(extent={{-80,-60},{-60,-40}})));
  Fluid.Sources.Boundary_pT           bou1(
    redeclare package Medium = Media.Water "Water",
    use_p_in=false,
    p(displayUnit="Pa") = 100000,
    use_T_in=false,
    T=303.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={10,-80})));
  Fluid.Sources.Boundary_pT           bou(
    redeclare package Medium = Media.Water "Water",
    use_p_in=false,
    p(displayUnit="Pa") = 100000,
    T=333.15) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-30,-80})));
  Fluid.Sources.Boundary_pT           bou2(
    redeclare package Medium = Media.Water "Water",
    use_p_in=false,
    p(displayUnit="Pa") = 100000,
    use_T_in=false,
    T=279.95,
    nPorts=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={56,50})));
  Fluid.Sources.Boundary_pT           bou3(
    redeclare package Medium = Media.Water "Water",
    use_p_in=false,
    p(displayUnit="Pa") = 100000,
    T=279.95,
    nPorts=1) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={30,50})));
  Fluid.HeatExchangers.SensibleCooler_T coo(
    redeclare package Medium = Buildings.Media.Water "Water",
    m_flow_nominal=1.1*120000*3/(4200*12),
    dp_nominal=90000)
    annotation (Placement(transformation(extent={{20,-40},{40,-20}})));
  Buildings.Controls.OBC.CDL.Reals.Sources.Constant con(k=273.15 + 40)
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
equation
  connect(conInt.y, hHW_CHW_plant.nReqResChiWat) annotation (Line(points={{-58,0},
          {-14,0},{-14,14},{-4,14}}, color={255,127,0}));
  connect(conInt.y, hHW_CHW_plant.nReqPlaChiWat) annotation (Line(points={{-58,0},
          {-14,0},{-14,6},{-4,6}}, color={255,127,0}));
  connect(conInt1.y, hHW_CHW_plant.nReqPlaHeaWat) annotation (Line(points={{-18,
          -20},{-10,-20},{-10,0},{-4,0}}, color={255,127,0}));
  connect(ram.y, reaToInt.u)
    annotation (Line(points={{-58,70},{-42,70}}, color={0,0,127}));
  connect(reaToInt.y, hHW_CHW_plant.nReqResHeaWat) annotation (Line(points={{-18,
          70},{-14,70},{-14,20},{-4,20}}, color={255,127,0}));
  connect(weather.weaBus, hHW_CHW_plant.weaBus) annotation (Line(
      points={{-60,-50},{-46,-50},{-46,8},{-22,8},{-22,27.5},{-30.1,27.5}},
      color={255,204,51},
      thickness=0.5));
  connect(bou3.ports[1], hHW_CHW_plant.port_a1) annotation (Line(points={{30,60},
          {30,64},{0,64},{0,16}}, color={0,127,255}));
  connect(bou2.ports[1], hHW_CHW_plant.port_b1) annotation (Line(points={{56,60},
          {56,64},{70,64},{70,16},{20,16}}, color={0,127,255}));
  connect(hHW_CHW_plant.port_b2, coo.port_a)
    annotation (Line(points={{0,4},{0,-30},{20,-30}}, color={0,127,255}));
  connect(coo.port_b, hHW_CHW_plant.port_a2) annotation (Line(points={{40,-30},{
          48,-30},{48,4},{20,4}}, color={0,127,255}));
  connect(con.y, coo.TSet) annotation (Line(points={{-58,40},{-18,40},{-18,-14},
          {18,-14},{18,-22}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false), graphics={Line(
          points={{-4,-26},{-4,-12}},
          color={238,46,47},
          arrow={Arrow.Filled,Arrow.None}), Line(
          points={{24,0},{44,0}},
          color={238,46,47},
          arrow={Arrow.Filled,Arrow.None})}),
    experiment(
      StopTime=18000,
      Interval=60,
      Tolerance=1e-05,
      __Dymola_Algorithm="Dassl"));
end HeatPumpPlant_example;
