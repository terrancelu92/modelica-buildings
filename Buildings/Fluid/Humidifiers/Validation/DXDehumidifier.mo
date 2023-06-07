within Buildings.Fluid.Humidifiers.Validation;
model DXDehumidifier
      extends Modelica.Icons.Example;
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal=0.13545
    "Nominal mass flow rate";

  parameter Modelica.Units.SI.Time averagingTimestep = 3600
    "Time-step used to average out Modelica results for comparison with EPlus results. Same val;ue is also applied to unit delay shift on EPlus power value";

  parameter Modelica.Units.SI.Time delayTimestep = 3600
    "Time-step used to unit delay shift on EPlus power value";

  package Medium = Buildings.Media.Air "Medium model";
  inner ThermalZones.EnergyPlus_9_6_0.Building building(
    idfName=Modelica.Utilities.Files.loadResource(
        "modelica://Buildings/Resources/Data/Fluid/Humidifiers/DXDehumidifier/DXDehumidifier.idf"),
    epwName=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.epw"),
    weaName=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"))
    "Building instance for thermal zone"
    annotation (Placement(transformation(extent={{-108,54},{-88,74}})));

  Buildings.ThermalZones.EnergyPlus_9_6_0.ThermalZone zon(
    zoneName="West Zone",
    redeclare package Medium = Medium,
    T_start=301.33,
    X_start={0.01093901449,1 - 0.01093901449},
    nPorts=2)
    "Thermal zone model"
    annotation (Placement(transformation(extent={{-2,20},{-42,60}})));
  Buildings.Controls.OBC.CDL.Continuous.Sources.Constant con[3](final k=fill(0,
        3))
    "Zero signal for internal thermal loads"
    annotation (Placement(transformation(extent={{40,40},{20,60}})));
  Modelica.Blocks.Sources.CombiTimeTable datRea(
    final tableOnFile=true,
    final fileName=Modelica.Utilities.Files.loadResource(
        "modelica://Buildings/Resources/Data/Fluid/Humidifiers/DXDehumidifier/DXDehumidifier.dat"),
    final columns=2:21,
    final tableName="EnergyPlus",
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments)
    "Reader for energy plus reference results"
    annotation (Placement(transformation(extent={{-140,54},{-120,74}})));

  Buildings.Fluid.Humidifiers.DXDehumidifier dxDeh(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=100,
    per=per) "DX dehumidifier"
    annotation (Placement(transformation(extent={{30,-42},{50,-22}})));
  Modelica.Blocks.Sources.Constant phiSet(k=0.45)
    "Set point for relative humidity"
    annotation (Placement(transformation(extent={{-160,-66},{-140,-46}})));
  Buildings.Fluid.Humidifiers.Data.Generic per "Zone air DX dehumidifier curve"
    annotation (Placement(transformation(extent={{-140,14},{-120,34}})));
  Buildings.Fluid.Movers.Preconfigured.FlowControlled_m_flow fan(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=100)
    "Fan"
    annotation (Placement(transformation(extent={{-2,-42},{18,-22}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToReaFanEna
    "Convert fan enable signal to real value"
    annotation (Placement(transformation(extent={{-68,-6},{-48,14}})));

  Buildings.Controls.OBC.CDL.Continuous.Hysteresis hysPhi(final uLow=-0.01, final uHigh=
        0.01)
    "Enable the dehumidifier when zone relative humidity is not at setpoint"
    annotation (Placement(transformation(extent={{-100,-60},{-80,-40}})));
  Buildings.Controls.OBC.CDL.Continuous.Subtract phiSub
    "Find difference between zone RH and setpoint"
    annotation (Placement(transformation(extent={{-130,-60},{-110,-40}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiplyByParameter gai(final k=m_flow_nominal)
                                                                 "Gain factor"
    annotation (Placement(transformation(extent={{-38,-2},{-26,10}})));
  Modelica.Blocks.Sources.RealExpression realExpression1(final y=fan.m_flow)
    "Fan mass flow rate (Modelica)"
    annotation (Placement(transformation(extent={{66,60},{86,80}})));
  Modelica.Blocks.Math.Mean m_flowFan(final f=1/averagingTimestep)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{100,60},{120,80}})));
  Modelica.Blocks.Math.Mean m_flowFanEP(f=1/averagingTimestep)
                       "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,60},{200,80}})));
  Modelica.Blocks.Sources.RealExpression realExpression7(final y=datRea.y[19])
    "Fan mass flow rate (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,60},{164,80}})));
  Modelica.Blocks.Sources.RealExpression realExpression2(final y=-dxDeh.deHum.mWat_flow)
    "Water removal mass flow rate (Modelica)"
    annotation (Placement(transformation(extent={{66,26},{86,46}})));
  Modelica.Blocks.Math.Mean mWatMod(final f=1/averagingTimestep)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{100,26},{120,46}})));
  Modelica.Blocks.Math.Mean mWatEP(f=1/averagingTimestep)
    "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,26},{200,46}})));
  Modelica.Blocks.Sources.RealExpression realExpression8(final y=datRea.y[10])
    "Water removal mass flow rate (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,26},{164,46}})));
  Modelica.Blocks.Sources.RealExpression realExpression3(final y=dxDeh.QHea.y)
    "Air heating rate (Modelica)"
    annotation (Placement(transformation(extent={{66,-10},{86,10}})));
  Modelica.Blocks.Math.Mean QHeaMod(final f=1/averagingTimestep)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{100,-10},{120,10}})));
  Modelica.Blocks.Math.Mean QHeaEP(f=1/averagingTimestep)
    "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,-10},{200,10}})));
  Modelica.Blocks.Sources.RealExpression realExpression9(final y=datRea.y[9])
    "Air heating rate (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,-10},{164,10}})));
  Modelica.Blocks.Sources.RealExpression realExpression4(final y=dxDeh.P)
    "Air heating rate (Modelica)"
    annotation (Placement(transformation(extent={{66,-40},{86,-20}})));
  Modelica.Blocks.Math.Mean PMod(final f=1/averagingTimestep)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{100,-40},{120,-20}})));
  Modelica.Blocks.Math.Mean PEP(f=1/averagingTimestep)
    "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,-40},{200,-20}})));
  Modelica.Blocks.Sources.RealExpression realExpression10(final y=datRea.y[11])
    "DX dehumidifier power rate (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,-40},{164,-20}})));
  Modelica.Blocks.Sources.RealExpression realExpression5(final y=zon.TAir -
        273.15) "Zone air temperature (Modelica)"
    annotation (Placement(transformation(extent={{66,-70},{86,-50}})));
  Modelica.Blocks.Math.Mean TZonAirMod(final f=1/averagingTimestep, x0=28.18)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{100,-70},{120,-50}})));
  Modelica.Blocks.Math.Mean TZonAirEP(f=1/averagingTimestep)
                       "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,-70},{200,-50}})));
  Modelica.Blocks.Sources.RealExpression realExpression11(final y=datRea.y[4])
    "Zone air temperature (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,-70},{164,-50}})));
  Modelica.Blocks.Sources.RealExpression realExpression6(final y=zon.phi*100)
    "Zone air humidity ratio (Modelica)"
    annotation (Placement(transformation(extent={{66,-100},{86,-80}})));
  Modelica.Blocks.Math.Mean phiZonAirMod(final f=1/averagingTimestep, x0=44.95)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{100,-100},{120,-80}})));
  Modelica.Blocks.Math.Mean phiZonAirEP(f=1/averagingTimestep)
                       "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,-100},{200,-80}})));
  Modelica.Blocks.Sources.RealExpression realExpression12(final y=datRea.y[6])
    "Zone air humidity ratio (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,-100},{164,-80}})));
