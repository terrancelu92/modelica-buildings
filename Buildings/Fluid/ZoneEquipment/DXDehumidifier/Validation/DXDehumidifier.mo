within Buildings.Fluid.ZoneEquipment.DXDehumidifier.Validation;
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
    idfName=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/Data/Fluid/ZoneEquipment/DXDehumidifier/DXDehumidifier.idf"),
    epwName=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.epw"),
    weaName=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/weatherdata/USA_IL_Chicago-OHare.Intl.AP.725300_TMY3.mos"))
    "Building instance for thermal zone"
    annotation (Placement(transformation(extent={{-108,54},{-88,74}})));

  ThermalZones.EnergyPlus_9_6_0.ThermalZone zon(
    zoneName="West Zone",
    redeclare package Medium = Medium,
    T_start=301.33,
    X_start={0.01093901449,1 - 0.01093901449},
    nPorts=2)
    "Thermal zone model"
    annotation (Placement(transformation(extent={{-2,20},{-42,60}})));
  Controls.OBC.CDL.Continuous.Sources.Constant con[3](final k=fill(0,
        3))
    "Zero signal for internal thermal loads"
    annotation (Placement(transformation(extent={{40,40},{20,60}})));
  Modelica.Blocks.Sources.CombiTimeTable datRea(
    final tableOnFile=true,
    final fileName=Modelica.Utilities.Files.loadResource("modelica://Buildings/Resources/Data/Fluid/ZoneEquipment/DXDehumidifier/DXDehumidifier.dat"),
    final columns=2:21,
    final tableName="EnergyPlus",
    final smoothness=Modelica.Blocks.Types.Smoothness.ConstantSegments)
    "Reader for energy plus reference results"
    annotation (Placement(transformation(extent={{-140,54},{-120,74}})));

  Buildings.Fluid.ZoneEquipment.DXDehumidifier.DXDehumidifier dxDeh(
    redeclare package Medium = Medium,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=100,
    per=per)
    annotation (Placement(transformation(extent={{28,-68},{48,-48}})));
  Modelica.Blocks.Sources.Constant phiSet(k=0.45)
                                                 "Set point for RH"
    annotation (Placement(transformation(extent={{-160,-66},{-140,-46}})));
  Data.Generic per
    annotation (Placement(transformation(extent={{-140,14},{-120,34}})));
  Movers.Preconfigured.FlowControlled_m_flow fan(
    redeclare package Medium = Medium,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    m_flow_nominal=m_flow_nominal,
    dp_nominal=100)
    "Fan"
    annotation (Placement(transformation(extent={{-2,-42},{18,-22}})));
  Controls.OBC.CDL.Conversions.BooleanToReal booToReaFanEna
    "Convert fan enable signal to real value"
    annotation (Placement(transformation(extent={{-68,-6},{-48,14}})));

  Controls.OBC.CDL.Continuous.Hysteresis hysModCoo(final uLow=-0.01, final
      uHigh=0.01)
    "Enable cooling mode when zone temperature is not at setpoint"
    annotation (Placement(transformation(extent={{-100,-60},{-80,-40}})));
  Controls.OBC.CDL.Continuous.Subtract phiSub
    "Find difference between zone RH and setpoint"
    annotation (Placement(transformation(extent={{-130,-60},{-110,-40}})));
  Sensors.TemperatureTwoPort senTem(redeclare package Medium = Medium,
      m_flow_nominal=m_flow_nominal)
    annotation (Placement(transformation(extent={{-38,-22},{-18,-42}})));
  Sensors.RelativeHumidityTwoPort senRelHum(redeclare package Medium = Medium,
      m_flow_nominal=m_flow_nominal)
    annotation (Placement(transformation(extent={{-68,-22},{-48,-42}})));
  Controls.OBC.CDL.Continuous.MultiplyByParameter gai(final k=m_flow_nominal)
                                                                 "Gain factor"
    annotation (Placement(transformation(extent={{-38,-2},{-26,10}})));
  Modelica.Blocks.Sources.RealExpression realExpression2(final y=fan.m_flow)
    "Fan mass flow rate (Modelica)"
    annotation (Placement(transformation(extent={{66,60},{86,80}})));
  Modelica.Blocks.Math.Mean m_flowFan(final f=1/averagingTimestep)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{102,60},{122,80}})));
  Controls.OBC.CDL.Discrete.UnitDelay m_flowFanEP(final samplePeriod=
        delayTimestep) "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,60},{200,80}})));
  Modelica.Blocks.Sources.RealExpression realExpression9(final y=datRea.y[19])
    "Fan mass flow rate (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,60},{164,80}})));
  Modelica.Blocks.Sources.RealExpression realExpression1(final y=-dxDeh.mWat_flow.y)
    "Water removal mass flow rate (Modelica)"
    annotation (Placement(transformation(extent={{66,26},{86,46}})));
  Modelica.Blocks.Math.Mean mWatMod(final f=1/averagingTimestep)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{102,26},{122,46}})));
  Controls.OBC.CDL.Discrete.UnitDelay mWatEP(final samplePeriod=delayTimestep)
    "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,26},{200,46}})));
  Modelica.Blocks.Sources.RealExpression realExpression3(final y=datRea.y[10])
    "Water removal mass flow rate (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,26},{164,46}})));
  Modelica.Blocks.Sources.RealExpression realExpression4(final y=dxDeh.QHea.y)
    "Air heating rate (Modelica)"
    annotation (Placement(transformation(extent={{66,-10},{86,10}})));
  Modelica.Blocks.Math.Mean QHeaMod(final f=1/averagingTimestep)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{102,-10},{122,10}})));
  Controls.OBC.CDL.Discrete.UnitDelay QHeaEP(final samplePeriod=delayTimestep)
    "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,-10},{200,10}})));
  Modelica.Blocks.Sources.RealExpression realExpression5(final y=datRea.y[9])
    "Air heating rate (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,-10},{164,10}})));
  Modelica.Blocks.Sources.RealExpression realExpression6(final y=dxDeh.P)
    "Air heating rate (Modelica)"
    annotation (Placement(transformation(extent={{66,-40},{86,-20}})));
  Modelica.Blocks.Math.Mean PMod(final f=1/averagingTimestep)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{104,-40},{124,-20}})));
  Controls.OBC.CDL.Discrete.UnitDelay PEP(final samplePeriod=delayTimestep)
    "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,-40},{200,-20}})));
  Modelica.Blocks.Sources.RealExpression realExpression7(final y=datRea.y[11])
    "DX dehumidifier power rate (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,-40},{164,-20}})));
  Modelica.Blocks.Sources.RealExpression realExpression8(final y=zon.TAir - 273.15)
    "Zone air temperature (Modelica)"
    annotation (Placement(transformation(extent={{66,-70},{86,-50}})));
  Modelica.Blocks.Math.Mean TZonAirMod(final f=1/averagingTimestep, x0=28.18)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{104,-70},{124,-50}})));
  Controls.OBC.CDL.Discrete.UnitDelay TZonAirEP(final samplePeriod=
        delayTimestep) "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,-70},{200,-50}})));
  Modelica.Blocks.Sources.RealExpression realExpression10(final y=datRea.y[4])
    "Zone air temperature (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,-70},{164,-50}})));
  Modelica.Blocks.Sources.RealExpression realExpression11(final y=zon.phi*100)
    "Zone air humidity ratio (Modelica)"
    annotation (Placement(transformation(extent={{66,-100},{86,-80}})));
  Modelica.Blocks.Math.Mean phiZonAirMod(final f=1/averagingTimestep, x0=44.95)
    "Average out Modelica results over time"
    annotation (Placement(transformation(extent={{104,-100},{124,-80}})));
  Controls.OBC.CDL.Discrete.UnitDelay phiZonAirEP(final samplePeriod=
        delayTimestep) "Unit delay on EnergyPlus results"
    annotation (Placement(transformation(extent={{180,-100},{200,-80}})));
  Modelica.Blocks.Sources.RealExpression realExpression12(final y=datRea.y[6])
    "Zone air humidity ratio (EnergyPlus)"
    annotation (Placement(transformation(extent={{144,-100},{164,-80}})));
equation
  connect(con.y, zon.qGai_flow)
    annotation (Line(points={{18,50},{0,50}},    color={0,0,127}));
  connect(phiSub.y, hysModCoo.u)
    annotation (Line(points={{-108,-50},{-102,-50}},
                                                   color={0,0,127}));
  connect(hysModCoo.y, dxDeh.uEna)
    annotation (Line(points={{-78,-50},{-58,-50},{-58,-63},{26.8,-63}},
                                                   color={255,0,255}));
  connect(hysModCoo.y, booToReaFanEna.u) annotation (Line(points={{-78,-50},{-76,
          -50},{-76,4},{-70,4}},     color={255,0,255}));
  connect(phiSet.y, phiSub.u2)
    annotation (Line(points={{-139,-56},{-132,-56}}, color={0,0,127}));
  connect(zon.phi, phiSub.u1) annotation (Line(points={{-43,50},{-82,50},{-82,-26},
          {-136,-26},{-136,-44},{-132,-44}}, color={0,0,127}));
  connect(senTem.port_b, fan.port_a)
    annotation (Line(points={{-18,-32},{-2,-32}},
                                                color={0,127,255}));
  connect(senRelHum.port_b, senTem.port_a)
    annotation (Line(points={{-48,-32},{-38,-32}}, color={0,127,255}));
  connect(senRelHum.port_a, zon.ports[1]) annotation (Line(points={{-68,-32},{-72,
          -32},{-72,-24},{-20,-24},{-20,20.9}},
                                           color={0,127,255}));
  connect(fan.port_b, dxDeh.port_a) annotation (Line(points={{18,-32},{22,-32},{
          22,-58},{28,-58}}, color={0,127,255}));
  connect(senRelHum.phi, dxDeh.phi) annotation (Line(points={{-57.9,-43},{-58,-43},
          {-58,-55.5},{27,-55.5}},
                               color={0,0,127}));
  connect(senTem.T, dxDeh.TIn)
    annotation (Line(points={{-28,-43},{-28,-53},{27,-53}},
                                                          color={0,0,127}));
  connect(dxDeh.port_b, zon.ports[2]) annotation (Line(points={{48,-58},{58,-58},
          {58,12},{-24,12},{-24,20.9}},
                                     color={0,127,255}));
  connect(booToReaFanEna.y, gai.u)
    annotation (Line(points={{-46,4},{-39.2,4}},     color={0,0,127}));
  connect(gai.y, fan.m_flow_in)
    annotation (Line(points={{-24.8,4},{8,4},{8,-20}},      color={0,0,127}));
  connect(realExpression2.y,m_flowFan. u)
    annotation (Line(points={{87,70},{100,70}},  color={0,0,127}));
  connect(realExpression9.y,m_flowFanEP. u)
    annotation (Line(points={{165,70},{178,70}}, color={0,0,127}));
  connect(realExpression1.y, mWatMod.u)
    annotation (Line(points={{87,36},{100,36}}, color={0,0,127}));
  connect(realExpression3.y, mWatEP.u)
    annotation (Line(points={{165,36},{178,36}}, color={0,0,127}));
  connect(realExpression4.y, QHeaMod.u)
    annotation (Line(points={{87,0},{100,0}}, color={0,0,127}));
  connect(realExpression5.y, QHeaEP.u)
    annotation (Line(points={{165,0},{178,0}}, color={0,0,127}));
  connect(realExpression6.y, PMod.u)
    annotation (Line(points={{87,-30},{102,-30}}, color={0,0,127}));
  connect(realExpression7.y, PEP.u)
    annotation (Line(points={{165,-30},{178,-30}}, color={0,0,127}));
  connect(realExpression8.y, TZonAirMod.u)
    annotation (Line(points={{87,-60},{102,-60}}, color={0,0,127}));
  connect(realExpression10.y, TZonAirEP.u)
    annotation (Line(points={{165,-60},{178,-60}}, color={0,0,127}));
  connect(realExpression11.y, phiZonAirMod.u)
    annotation (Line(points={{87,-90},{102,-90}}, color={0,0,127}));
  connect(realExpression12.y, phiZonAirEP.u)
    annotation (Line(points={{165,-90},{178,-90}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-140,-120},
            {100,80}})),  Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-160,-100},{200,100}})),
    experiment(
      StartTime=12960000,
      StopTime=13564800,
      __Dymola_Algorithm="Cvode"),
    __Dymola_Commands(file="Fluid/ZoneEquipment/DXDehumidifier/Validation/DXDehumidifier.mos"
        "Simulate and Plot"));
end DXDehumidifier;