equation
  connect(con.y, zon.qGai_flow)
    annotation (Line(points={{18,50},{0,50}},    color={0,0,127}));
  connect(phiSub.y, hysPhi.u)
    annotation (Line(points={{-108,-50},{-102,-50}}, color={0,0,127}));
  connect(hysPhi.y, dxDeh.uEna) annotation (Line(points={{-78,-50},{-58,-50},{-58,
          -37},{29,-37}},   color={255,0,255}));
  connect(hysPhi.y, booToReaFanEna.u) annotation (Line(points={{-78,-50},{-76,-50},
          {-76,4},{-70,4}}, color={255,0,255}));
  connect(phiSet.y, phiSub.u2)
    annotation (Line(points={{-139,-56},{-132,-56}}, color={0,0,127}));
  connect(zon.phi, phiSub.u1) annotation (Line(points={{-43,50},{-82,50},{-82,-26},
          {-136,-26},{-136,-44},{-132,-44}}, color={0,0,127}));
  connect(fan.port_b, dxDeh.port_a) annotation (Line(points={{18,-32},{30,-32}},
                             color={0,127,255}));
  connect(dxDeh.port_b, zon.ports[1]) annotation (Line(points={{50,-32},{54,-32},
          {54,12},{-20,12},{-20,20.9}},
                                     color={0,127,255}));
  connect(booToReaFanEna.y, gai.u)
    annotation (Line(points={{-46,4},{-39.2,4}},     color={0,0,127}));
  connect(gai.y, fan.m_flow_in)
    annotation (Line(points={{-24.8,4},{8,4},{8,-20}},      color={0,0,127}));
  connect(realExpression1.y, m_flowFan.u)
    annotation (Line(points={{87,70},{98,70}}, color={0,0,127}));
  connect(realExpression7.y, m_flowFanEP.u)
    annotation (Line(points={{165,70},{178,70}}, color={0,0,127}));
  connect(realExpression2.y, mWatMod.u)
    annotation (Line(points={{87,36},{98,36}},  color={0,0,127}));
  connect(realExpression8.y, mWatEP.u)
    annotation (Line(points={{165,36},{178,36}}, color={0,0,127}));
  connect(realExpression3.y, QHeaMod.u)
    annotation (Line(points={{87,0},{98,0}}, color={0,0,127}));
  connect(realExpression9.y, QHeaEP.u)
    annotation (Line(points={{165,0},{178,0}}, color={0,0,127}));
  connect(realExpression4.y, PMod.u)
    annotation (Line(points={{87,-30},{98,-30}},  color={0,0,127}));
  connect(realExpression10.y, PEP.u)
    annotation (Line(points={{165,-30},{178,-30}}, color={0,0,127}));
  connect(realExpression5.y, TZonAirMod.u)
    annotation (Line(points={{87,-60},{98,-60}}, color={0,0,127}));
  connect(realExpression11.y, TZonAirEP.u)
    annotation (Line(points={{165,-60},{178,-60}}, color={0,0,127}));
  connect(realExpression6.y, phiZonAirMod.u)
    annotation (Line(points={{87,-90},{98,-90}}, color={0,0,127}));
  connect(realExpression12.y, phiZonAirEP.u)
    annotation (Line(points={{165,-90},{178,-90}}, color={0,0,127}));
  connect(fan.port_a, zon.ports[2]) annotation (Line(points={{-2,-32},{-24,-32},
          {-24,20.9}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-140,-120},
            {100,80}})),  Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-160,-100},{200,100}})),
    experiment(
      StartTime=12960000,
      StopTime=13564800,
      __Dymola_Algorithm="Cvode"),
    __Dymola_Commands(file="Resources/Scripts/Dymola/Fluid/Humidifiers/Validation/DXDehumidifier.mos"
        "Simulate and Plot"),
    Documentation(info="<html>
<p>This is an example model for the zone air DX dehumidifier model with an on-off controller to maintain the zone relative humidity. It consists of: </p>
<ul>
<li>an instance of the zone air DX dehumidifier model <span style=\"font-family: Courier New;\">dxDeh</span>. </li>
<li>thermal zone model <span style=\"font-family: Courier New;\">zon</span> of class <a href=\"modelica://Buildings.ThermalZones.EnergyPlus_9_6_0.ThermalZone\">Buildings.ThermalZones.EnergyPlus_9_6_0.ThermalZone</a>. </li>
<li>on-off controller <span style=\"font-family: Courier New;\">hysPhi</span>. </li>
<li>zone air relative humidity setpoint controller <span style=\"font-family: Courier New;\">phiSet</span>. </li>
</ul>
<p>The simulation model provides a closed-loop example of <span style=\"font-family: Courier New;\">DX dehumidifier</span> that is operated by <span style=\"font-family: Courier New;\">dxDeh</span> and regulates the zone relative humidity in <span style=\"font-family: Courier New;\">zon</span> at the setpoint generated by <span style=\"font-family: Courier New;\">phiSet</span>. </p>
</html>"));
end DXDehumidifier;
